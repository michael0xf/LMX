#!/usr/bin/env python3
"""Import a C source census into the proposed LMX catalogue.

The hand-maintained placement source is package_plan.lmx. Generated LMX files
become the reviewable porting source. This importer is not a parser/compiler of
LMX: it reads only this document's deliberately restricted metadata forms.
Run into a fresh output directory; --replace-generated deliberately refreshes
generated candidates and never touches the normative spec or vendor sources.
"""
from __future__ import annotations
import argparse
import collections
import fnmatch
import gzip
import hashlib
import json
import os
import re
import sys
from pathlib import Path


def q(value):
    return json.dumps(str(value), ensure_ascii=False)


def ident(value):
    return re.sub(r"[^A-Za-z0-9_]", "_", value)


def load_plan(path):
    components, rules = {}, []
    mode, item = None, None
    for line in path.read_text().splitlines():
        if line == "    Components:": mode = "components"
        elif line == "    Rules:": mode = "rules"
        elif re.fullmatch(r"        [A-Za-z0-9_]+:", line):
            item = {}
            if mode == "rules": rules.append(item)
        else:
            m = re.fullmatch(r"            char\[\]: (\w+) (\".*\")", line)
            if m and item is not None:
                item[m[1]] = json.loads(m[2])
                if m[1] == "component" and mode == "components": components[item["component"]] = item
    return components, rules


def place(entry, plan, rules):
    p = dict(plan[entry["component"]])
    for r in rules:
        if (r["component"] == entry["component"]
                and fnmatch.fnmatchcase(entry["name"], r.get("namePattern", "*"))
                and fnmatch.fnmatchcase(entry.get("source", {}).get("path", ""), r.get("headerPattern", "*"))):
            p.update(r)
            break
    return p


def base_type(t):
    t = t or ""
    t = re.sub(r"\b(?:extern|static|inline|const|volatile|restrict|__inline__|__inline)\b", " ", t)
    t = re.sub(r"\b(?:[A-Z][A-Z0-9_]*(?:API|EXPORT|INLINE|DECL|PUBLIC|CALL|DEPRECATED)[A-Z0-9_]*|API|EXPORT)\b", " ", t)
    return " ".join(t.split())


SCALAR = {"int": "int", "unsigned": "unsigned", "unsigned int": "unsigned",
          "double": "double", "float": "float", "char": "char", "size_t": "size_t"}
def arg_model(param, primary):
    t = base_type(param.get("c_type"))
    name = param.get("name", "")
    # The extractor resolves typedefs within their component and records the
    # exact callback_type_refs. A same-named typedef in another library must
    # never turn an ordinary argument into a callback.
    if param.get("callback") or "(*" in t.replace(" ", ""):
        return "BridgeData\\Callback@", "callback_trampoline", "callback_contract_required"
    if param.get("variadic") or name == "..." or t == "...":
        return "@[]", "finite_typed_varargs", "specialize_before_publication"
    if param.get("semantic_role") in ("native_resource_id", "native_resource_output"):
        return "BridgeData\\Resource@", param["semantic_role"], "owner_bound_" + param.get("resource_backend", "native") + "_" + param.get("resource_kind", "handle")
    if param.get("semantic_role") == "native_resource_vector":
        return "@[]", "native_resource_vector", "checked_count_and_owner_bound_" + param.get("resource_backend", "native") + "_handles"
    if re.search(r"\bMPI_(?:Comm|Info|Datatype|Request|File|Group|Op|Win|Session)\b", t):
        return "BridgeData\\Resource@", "mpi_resource", "exact_MPI_kind_backend_ABI_owner_thread_support_and_collective_contract"
    if re.search(r"\bhid_t\b", t):
        return "BridgeData\\Resource@", "hdf5_resource", "exact_HDF5_identifier_kind_owner_lifetime_and_predefined_id_policy"
    if re.search(r"\b(?:MPI_Offset|MPI_Aint|MPI_Count|hsize_t|hssize_t)\b", t):
        if "*" in t or param.get("array"):
            return "BridgeData\\Buffer@", "checked_native_integer_span", "resolve_native_width_rank_count_units_and_overflow_no_typedef_cast"
        return "@", "checked_native_integer", "resolve_native_width_sign_offset_units_and_overflow"
    if not param.get("pointer") and not param.get("array") and t in SCALAR:
        return SCALAR[t], "exact_scalar", "c_width_preserved"
    if re.search(r"\b(?:int[0-9]+_t|uint[0-9]+_t|u?long|ssize_t|ptrdiff_t)\b", t) and "*" not in t and "[" not in t:
        return "@", "checked_integer", "resolve_native_width_then_choose_existing_integer"
    if "mpd_" in t or "decNumber" in t or "decDouble" in t or "decQuad" in t or "decSingle" in t:
        return "@", "decimal_backend", "one_decimal_semantic_type_explicit_context"
    if re.search(r"\bmp_int\b", t):
        return "@", "bigint_backend", "one_bigint_semantic_type"
    if re.search(r"\bbf_t\b", t):
        return "@", "real_backend", "one_real_semantic_type_explicit_binary_precision"
    if re.search(r"\bbfdec_t\b", t):
        return "@", "decimal_backend", "convert_to_canonical_decimal_no_second_decimal_type"
    if re.search(r"\b(?:utf8_t|utf16_t|utf32_t)\b", t) and ("*" in t or param.get("array")):
        return "BridgeData\\Buffer@", "checked_span", "unicode_code_unit_width_and_output_length_required"
    if re.search(r"\b(?:Bytef?|charf|voidpf?)\b", t):
        return "BridgeData\\Buffer@", "checked_span", "zlib_byte_storage_not_opaque_resource"
    if re.search(r"\b(?:uIntf?|uLongf?|z_size_t|z_off_t|z_off64_t)\b", t):
        if "*" in t:
            return "BridgeData\\ScalarCell@", "checked_scalar_output", "zlib_inout_count_copy_back_only_after_success"
        return "@", "checked_integer", "resolve_zlib_native_width_then_choose_existing_integer"
    if re.search(r"\b(?:liquid_float_complex|liquid_double_complex|kiss_fft_cpx)\b", t):
        return ("BridgeData\\ComplexBuffer@", "complex_buffer", "explicit_interleaved_or_planar_layout") if "*" in t or param.get("array") else ("BridgeData\\Complex@", "complex_components", "no_implicit_abi_equivalence")
    if "*" in t or param.get("pointer") or param.get("array"):
        if re.search(r"\bchar\b", t) and "const" in (param.get("c_type") or "") and t.count("*") == 1:
            return "char[]", "text_or_bytes", "review_length_encoding_nul_and_retention"
        if re.search(r"\b(?:char|void|u?int[0-9]+_t|float|double|unsigned|short|int)\b", t) or param.get("array"):
            return "BridgeData\\Buffer@", "checked_span", "review_element_type_shape_direction_and_lifetime"
        return "BridgeData\\Resource@", "typed_resource", "review_owner_native_type_generation_and_close"
    if "complex" in t or "_Complex" in t:
        return "BridgeData\\Complex@", "complex_components", "no_double_or_struct_pointer_cast"
    return "@", "typed_native_value", "resolve_typedef_enum_or_by_value_record"


def is_callable(e):
    if "publish_candidate" in e: return bool(e["publish_candidate"])
    return e["classification"] in {"function", "static_inline", "generated_function", "platform_function"}


def direct_scalar(e):
    if e.get("ffi_disposition") in {"unimplemented_declaration_contract", "outside_selected_profile", "typed_scientific_resource_bridge"}:
        return False
    if (e.get("availability", "").startswith(("outside_selected_", "not_built_"))
            or e.get("availability") in {"unimplemented", "declared_unimplemented", "application_implementation_required"}):
        return False
    if e.get("unresolved") or e.get("variant_count", 1) != 1:
        return False
    if e["classification"] not in {"function", "static_inline", "generated_function"}:
        return False
    if base_type(e.get("return_type")) not in set(SCALAR) | {"void"}:
        return False
    return all(base_type(p.get("c_type")) in SCALAR and not any(p.get(k) for k in ("pointer", "array", "callback", "variadic"))
               for p in e.get("parameters", []))


def shim_name(e):
    return "lmx_bridge_" + ident(e["name"]) + "_" + e["id"].split("_")[-1]


def macro_id(e):
    return e["id"].upper()


def param_names(e):
    seen = set()
    result = []
    for i, p in enumerate(e.get("parameters", [])):
        n = ident(p.get("name") or "arg" + str(i))
        if not n or not re.match(r"[A-Za-z_]", n) or n in {"return", "node", "data", "request", "context", "throws", "parent"}:
            n = "arg" + str(i)
        if n in seen: n += "_" + str(i)
        seen.add(n); result.append(n)
    return result


def emit_c(e):
    """A default refusing entry + a concrete, opt-in typed forwarding body.

    There is deliberately no name->address dispatcher, void** argument cast,
    guessed struct layout or automatic varargs/typedef promotion.
    """
    mid, name = macro_id(e), shim_name(e)
    if (e.get("ffi_disposition") == "unimplemented_declaration_contract"
            or e.get("availability", "").startswith(("outside_selected_", "not_built_"))
            or e.get("availability") == "application_implementation_required"):
        return ("/* " + e["id"] + ": declaration unavailable in this selected profile or requiring an owner implementation. */\n"
                "/* No opt-in native branch is emitted for this declaration. */\n"
                "int " + name + "(void *opaque)\n{\n"
                "    return lmx_catalog_review_required((lmx_catalog_frame *)opaque, "
                + q(e["name"]) + ");\n}\n")
    ps = e.get("parameters", [])
    variadic = any(p.get("variadic") or p.get("name") == "..." or p.get("c_type") == "..." for p in ps)
    fixed = [p for p in ps if not (p.get("variadic") or p.get("name") == "..." or p.get("c_type") == "...")]
    void = base_type(e.get("return_type")) == "void"
    source = e["source"]
    sig = (e.get("signature") or "").replace("*/", "* /")
    lines = ["", "/* " + e["id"] + " | " + e["name"],
             " * " + source["path"] + ":" + str(source["line"]), " * " + sig, " */",
             "#ifdef LMXC99_ENABLE_" + mid,
             "/* The selected target must supply its real public header/config.",
             " * For generated .h.in or alternate profiles, override HEADER explicitly. */",
             "#ifndef LMXC99_HEADER_" + mid,
             "#define LMXC99_HEADER_" + mid + " " + q(e.get("canonical_header") or "REVIEW_PUBLIC_HEADER.h"),
             "#endif", "#include LMXC99_HEADER_" + mid, "#endif",
             "int " + name + "(void *opaque)", "{", "    lmx_catalog_frame *frame = (lmx_catalog_frame *)opaque;",
             "#ifdef LMXC99_ENABLE_" + mid]
    lines += ["    int rc;"]
    for i in range(len(fixed)):
        lines += [f"    LMXC99_TYPE_{mid}_A{i} a{i};"]
    if not void: lines += [f"    LMXC99_RESULT_{mid} result;"]
    lines += [f"    rc = lmx_catalog_check(frame, {len(fixed)}U);", "    if (rc != LMXC_OK) return rc;"]
    if variadic:
        lines += ["    /* This template is not an arbitrary variadic ABI. A reviewed finite",
                  "     * specialization supplies extra typed locals before the call. */",
                  f"    LMXC99_PREPARE_VARARGS_{mid}(frame);"]
    for i in range(len(fixed)):
        lines += [f"    rc = LMXC99_READ_{mid}_A{i}(frame, {i}U, &a{i});", "    if (rc != LMXC_OK) return rc;"]
    lines += ["    /* All conversions are finished in lexical order before C evaluates its",
              "     * argument expressions. CHECK validates cross-argument lengths, output",
              "     * capacity, overlap, resource states and any per-operation domain rule. */",
              f"    rc = LMXC99_CHECK_{mid}(frame);", "    if (rc != LMXC_OK) return rc;"]
    args = ["a" + str(i) for i in range(len(fixed))]
    if variadic: args.append("LMXC99_VARARGS_" + mid)
    call = (e.get("abi_symbol") or e["name"]) + "(" + ", ".join(args) + ")"
    lines += ["    " + ("" if void else "result = ") + call + ";"]
    lines += [f"    return LMXC99_SAVE_{mid}(frame" + ("" if void else ", result") + ");",
              "#else", "    return lmx_catalog_review_required(frame, " + q(e["name"]) + ");", "#endif", "}"]
    return "\n".join(lines) + "\n"


# The following is a reader/writer for one metadata notation, not an LMX parser.
# Parenthesized values are ordinary positional Structures. Every foreign key is
# documented in Columns and FORMAT; this metadata reader is not a language parser.
SCHEMA_VERSION = 2
TABLE_CHUNK_SIZE = 32
PRIMARY_KEYS = ("signature", "return_type", "parameters", "source", "conditions",
                "extraction", "availability", "unresolved", "notes", "body")
PARAM_FLAGS = ("pointer", "array", "callback", "variadic", "name_in_source")
TABLE_COLUMNS = {
    "Parameters": ("cName", "cType", "flags", "declarationMode", "declarationOverride", "model", "extra"),
    "Specs": ("signature", "returnType", "parameterList"),
    "Origins": ("extraction", "availability", "unresolved", "notes", "body", "conditionsPresent"),
    "Variants": ("spec", "source", "line", "conditions", "origin", "extra"),
    "Profiles": ("kind", "header", "targets", "ffiDisposition", "publishCandidate", "pubCandidate", "status", "callable", "direct"),
    "Placements": ("package", "primaryModel", "extra"),
    "Entries": ("symbol", "spec", "source", "line", "conditions", "origin", "profile", "variants", "placement", "extra"),
}
TABLE_PREFIX = {"Signatures": "s", "Types": "t", "Sources": "r", "Lists": "l",
                "Properties": "x", "Parameters": "p", "ParameterLists": "a", "Specs": "q",
                "Origins": "o", "Variants": "d", "VariantLists": "v", "Profiles": "f", "Placements": "g"}
STATUS = ("METADATA_ONLY", "DIRECT_SCALAR_PROTOTYPE_NOT_RUN", "TYPED_SHIM_REVIEW_REQUIRED",
          "UNIMPLEMENTED_DECLARATION_REVIEW_REQUIRED", "PROFILE_REVIEW_REQUIRED")


def frozen(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def native(value):
    if isinstance(value, str): return q(value)
    if isinstance(value, bool): return str(int(value))
    if isinstance(value, int): return str(value)
    if isinstance(value, tuple): return "(" + ";".join(native(v) for v in value) + ")"
    if isinstance(value, list): return "[" + " ".join(native(v) for v in value) + "]"
    raise TypeError(type(value))


def pack(value):
    """Lossless uncommon properties, still native nested LMX Structures."""
    if value is None: return ("n",)
    if isinstance(value, bool): return ("b", int(value))
    if isinstance(value, str): return ("s", value)
    if isinstance(value, int): return ("i", value)
    if isinstance(value, float): return ("f", repr(value))
    if isinstance(value, list): return ("l", tuple(pack(v) for v in value))
    if isinstance(value, dict): return ("d", tuple((k, pack(v)) for k, v in sorted(value.items())))
    raise TypeError(type(value))


def unpack(value):
    tag = value[0]
    if tag == "n": return None
    if tag == "b": return bool(value[1])
    if tag == "s": return value[1]
    if tag == "i": return value[1]
    if tag == "f": return float(value[1])
    if tag == "l": return [unpack(v) for v in value[1]]
    if tag == "d": return {k: unpack(v) for k, v in value[1]}
    raise ValueError("Unknown metadata value tag: " + str(tag))


class Pool:
    def __init__(self):
        self.rows, self.lookup = [], {}

    def add(self, value):
        key = frozen(value)
        if key not in self.lookup:
            self.lookup[key] = len(self.rows)
            self.rows.append(value)
        return self.lookup[key]


def delta(original, base):
    changes = {k: v for k, v in original.items() if k not in base or v != base[k]}
    omitted = [k for k in base if k not in original]
    if omitted: changes["$omit"] = omitted
    return changes


def apply_delta(base, changes):
    result = dict(base)
    for key in changes.get("$omit", []): result.pop(key, None)
    result.update({k: v for k, v in changes.items() if k != "$omit"})
    return result


def status_of(e):
    if e.get("ffi_disposition") == "unimplemented_declaration_contract": return 3
    if not is_callable(e): return 0
    if (e.get("ffi_disposition") == "outside_selected_profile"
            or e.get("availability", "").startswith(("outside_selected_", "not_built_"))
            or e.get("availability") == "application_implementation_required"): return 4
    return 1 if direct_scalar(e) else 2


class Component:
    def __init__(self, info, models):
        self.info, self.models = info, models
        self.cid, self.ci = info["id"], ident(info["id"])
        self.tables = {name: Pool() for name in TABLE_PREFIX}
        self.entries = {}
        self.props({})

    def add(self, table, value): return self.tables[table].add(value)
    def get(self, table, key): return self.tables[table].rows[key]
    def props(self, value): return self.add("Properties", pack(value))
    def prop(self, key): return unpack(self.get("Properties", key))
    def typ(self, value): return -1 if value is None else self.add("Types", value)
    def type_value(self, key): return None if key == -1 else self.get("Types", key)

    def parameter(self, p, primary_model):
        flags = sum((1 << i) | ((1 << (i + 5)) if p[k] else 0)
                    for i, k in enumerate(PARAM_FLAGS) if k in p)
        name, ctype, decl = p.get("name", ""), p.get("c_type"), p.get("declaration")
        if decl == ctype: mode, override = 0, ""
        elif isinstance(ctype, str) and decl == ctype + " " + name: mode, override = 1, ""
        else: mode, override = 2, decl or ""
        row = (name, self.typ(ctype), flags, mode, override,
               self.models.add(tuple(arg_model(p, primary_model))), 0)
        base = self.decode_parameter(row)
        row = row[:-1] + (self.props(delta(p, base)),)
        return self.add("Parameters", row)

    def decode_parameter(self, row):
        name, tid, flags, mode, override, model, extra = row
        ctype = self.type_value(tid)
        decl = ctype if mode == 0 else ctype + " " + name if mode == 1 else override
        p = {"name": name, "c_type": ctype, "declaration": decl}
        for i, key in enumerate(PARAM_FLAGS):
            if flags & (1 << i): p[key] = bool(flags & (1 << (i + 5)))
        return apply_delta(p, self.prop(extra))

    def encode_primary(self, d, primary_model):
        params = self.add("ParameterLists", [self.parameter(p, primary_model) for p in d.get("parameters", [])])
        spec = self.add("Specs", (self.add("Signatures", d.get("signature", "")), self.typ(d.get("return_type")), params))
        source = d.get("source") or {"path": "", "line": 0}
        path = self.add("Sources", source["path"])
        conditions = self.add("Lists", tuple(d.get("conditions") or []))
        notes = self.add("Lists", tuple(d.get("notes") or []))
        body = int(bool(d["body"])) if "body" in d else -1
        origin = self.add("Origins", (d.get("extraction", ""), d.get("availability", ""), int(bool(d.get("unresolved"))), notes, body, int("conditions" in d)))
        return (spec, path, int(source["line"]), conditions, origin)

    def decode_primary(self, row):
        spec, source, line, conditions, origin = row[:5]
        signature, ret, params = self.get("Specs", spec)
        extraction, availability, unresolved, notes, body, has_conditions = self.get("Origins", origin)
        d = {"signature": self.get("Signatures", signature), "return_type": self.type_value(ret),
             "parameters": [self.decode_parameter(self.get("Parameters", p)) for p in self.get("ParameterLists", params)],
             "source": {"path": self.get("Sources", source), "line": line}, "extraction": extraction,
             "availability": availability, "unresolved": bool(unresolved), "notes": list(self.get("Lists", notes))}
        if body >= 0: d["body"] = bool(body)
        if has_conditions: d["conditions"] = list(self.get("Lists", conditions))
        return d

    def add_entry(self, e, placement):
        model = placement["primaryModel"]
        primary = self.encode_primary(e, model)
        primary_decoded = {k: e[k] for k in PRIMARY_KEYS if k in e}
        primary_decoded.update(classification=e["classification"], canonical_header=e.get("canonical_header"), targets=e.get("targets"))
        primary_decoded["return_type"] = e.get("return_type_original", e.get("return_type"))
        variants = []
        for d in e.get("declarations", []):
            if d == primary_decoded:
                variants.append(-1)
            else:
                vd = self.encode_primary(d, model)
                ve = self.props(delta(d, self.decode_primary(vd)))
                variants.append(self.add("Variants", vd + (ve,)))
        vlist = self.add("VariantLists", variants)
        profile = self.add("Profiles", (e["classification"], e.get("canonical_header") or "",
             self.add("Lists", tuple(e.get("targets") or [])), e.get("ffi_disposition") or "",
             int(bool(e.get("publish_candidate", is_callable(e)))), int(bool(e.get("pub_candidate", is_callable(e)))),
             status_of(e), int(is_callable(e)), int(is_callable(e) and direct_scalar(e))))
        place_id = self.add("Placements", (placement["package"], model,
                    self.props({k: v for k, v in placement.items() if k not in {"package", "primaryModel"}})))
        row = (e["name"],) + primary + (profile, vlist, place_id, 0)
        base, _ = self.decode_entry(e["id"], row)
        # Declaration reconstruction uses the restored original return type and
        # entry attributes, so defer that part until sparse properties exist.
        base["declarations"] = e.get("declarations", [])
        row = row[:-1] + (self.props(delta(e, base)),)
        self.entries[e["id"]] = row

    def decode_entry(self, eid, row):
        name, spec, source, line, conditions, origin, profile, variants, placement, extra = row
        primary = self.decode_primary((spec, source, line, conditions, origin))
        kind, header, targets, ffi, publish, pub, status, callable_, direct = self.get("Profiles", profile)
        variant_ids = self.get("VariantLists", variants)
        e = {**primary, "id": eid, "component": self.cid, "name": name,
             "classification": kind, "canonical_header": header, "targets": list(self.get("Lists", targets)),
             "ffi_disposition": ffi, "publish_candidate": bool(publish), "pub_candidate": bool(pub),
             "abi_symbol": name, "return_type_original": primary["return_type"], "variant_count": len(variant_ids)}
        e = apply_delta(e, self.prop(extra))
        declared = {k: e[k] for k in PRIMARY_KEYS if k in e}
        declared.update(classification=e["classification"], canonical_header=e.get("canonical_header"), targets=e.get("targets"))
        declared["return_type"] = e.get("return_type_original", e.get("return_type"))
        declarations = []
        for did in variant_ids:
            if did == -1: declarations.append(dict(declared))
            else:
                dr = self.get("Variants", did)
                declarations.append(apply_delta(self.decode_primary(dr), self.prop(dr[5])))
        e["declarations"] = declarations
        package, model, props = self.get("Placements", placement)
        p = {**self.prop(props), "package": package, "primaryModel": model}
        return e, p

    def inline_spec(self, sid):
        signature, ret, params = self.get("Specs", sid)
        return (signature, ret, tuple(self.get("ParameterLists", params)))

    def expand_spec(self, spec):
        signature, ret, params = spec
        return self.add("Specs", (signature, ret, self.add("ParameterLists", params)))

    def text(self):
        lines = ["# Canonical compact LMX proposal. Columns are positional; ids are table-local.",
                 "# Reader/schema: ../CATALOG_FORMAT.ru.md. No publication or runtime proof.",
                 "C99Catalog_" + self.ci + ":", "    int: schemaVersion 2",
                 "    int: tableChunkSize " + str(TABLE_CHUNK_SIZE),
                 "    char[]: componentId " + q(self.cid),
                 "    @: component " + native(pack(self.info)),
                 "    @: models C99Schema\\Models", "    Columns:"]
        for table, cols in TABLE_COLUMNS.items(): lines.append("        @: " + table + " " + native(cols))
        lines.append("    ---")
        property_keys, property_values = Pool(), Pool()
        property_rows = []
        for value in self.tables["Properties"].rows:
            if value[0] != "d": raise ValueError("Property record must be a dictionary")
            property_rows.append(tuple((property_keys.add(key), property_values.add(val)) for key, val in value[1]))
        serialized = [("PropertyKeys", "k", property_keys.rows),
                      ("PropertyValues", "z", property_values.rows)]
        for table, pool in self.tables.items():
            if table in {"Specs", "ParameterLists", "VariantLists"}: continue
            if table == "Properties": rows = property_rows
            elif table == "Variants": rows = [(self.inline_spec(row[0]),) + row[1:] for row in pool.rows]
            else: rows = pool.rows
            serialized.append((table, TABLE_PREFIX[table], rows))
        for table, prefix, rows in serialized:
            lines.append("    " + table + ":")
            for start in range(0, len(rows), TABLE_CHUNK_SIZE):
                lines.append("        @: " + prefix + str(start // TABLE_CHUNK_SIZE) + " " + native(tuple(rows[start:start + TABLE_CHUNK_SIZE])))
        lines.append("    Entries:")
        for eid, row in self.entries.items():
            row = (row[0], self.inline_spec(row[1])) + row[2:7] + (tuple(self.get("VariantLists", row[7])),) + row[8:]
            lines.append("        @: " + eid + " " + native(row))
        return "\n".join(lines) + "\n"


class NativeReader:
    """Read this restricted metadata subset, never executable language syntax."""
    def __init__(self, text): self.text, self.pos = text, 0

    def space(self):
        while self.pos < len(self.text) and self.text[self.pos].isspace(): self.pos += 1

    def value(self):
        self.space()
        if self.pos >= len(self.text): raise ValueError("Missing metadata value")
        ch = self.text[self.pos]
        if ch == '"':
            value, size = json.JSONDecoder().raw_decode(self.text[self.pos:])
            self.pos += size
            return value
        if ch in "([":
            self.pos += 1
            values, close = [], ")" if ch == "(" else "]"
            self.space()
            while self.pos < len(self.text) and self.text[self.pos] != close:
                values.append(self.value()); self.space()
                if self.pos < len(self.text) and self.text[self.pos] == ";": self.pos += 1; self.space()
                elif ch == "(" and self.pos < len(self.text) and self.text[self.pos] != close:
                    raise ValueError("Structure values require ';'")
            if self.pos >= len(self.text): raise ValueError("Unclosed metadata structure")
            self.pos += 1
            return tuple(values) if ch == "(" else values
        m = re.match(r"-?[0-9]+", self.text[self.pos:])
        if not m: raise ValueError("Not supported metadata syntax near " + self.text[self.pos:self.pos+40])
        self.pos += len(m[0]); return int(m[0])

    def read(self):
        value = self.value(); self.space()
        if self.pos != len(self.text): raise ValueError("Trailing metadata content")
        return value


def read_component(path, models):
    text = path.read_text()
    cm = re.search(r'^    @: component (.*)$', text, re.M)
    if not cm: raise ValueError("No component metadata: " + str(path))
    component = Component(unpack(NativeReader(cm[1]).read()), models)
    chunk_match = re.search(r'^    int: tableChunkSize ([0-9]+)$', text, re.M)
    chunk_size = int(chunk_match[1]) if chunk_match else 1
    if chunk_size != TABLE_CHUNK_SIZE: raise ValueError("Unsupported table chunk size: " + str(path))
    for pool in component.tables.values(): pool.rows.clear(); pool.lookup.clear()
    property_keys, property_values, compact_properties = [], [], []
    table = None
    for lineno, line in enumerate(text.splitlines(), 1):
        m = re.fullmatch(r"    ([A-Za-z]+):", line)
        if m: table = m[1]; continue
        m = re.fullmatch(r"        (?:char\[\]|int\[\]|@): (\w+) (.*)", line)
        if not m: continue
        if table == "Columns":
            if m[1] in TABLE_COLUMNS and NativeReader(m[2]).read() != TABLE_COLUMNS[m[1]]:
                raise ValueError(f"Changed column schema at {path}:{lineno}")
            continue
        if table == "Entries":
            row = NativeReader(m[2]).read()
            row = (row[0], component.expand_spec(row[1])) + row[2:7] + (component.add("VariantLists", row[7]),) + row[8:]
            component.entries[m[1]] = row
        elif table in TABLE_PREFIX or table in {"PropertyKeys", "PropertyValues"}:
            prefix = {"PropertyKeys": "k", "PropertyValues": "z"}.get(table, TABLE_PREFIX.get(table))
            target = property_keys if table == "PropertyKeys" else property_values if table == "PropertyValues" else compact_properties if table == "Properties" else component.tables[table].rows
            if len(target) % chunk_size or m[1] != prefix + str(len(target) // chunk_size):
                raise ValueError(f"Non-contiguous {table} ids at {path}:{lineno}")
            chunk = NativeReader(m[2]).read()
            if not 1 <= len(chunk) <= chunk_size: raise ValueError(f"Invalid chunk at {path}:{lineno}")
            for row in chunk:
                if table == "Variants": row = (component.expand_spec(row[0]),) + row[1:]
                target.append(row)
    component.tables["Properties"].rows = [("d", tuple((property_keys[k], property_values[v]) for k, v in row)) for row in compact_properties]
    return component


def explicit_cuts(content):
    result, previous = [], None
    for line in content.splitlines():
        stripped = line.strip()
        if not stripped: previous = None
        elif not stripped.startswith("#"):
            indent = len(line) - len(line.lstrip(" "))
            if previous is not None and previous - indent > 4 and not stripped.startswith("---"):
                result.append(" " * indent + "---")
            previous = indent
        result.append(line)
    return "\n".join(result) + "\n"


def write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.suffix in {".lmx", ".lm2", ".lm3"}: content = explicit_cuts(content)
    path.write_text(content, encoding="utf-8")


def method_path(e):
    if direct_scalar(e): return "C99Direct_" + e["id"] + "\\invoke"
    return "C99Calls_" + ident(e["component"]) + "\\" + e["id"]


def binding_text(component):
    rows = [component.decode_entry(eid, row)[0] for eid, row in component.entries.items()]
    callables = [e for e in rows if is_callable(e)]
    direct = [e for e in callables if direct_scalar(e)]
    shims = [e for e in callables if not direct_scalar(e)]
    lines = ["# Porting scaffold; not compiled or published. See ../CATALOG_FORMAT.ru.md.",
             "# Metadata: ../catalog/" + component.ci + ".lmx; CallRequest validation is per entry."]
    headers = sorted({e["canonical_header"] for e in direct if e.get("canonical_header")})
    if headers: lines += ["L2:"] + ["    include: " + q('"' + h + '"') for h in headers] + [""]
    if shims:
        root = "C99Catalog_" + component.ci
        lines += ["C99Calls_" + component.ci + ":", "    private: BridgeData\\CallRequest@: request",
                  "    required: request", "    return: BridgeData\\CallResult@"]
        for e in shims:
            lines += ["    " + e["id"] + ":", "        throws: BridgeLowerError", "        L2:",
                      "            @: f BridgeLower\\open(request, " + root + ", " + root + "\\Entries\\" + e["id"] + ")",
                      "            finally:", "                BridgeLower\\release(f)", "            ---",
                      "            int: s c." + shim_name(e) + "(f)",
                      "            return: BridgeLower\\finish(f, s)"]
        lines.append("")
    for e in direct:
        names = param_names(e)
        lines += ["C99Direct_" + e["id"] + ":"]
        for p, name in zip(e.get("parameters", []), names): lines.append("    private: " + SCALAR[base_type(p["c_type"])] + ": " + name)
        if names: lines.append("    required: " + " ".join(names))
        ret = base_type(e.get("return_type"))
        if ret != "void": lines.append("    return: " + SCALAR[ret])
        lines += ["    invoke:", "        L2:", "            " + ("return: " if ret != "void" else "")
                  + "c." + (e.get("abi_symbol") or e["name"]) + "(" + ", ".join(names) + ")", ""]
    return "\n".join(lines) + "\n"


def read_catalog(root, component_filter=None, entry_id=None):
    models = Pool()
    schema = root / "catalog/schema.lmx"
    for line in schema.read_text().splitlines():
        m = re.fullmatch(r"        @: m[0-9]+ (.*)", line)
        if m: models.rows.append(NativeReader(m[1]).read())
    if component_filter:
        files = [root / "catalog" / (ident(component_filter) + ".lmx")]
        if not files[0].is_file(): raise SystemExit("Unknown component: " + component_filter)
    else:
        files = [p for p in sorted((root / "catalog").glob("*.lmx")) if p.name != "schema.lmx"]
        if entry_id:
            marker = "        @: " + entry_id + " "
            files = [p for p in files if marker in p.read_text()]
    components = [read_component(p, models) for p in files]
    if component_filter and any(c.cid != component_filter for c in components):
        raise ValueError("Component filename identity mismatch")
    return components, models


def source_coverage_text(data):
    """Small, self-contained fingerprints; no duplicate diagnostics/report."""
    components, targets, rows = Pool(), Pool(), []
    prefix = data["source_root"].rstrip("/") + "/"
    keys = {"component", "path", "targets", "sha256", "bytes", "raw_declarations", "function_macros"}
    for header in data.get("header_coverage", []):
        if set(header) != keys or not header["path"].startswith(prefix):
            raise ValueError("Unrecognized header coverage schema")
        rows.append((components.add(header["component"]), header["path"][len(prefix):],
                     targets.add(tuple(header["targets"])), header["sha256"],
                     header["bytes"], header["raw_declarations"], header["function_macros"]))
    lines = ["", "C99SourceCoverage:", "    char[]: sourceRoot " + q(data["source_root"]),
             "    int: tableChunkSize " + str(TABLE_CHUNK_SIZE),
             "    @: columns " + native(("component", "path", "targets", "sha256", "bytes", "rawDeclarations", "functionMacros")),
             "    @: components " + native(tuple(components.rows)),
             "    @: targets " + native(tuple(targets.rows)), "    Headers:"]
    for start in range(0, len(rows), TABLE_CHUNK_SIZE):
        lines.append("        @: h" + str(start // TABLE_CHUNK_SIZE) + " " + native(tuple(rows[start:start + TABLE_CHUNK_SIZE])))
    return "\n".join(lines) + "\n"


def read_source_coverage(root):
    text = (root / "catalog/schema.lmx").read_text().split("\nC99SourceCoverage:\n", 1)[1]
    def field(name):
        m = re.search(r'^    (?:@|char\[\]): ' + name + r' (.*)$', text, re.M)
        if not m: raise ValueError("Missing source coverage field " + name)
        return NativeReader(m[1]).read()
    prefix, components, targets = field("sourceRoot") + "/", field("components"), field("targets")
    headers = []
    for line in text.splitlines():
        m = re.fullmatch(r"        @: h[0-9]+ (.*)", line)
        if m:
            for component, path, target, sha, size, declarations, macros in NativeReader(m[1]).read():
                headers.append({"component": components[component], "path": prefix + path,
                                "targets": list(targets[target]), "sha256": sha, "bytes": size,
                                "raw_declarations": declarations, "function_macros": macros})
    return headers


def publication_names(entries, placements):
    """Two-stage identity-preserving collision policy, including same backend."""
    by_path = collections.defaultdict(list)
    for e in entries:
        if is_callable(e): by_path[placements[e["id"]]["package"] + "\\" + e["name"]].append(e)
    result, collisions = {}, {}
    for path, group in by_path.items():
        if len(group) == 1: result[group[0]["id"]] = path; continue
        collisions[path] = []
        for e in group:
            name = ident(e["component"].split(":", 1)[-1]) + "__" + e["name"]
            result[e["id"]] = placements[e["id"]]["package"] + "\\" + name
    reversed_paths = collections.defaultdict(list)
    for eid, path in result.items(): reversed_paths[path].append(eid)
    for path, ids in reversed_paths.items():
        if len(ids) > 1:
            for eid in ids: result[eid] = path + "__" + eid.removeprefix("capi_")
    if len(set(result.values())) != len(result): raise ValueError("Publication collision survived stable id suffix")
    for path in collisions:
        collisions[path] = [{"id": e["id"], "publicationPath": result[e["id"]]} for e in by_path[path]]
    return result, collisions


def projections(out, components, extra_summary=None):
    entries, placements, catalogs, lines = [], {}, {}, {}
    for c in components:
        for eid, row in c.entries.items():
            e, p = c.decode_entry(eid, row); entries.append(e); placements[eid] = p; catalogs[eid] = "catalog/" + c.ci + ".lmx"
        for n, line in enumerate((out / "catalog" / (c.ci + ".lmx")).read_text().splitlines(), 1):
            m = re.match(r"        @: (capi_[A-Za-z0-9_]+) ", line)
            if m: lines[m[1]] = n
    names, collisions = publication_names(entries, placements)
    component_summary, packages = [], collections.defaultdict(lambda: {"entries": 0, "callables": 0})
    by_comp = collections.defaultdict(list)
    for e in entries:
        by_comp[e["component"]].append(e); pp = packages[placements[e["id"]]["package"]]
        pp["entries"] += 1; pp["callables"] += int(is_callable(e))
    # Compact gzip projection; the complete record is read from its canonical LMX.
    index = {"schema_version": 2, "columns": ["id", "symbol", "component", "package", "status", "catalogLine", "publicationPath"], "rows": []}
    for e in entries:
        index["rows"].append([e["id"], e["name"], e["component"], placements[e["id"]]["package"], status_of(e), lines[e["id"]], names.get(e["id"], "")])
    (out / "catalog_index.json.gz").write_bytes(gzip.compress(json.dumps(index, ensure_ascii=False, separators=(",", ":")).encode(), compresslevel=9, mtime=0))
    for c in components:
        es = by_comp[c.cid]; counts = dict(collections.Counter(e["classification"] for e in es))
        item = {"component": c.cid, "entries": len(es), "callables": sum(is_callable(e) for e in es),
                "direct_scalar": sum(is_callable(e) and direct_scalar(e) for e in es), "counts": counts,
                "catalog": "catalog/" + c.ci + ".lmx", "packages": sorted({placements[e["id"]]["package"] for e in es})}
        component_summary.append(item)
        md = ["# " + c.cid, "", "[Первичный LMX-каталог](../catalog/" + c.ci + ".lmx) · [Тела LMX](../bindings/" + c.ci + ".lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)", "",
              "Версия: `" + str(c.info.get("version") or c.info.get("commit") or "см. SOURCES.json") + "`.",
              "Записей: **" + str(len(es)) + "**; кандидатов вызова: **" + str(item["callables"]) + "**; scalar prototypes: **" + str(item["direct_scalar"]) + "**.", "",
              "Пакеты: " + ", ".join("`" + p + "`" for p in item["packages"]) + ".",
              "CMake: " + ", ".join("`" + t + "`" for t in c.info.get("targets", [])) + ".", "",
              "| Категория | Записи |", "|---|---:|"]
        md += ["| " + k + " | " + str(v) + " |" for k, v in sorted(counts.items())]
        md += ["", "Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.", "",
               "Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`)."]
        write(out / "reference" / (c.ci + ".md"), "\n".join(md) + "\n")
    summary = {"schema_version": 2, "components": component_summary, "entries": len(entries),
               "callable_candidates": sum(is_callable(e) for e in entries), "direct_scalar_prototypes": sum(is_callable(e) and direct_scalar(e) for e in entries),
               "classification_counts": dict(collections.Counter(e["classification"] for e in entries)),
               "package_counts": dict(sorted(packages.items())), "collisions": collisions,
               "lmx_runtime": "NOT_RUN", "whole_collection_link": "NOT_RUN", **(extra_summary or {})}
    summary["generated_bytes"] = {name: sum(p.stat().st_size for p in (out / name).rglob("*") if p.is_file()) for name in ("catalog", "bindings", "reference", "c_shims")}
    summary["generated_bytes"]["catalog_index.json.gz"] = (out / "catalog_index.json.gz").stat().st_size
    write(out / "catalog_summary.json", json.dumps(summary, ensure_ascii=False, indent=2) + "\n")
    write(out / "catalog_index.json", json.dumps({"schema_version": 2, "projection": "catalog_index.json.gz", "primary": "catalog/*.lmx", "entries": len(entries), "reader": "tools/build_c_catalog.py --catalog-root . --export-json FILE"}, ensure_ascii=False, indent=2) + "\n")
    # Publication rows are derived from canonical Entries and Paths; only the
    # collision exceptions are repeated here. Bootstrap is an explicit task.
    pub = ["# Descriptor recipe, not an installer. Expand from canonical Entries.", "C99PublicationPlan:",
           "    char[]: source \"catalog/*.lmx\"", "    char[]: eligible \"Profiles.callable = 1; publication still requires review\"",
           "    char[]: ordinaryPath \"Placements.package + backslash + Entries.symbol\"",
           "    char[]: directMethod \"C99Direct_<entry-id>\\\\invoke\"",
           "    char[]: shimMethod \"C99Calls_<component-id>\\\\<entry-id>\"",
           "    char[]: status \"proposal_only; runtime NOT_RUN\"", "    @: exceptionColumns (\"id\"; \"publicationPath\")", "    Exceptions:"]
    for path in sorted(collisions):
        for row in collisions[path]: pub.append("        @: " + row["id"] + " " + native((row["id"], row["publicationPath"])))
    write(out / "publication.lmx", "\n".join(pub) + "\n")
    md = ["# Пакеты C API", "", "Первичный план: [package_plan.lmx](package_plan.lmx). [Компактный формат](CATALOG_FORMAT.ru.md). Полные объявления и каждый вариант сохранены в LMX; большие JSON/C-проекции создаются по запросу.", "",
          "| Пакет | Кандидаты функций | Все записи |", "|---|---:|---:|"]
    md += [f"| `{p}` | {v['callables']} | {v['entries']} |" for p, v in sorted(packages.items())]
    md += ["", "## Компоненты", "", "| Компонент | Кандидаты | Записи |", "|---|---:|---:|"]
    md += [f"| [{c['component']}](reference/{ident(c['component'])}.md) | {c['callables']} | {c['entries']} |" for c in component_summary]
    md += ["", "Коллизии сохраняют отдельные backend API: `component__symbol`, а при повторной коллизии добавляется полный стабильный ID. Таблица исключений — [publication.lmx](publication.lmx). Ни одно совпавшее имя не объединяет договоры или реализации."]
    write(out / "PACKAGES.ru.md", "\n".join(md) + "\n")
    return summary


FORMAT_RU = '''# Компактный C-каталог в обычных LMX-структурах

Первичный материал — файлы [catalog/](catalog/). Каждая строка `@: name (a; b; ...)` хранит позиционную **Structure**. Вложенные последовательности — тоже обычные Structures, включая одиночную `(x)` и пустую `()`. Это не новый синтаксис языка и не JSON в строке. Порядок полей объявлен один раз в `Columns` каждого компонента; общие правила и LMX-модели находятся в [schema.lmx](catalog/schema.lmx). Проверка генератора читает только этот узкий формат данных и **не является P0-парсером, компилятором или доказательством запуска L3**.

Повторяющиеся справочники записаны группами по **32 логические записи** — `tableChunkSize`. Например, `Signatures` содержит `@: s0 ("первая сигнатура"; ...; "тридцать вторая")`, затем `@: s1 (...)`. Ссылка `N` означает поле `N % 32` (нумерация с нуля) внутри группы с суффиксом `N // 32`. Последняя группа может быть короче. Это правило действует для всех таблиц компонента кроме `Columns` и `Entries`; `Models` в общей схеме имеет отдельные именованные строки `mN`. Группировка убирает повторение объявления узла на каждой справочной строке. Она сохраняет каждую строку C-сигнатуры целиком и не вводит сжатого бинарного payload.

## Как читать одну функцию

Найдите C-имя в `Entries` файла компонента. Имя строки `capi_...` — стабильная идентичность API. Позиции строки:

| Поле | Значение |
|---|---|
| `symbol` | Исходное C-имя; разные backend остаются разными записями |
| `spec` | Вложенная тройка `(signature; returnType; (parameters...))`: индексы `Signatures`, `Types` и последовательность индексов `Parameters`; отдельных файлов Specs/ParameterLists нет |
| `source`, `line` | Индекс `Sources` и точная строка исходного объявления |
| `conditions`, `origin` | Индексы `Lists` и `Origins`: условия препроцессора, способ извлечения, availability, unresolved, notes, наличие C-тела |
| `profile` | Индекс `Profiles`: категория, публичный include, targets, disposition, candidate flags и состояние |
| `variants` | Вложенная упорядоченная последовательность: `-1` означает основное объявление, другой номер — индекс `Variants` |
| `placement` | Индекс `Placements`: смысловой пакет, общая модель, дополнительные правила плана |
| `extra` | Индекс `Properties`: редкие дополнительные/уточняющие свойства; запись 0 пуста |

Сигнатура хранится один раз в `Signatures`; тождественные строки не размножаются при разных исходных позициях или профилях. `Variants` сохраняет все различимые декларации и их условия. Неэкспортируемые macros, templates, callbacks, aliases, SQL forms и отсутствующие реализации остаются в каталоге, с собственным disposition. Они не становятся автоматически вызываемыми методами.

Логическая запись `Parameters` содержит `cName`, ссылку `cType`, flags, способ восстановления исходного declaration, override, общую модель и extra. Для flags пять младших битов означают наличие полей `pointer,array,callback,variadic,name_in_source`, следующие пять — значения этих полей. Declaration mode `0` означает точный C-type, `1` — C-type + пробел + имя, `2` — буквальный override. Обе исходные строки C-type и declaration восстанавливаются точно. `model` указывает на `C99Schema\\Models/mN` с тройкой LMX-type/converter/requirement. Тип `-1` означает исходный `null`, не индекс таблицы. `Origins.body` равен `-1`, когда исходное поле отсутствовало; иначе это 0/1. `conditionsPresent` отдельно сохраняет отсутствие поля и пустой список.

`Properties` сохраняет редкие поля без потерь. Каждая запись — последовательность пар `(keyIndex; valueIndex)` в справочники `PropertyKeys` и `PropertyValues`. Имена и повторяющиеся значения хранятся один раз. Значения имеют явные теги: `s` string, `i` integer, `b` boolean, `n` null, `f` float text, `l` list, `d` dictionary. Это вложенные LMX Structures, а не сериализованный JSON. Служебный `$omit` сохраняет отсутствие необязательного поля исходного census. Потребителю porting-плана обычно нужны именованные таблицы, а не эти provenance-поля. При восстановлении основного declaration с кодом `-1` берутся PRIMARY_KEYS записи, classification/header/targets из её profile, а исходный return type — из `return_type_original` после наложения extra; это сохраняет различие нормализованного типа и исходного объявления.

Семантические уточнения параметров тоже находятся в `extra`: например, `semantic_role`, `resource_kind` и `resource_backend` отличают owner-bound netCDF/PnetCDF `int ncid` от обычного целого. Исходная C-сигнатура остаётся неизменной. Callback typedef разрешается внутри своего компонента по `callback_type_refs`; совпадение имени typedef в другой библиотеке не изменяет модель аргумента.

В [package_plan.lmx](package_plan.lmx) правила имеют `component`, необязательные `namePattern` и `headerPattern`, новый `package` и `primaryModel`. Обе маски должны совпасть; применяется первое подходящее правило. Это позволяет распределить большие APR/SDL/gb API по смыслу без отдельных ручных записей на каждую функцию. Поле `headerPattern` использует исходный путь header из census, а не установленное include-имя.

В [schema.lmx](catalog/schema.lmx) структура `C99SourceCoverage` сохраняет все поверхности заголовков: компонент, путь относительно `sourceRoot`, targets, SHA-256, размер, количество исходных деклараций и function macros. `components` и `targets` — общие позиционные справочники, `Headers/hN` — группы по 32 строки с объявленными columns. Хеши относятся к закреплённому источнику; они не являются доказательством бинарной совместимости. Диагностика и ограничения census приведены в [отчёте покрытия](validation/expanded_api_coverage.json).

## Методы и C-переход

В [bindings/](bindings/) находятся реальные отдельные CODE-методы с собственным `c.*` вызовом. Для сложных ABI все методы компонента имеют одного настоящего DATA-родителя `C99Calls_<component>` с единственным `BridgeData\\CallRequest@: request`. Его `arguments` содержат позиционные значения конкретного API; структура, количество, C-типы, модели и все проверки берутся из конкретной строки Entries. Это общий переносимый договор запроса; он не делает произвольный массив C-аргументами без проверки.

Метод вызывает `BridgeLower\\open(request, componentCatalog, entry)`. Затем регистрируется `finally` с `BridgeLower\\release`, выполняется конкретный `c.lmx_bridge_<symbol>_<id>` и сохраняется результат через `finish`. Open/finish/release остаются явными [требованиями интеграции](bridge/lowering_contract.lmx); запрос не преобразуется в C-frame простым cast.

**Общие определения не копируются в арены акторов.** Пакеты, CODE и неизменяемые DATA с `independent: immutable:` используются через ссылки на существующие объекты. Bootstrap явно передаёт выбранные ссылки и сохраняет настоящий `parent(C)` и lifetime владельца; стоимость каталога не умножается на число акторов. Mutable invocation DATA, включая `request`, рабочие буферы и C contexts принадлежат конкретной активации/ресурсу. Учебный шаблон не вводит один изменяемый запрос для всех акторов. При порте используется штатный вызов с локальными аргументами; публикуемое определение остаётся общим. Полная опись и инструменты генерации — руководство интегратору, а не дублируемый runtime payload.

Простые scalar prototypes имеют отдельные DATA-контексты с точными аргументами и прямым `c.originalSymbol`. Они тоже помечены `NOT_RUN`; review поведения и прав остаётся обязательной частью порта. У отсутствующего определения `unimplemented_declaration_contract` генератор C-адаптера выдаёт только отказ и не содержит включаемой ветки вызова несуществующей реализации. Функции вне выбранного build profile не допускаются в direct scalar путь.

Научные HDF5/netCDF/PnetCDF backend используют `typed_scientific_resource_bridge` даже при внешне простой скалярной сигнатуре: живые identifiers и process-wide state не должны обходить owner/lifetime admission. `MPI_Comm`/`MPI_Info`/`MPI_Datatype` и `hid_t` получают точную ресурсную модель; `MPI_Offset` и размеры преобразуются с проверкой ширины.

## Один C-shim по запросу

Большой лес одинаковых C-файлов не хранится. Нужный per-symbol C99 scaffold восстанавливается **из канонического LMX**, без исходного большого JSON:

```sh
python3 tools/build_c_catalog.py --catalog-root . \\
  --emit-shim capi_EXACT_ID --shim-output /tmp/lmx_one.c
```

Команда запускается из `docs/core_catalog`. Вместо ID разрешено C-имя; при нескольких backend надо добавить `--component group:name`. Неоднозначность всегда вызывает ошибку. С `--component` генератор читает только нужный компонент и общую схему. Для полного ID без компонента сначала просматривается текст файлов, затем разбирается только найденный компонент. Поиск C-имени без компонента и полный экспорт могут потребовать значительно больше RAM; весь каталог не является runtime-данными акторов. В каталоге [c_shims/](c_shims/) оставлены только три репрезентативных примера. Для C-компиляции добавьте include directory `docs/core_catalog/bridge`; production target выбранной библиотеки поставляет её заголовки и compile definitions.

По умолчанию shim возвращает `REVIEW_REQUIRED`. Включаемая ветка требует точные per-parameter TYPE/READ, общий CHECK и SAVE. В ней стоит прямой вызов конкретного исходного ABI-символа. Строкового symbol dispatcher и догадок о struct/varargs нет. Для xxHash modern используется именованный canonical wrapper и реальный namespace; старый и новый заголовки остаются в разных C translation units.

## Проекции и проверка сохранности

`catalog_index.json` — маленький указатель на сжатую поисковую проекцию `catalog_index.json.gz`; `catalog_summary.json` содержит счётчики. Таблицы Markdown суммируют компоненты и пакеты. Они не копируют десятки тысяч объявлений. Полную JSON-проекцию можно создать локально:

```sh
python3 tools/build_c_catalog.py --catalog-root . --export-json /tmp/lmx-c-api.json
python3 tools/build_c_catalog.py --catalog-root . --regenerate-projections
```

Импортёр после записи заново читает LMX и сравнивает **каждый исходный JSON entry целиком**, включая signatures, параметры, все source positions, variants, notes, ABI rename и неизвестные дополнительные поля. Ошибка прекращает импорт. Это проверка сохранности данных. Отдельный `check_lmx_sources.py` проверяет лишь ограниченный синтаксический набор; C/LMX runtime acceptance в результате не повышается.

Если native composition уже проверена, импорт или регенерация проекций принимает явный `--native-verification ../c99_archive/VERIFICATION_2026-11-26.json` из этой директории. Число компонентов должно совпасть; проверенные `catalog.combined_*` consumers, статус CTest, ссылка и SHA-256 отчёта записываются в `whole_collection_link`. Без такого входа поле остаётся `NOT_RUN`. Даже с этим свидетельством `lmx_runtime` и отдельный `native_whole_archive_link` остаются `NOT_RUN`: проверка выбранных consumers не запускает язык и не включает принудительно каждый объект каждого архива.

Публикация выводится из Entries/Placements и [исключений коллизий](publication.lmx). [План пакетов](package_plan.lmx) определяет смысловые пути. Одинаковые имена не объединяют разные библиотеки: сначала используется `component__symbol`, затем при необходимости стабильный ID. Глубина смыслового пути не растёт от этих уточнений.
'''


def prepare_output(out, replace):
    for name, suffix in (("catalog", ".lmx"), ("bindings", ".lm3"), ("c_shims", ".c"), ("reference", ".md")):
        folder = out / name
        old = list(folder.glob("*")) if folder.exists() else []
        if old and not replace: raise SystemExit(str(folder) + " is not empty; use a new tree or --replace-generated")
        if replace:
            for path in old:
                if path.is_file() and path.suffix == suffix: path.unlink()
        folder.mkdir(parents=True, exist_ok=True)


def native_verification(args, out, component_count):
    """Attach explicit native evidence without changing LMX runtime status."""
    if not args.native_verification:
        return {}
    report = json.loads(args.native_verification.read_text())
    if report.get("components") != component_count:
        raise ValueError("Native verification component count does not match catalogue")
    combined = [c for c in report.get("ctest_cases", []) if c.get("name", "").startswith("catalog.combined_")]
    passed = report.get("build") == "PASS" and bool(combined) and all(c.get("result") == "PASS" for c in combined)
    return {"whole_collection_link": {
        "status": "PASS" if passed else "NOT_CONFIRMED",
        "scope": "Configured LMX::all native consumers; no --whole-archive image and no LMX runtime execution",
        "report": os.path.relpath(args.native_verification.resolve(), out),
        "sha256": hashlib.sha256(args.native_verification.read_bytes()).hexdigest(),
        "combined_consumers": combined,
        "ctest": report.get("ctest", {})
    }, "native_whole_archive_link": "NOT_RUN"}


def run_import(args):
    out = args.output.resolve(); prepare_output(out, args.replace_generated)
    plan, rules = load_plan(args.plan)
    inventory_bytes = args.inventory.read_bytes()
    inventory_sha256 = hashlib.sha256(inventory_bytes).hexdigest()
    data = json.loads(inventory_bytes)
    del inventory_bytes
    info = {c["id"]: c for c in data["components"]}
    missing = set(info) - set(plan)
    if missing: raise SystemExit("Missing plan components: " + repr(sorted(missing)))
    grouped = collections.defaultdict(list)
    for e in data["entries"]: grouped[e["component"]].append(e)
    models, components = Pool(), []
    for cid in sorted(info):
        component = Component(info[cid], models)
        for e in sorted(grouped[cid], key=lambda e: (e["name"], e["classification"], e["id"])):
            p = place(e, plan, rules)
            if len(p["package"].split("\\")) > 3: raise ValueError("Package deeper than three parents")
            component.add_entry(e, p)
        write(out / "catalog" / (component.ci + ".lmx"), component.text())
        write(out / "bindings" / (component.ci + ".lm3"), binding_text(component))
        components.append(component)
    schema = ["# Shared metadata models and policy; no runtime registration.", "C99Schema:",
              "    int: version 2", "    char[]: inventorySha256 " + q(inventory_sha256),
              "    char[]: sourceManifestSha256 " + q(data.get("source_manifest_sha256", "")),
              "    @: modelColumns (\"lmxType\"; \"converter\"; \"requirement\")",
              "    @: statuses " + native(tuple(STATUS)),
              "    char[]: publication \"proposal_only\"", "    char[]: runtimeAcceptance \"NOT_RUN\"",
              "    char[]: ownership \"review every argument/result; pin borrowed storage for full call interval\"",
              "    char[]: actorTransfer \"retain references to independent immutable definitions; mutable invocation data and native resources keep explicit owners\"",
              "    char[]: errors \"preserve native status then map explicitly\"", "    Models:"]
    schema += ["        @: m" + str(i) + " " + native(row) for i, row in enumerate(models.rows)]
    write(out / "catalog/schema.lmx", "\n".join(schema) + "\n" + source_coverage_text(data))
    write(out / "CATALOG_FORMAT.ru.md", FORMAT_RU)
    # Parse the delivered text, not in-memory tables, then compare full entries.
    reread, reread_models = read_catalog(out)
    if {c.cid: c.info for c in reread} != info: raise ValueError("Component metadata round-trip differs")
    if read_source_coverage(out) != data.get("header_coverage", []): raise ValueError("Header coverage round-trip differs")
    expected = {e["id"]: e for e in data["entries"]}
    reconstructed = {eid: c.decode_entry(eid, row)[0] for c in reread for eid, row in c.entries.items()}
    if set(expected) != set(reconstructed): raise ValueError("Round-trip entry identity set differs")
    errors = [eid for eid in expected if expected[eid] != reconstructed[eid]]
    if errors:
        eid = errors[0]
        differing = [k for k in set(expected[eid]) | set(reconstructed[eid]) if expected[eid].get(k) != reconstructed[eid].get(k)]
        raise ValueError("Lossless metadata comparison failed: " + eid + " keys=" + repr(differing))
    # Only small representative C scaffolds are retained; all others are recipes.
    for cid, symbol in (("base:zlib", "compress2"), ("acoustic:jansson", "json_loadb"), ("acoustic:liquid_dsp", "agc_crcf_create")):
        choices = [e for e in reconstructed.values() if e["component"] == cid and e["name"] == symbol and is_callable(e)]
        if len(choices) == 1:
            e = choices[0]
            write(out / "c_shims" / (ident(cid) + "_" + symbol + ".c"), '#include "lmx_catalog_bridge.h"\n' + emit_c(e))
    summary = projections(out, reread, {"metadata_roundtrip": "PASS_ALL_FIELDS_ALL_ENTRIES", "component_metadata_roundtrip": "PASS",
                                      "header_coverage_roundtrip": "PASS", "header_surfaces": len(data.get("header_coverage", [])),
                                      "source_inventory_sha256": inventory_sha256,
                                      **native_verification(args, out, len(reread))})
    sizes = summary["generated_bytes"]
    # The old fixed ten-megabyte documentation ceiling was tied to 132
    # components. Catalogue growth follows the accepted public API census;
    # report real bytes while retaining pooled types/signatures/metadata.
    # Runtime binary budgets do not apply to these offline porting documents.
    print(json.dumps({"components": len(reread), "entries": len(expected), "callables": summary["callable_candidates"],
                      "direct_scalar": summary["direct_scalar_prototypes"], "metadata_roundtrip": summary["metadata_roundtrip"], "bytes": sizes}, ensure_ascii=False))


def run_catalog_action(args):
    root = args.catalog_root.resolve()
    only_shim = args.emit_shim and not (args.export_json or args.regenerate_projections)
    entry_id = args.emit_shim if only_shim and re.fullmatch(r"capi_[A-Za-z0-9_]+", args.emit_shim) else None
    components, models = read_catalog(root, args.component if only_shim else None, entry_id)
    entries = [c.decode_entry(eid, row)[0] for c in components for eid, row in c.entries.items()]
    if args.emit_shim:
        choices = [e for e in entries if args.emit_shim in {e["id"], e["name"]} and (not args.component or e["component"] == args.component)]
        if len(choices) != 1:
            raise SystemExit("Select one exact entry: " + json.dumps([(e["component"], e["id"]) for e in choices], ensure_ascii=False))
        e = choices[0]
        if not is_callable(e) and e.get("ffi_disposition") != "unimplemented_declaration_contract":
            raise SystemExit("Metadata-only entry has no callable C shim: " + e["id"])
        code = '#include "lmx_catalog_bridge.h"\n' + emit_c(e)
        if args.shim_output: write(args.shim_output, code)
        else: sys.stdout.write(code)
    if args.export_json:
        write(args.export_json, json.dumps({"schema_version": 2, "scope": "Lossless entry projection from canonical LMX; no runtime proof", "components": [c.info for c in components], "header_coverage": read_source_coverage(root), "entries": entries}, ensure_ascii=False, separators=(",", ":")) + "\n")
        print("Exported " + str(len(entries)) + " entries to " + str(args.export_json))
    if args.regenerate_projections:
        summary = projections(root, components, {"metadata_roundtrip": "NOT_RECHECKED_FROM_INVENTORY",
                                                **native_verification(args, root, len(components))})
        print(json.dumps({"entries": summary["entries"], "callables": summary["callable_candidates"]}))


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--inventory", type=Path)
    ap.add_argument("--plan", type=Path)
    ap.add_argument("--output", type=Path)
    ap.add_argument("--replace-generated", action="store_true")
    ap.add_argument("--catalog-root", type=Path)
    ap.add_argument("--emit-shim", metavar="ID_OR_SYMBOL")
    ap.add_argument("--component")
    ap.add_argument("--shim-output", type=Path)
    ap.add_argument("--export-json", type=Path)
    ap.add_argument("--regenerate-projections", action="store_true")
    ap.add_argument("--native-verification", type=Path, help="explicit native composition verification report; does not claim LMX runtime acceptance")
    args = ap.parse_args()
    if args.catalog_root:
        if not (args.emit_shim or args.export_json or args.regenerate_projections): ap.error("Select a catalogue action")
        run_catalog_action(args)
    else:
        if not (args.inventory and args.plan and args.output): ap.error("Import requires --inventory --plan --output")
        run_import(args)
