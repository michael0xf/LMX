#!/usr/bin/env python3
"""Generate required semantic observations, never simulated LMX successes."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[1]
MODES=('interpreter_interpreter','interpreter_native','native_interpreter','native_native')

def main():
    cases=[]
    def add(group, scenario, expected):
        cases.append({'id':group+str(1+sum(c['id'].startswith(group) for c in cases)).zfill(3),
            'scenario':scenario,'expected':expected,'modes':{m:'NOT_RUN' for m in MODES}})
    for kind in ['int[]','long[]','float[]','double[]','char[]','@[] references','Structure mixed fields','Structure @[] holding Array references','empty dense Array','empty Structure','one element']:
        add('EQ', 'unique on '+kind, 'Stable first occurrences, fresh outer result with promised storage profile; input, typed element records and reference targets preserved')
    for scenario, expected in [
        ('same scalar/same Array/mixed Array versus scalar','Use ordinary scalar equality, recursive sequence equality, and false for the Array/scalar split'),
        ('explicit equivalence comparator','Comparator controls duplicates through the same stable scan; no second unique algorithm'),
        ('ordinary numeric equality across admitted numeric types','Use the existing equality result, with no extra type-code identity restriction'),
        ('NaN, signed zero and user references','Preserve existing ordinary equality semantics; no invented total equality or pointer policy'),
        ('referenced mixed Structures','Compare recursively with shared equalFields and keep surviving actual records; Structure is @[], not a separate nested-array storage kind'),
        ('uninitialised scalar element','Use the ordinary uninitialised-read contract; no fabricated ready value'),
        ('non-Array source','Ordinary Array admission rejects before traversal'),
        ('invalid/throwing comparator','Predicate/result admission and original declared failures remain visible'),
        ('source mutation during equality','Forbidden by the equivalence/stable-input contract, not silently supported'),
        ('memoize / membership / key / mismatch / search / grouping','All default equality users reach FxValueSame/FxSequenceDifference; explicit comparison remains optional')]:add('EQ',scenario,expected)
    for kind in ['int','long','float','double','char','char[]','dense Array','Structure','reference','callable','ready null reference','empty Array']:
        add('MON','some/ok/err/done capture '+kind,'Capture one whole admitted record before default @ admission; preserve actual type, referenced target and exact container result')
    for scenario,expected in [
        ('err with formal reason','The shared constructor adapter calls its sole input positionally, so reason is supplied correctly'),
        ('none / err bind chain','No skipped callback is run or read; preserve original inactive container'),
        ('Maybe, Result and Array under canonical bind','Select declared semantic family before input admission; never choose by fields or overload definition order'),
        ('half chain ordinary and operand forms','Identical left-to-right calls, values, effects and exact FxMaybe@ result'),
        ('Array bind empty/multiple outputs/type-changing outputs','One FxSeqBind traversal with flattening in order and exact @[] result'),
        ('Array bind callback returns non-Array','Reject by ordinary Array admission; do not wrap singleton silently'),
        ('bind empty right chain','Reject FxArity rather than return fabricated unit'),
        ('constructor uninit/type-only/void','Do not read uninit payload or invent a value for void; TYPE and VALUE routes remain separate'),
        ('constructor dynamic binding and mutable references','Ordinary parent/binding/lifetime behavior, one capture, no hidden environment'),
        ('bind callback declared failure','Finite target failures propagate with original name and typed payload')]:add('MON',scenario,expected)
    for kind in ['int[]','double[]','char[]','mixed Structure','Structure @[] holding Array references','empty typed Array']:
        add('PAT','ArrayView of '+kind,'One Pattern engine over actual units; literal/element/class/choice/repetition/capture preserve unit and slice profile')
    for scenario,expected in [
        ('utf8Text versus byteText','Keep explicit scalar/octet decoding, encoding checks and exact text slices'),
        ('literal multi-element Array versus element(Array value)','Literal matches a sequence; element matches one complete referenced Array value under ordinary reference rules'),
        ('within custom ordered type','Use selected order and type-preserving bound adapter; no char-only assumption'),
        ('satisfy and boundaryOf empty source','Validate real unary predicate signature before reading units; no fake integer probe'),
        ('then call and operand with text/Array sources','Same generic normalized Pattern composition and source domain'),
        ('sameAs capture','Shared range equality; full source position and capture context preserved'),
        ('matchedValue/captureValue/captureValues','Return values through actual source domain slice, with dense/mixed/text profiles retained'),
        ('replacement literal versus callable','Role selected before matching; callback receives Match and returns whole actual record; validate against source domain'),
        ('zero-width match repeated/split/replace','Progress policy prevents loops and retains one ordinary algorithm'),
        ('ASCII/line/boundary text profiles applied to Array','Admit explicit declared profile or reject; never guess text from fields or element values')]:add('PAT',scenario,expected)
    for scenario,expected in [
        ('-> inputs then final result token','Both forms construct identical full input/result requirements; void and nullary contracts preserved'),
        ('type(value) including uninitialised record','Observe the record type without reading payload'),
        ('pipe empty/type-changing/callable result','Empty R=T; exact final R, no fixed-@ public result, no invocation of a returned callable'),
        ('pipe invalid stage signature','Builder rejects non-unary or no-result stages before publishing; actual value admission occurs at reached call'),
        ('retry predicate/delay/limit','Original result type preserved; no policy on final attempt; delay only between retries; original errors stay errors'),
        ('join separator profiles','Generic explicit separator and text default share FxStdJoin; no separate text copying loop'),
        ('cycle negative policy','Default finite generic cycle and explicit rejectNegative retain separate requested policies through one loop'),
        ('trim/pad/translate/remove on nontext Array','Explicit members/predicate/fill/order are used; text defaults apply only to actual text profile'),
        ('range custom type','Explicit domain validates finite progress, step direction, actual output storage and endpoint rules'),
        ('format/parse selected codec','Codec selection determines exact types/errors; exact integer profile remains available'),
        ('quoted exact names and unary places','Canonical name only; ++var/var++/--var/var-- preserve before/after result and one assignable place'),
        ('RAW/FORM/PLACE/TYPE/void/control forms','Translator routes original role, owner, lifetime, effects and result; no eager VALUE adapter for non-VALUE forms')]:add('GEN',scenario,expected)
    for scenario, expected in [
        ('three service inputs and original user arity', 'The operand receives left/depth/right in that order; the wrapped ordinary source receives only logical arguments, including its own user field named depth when declared'),
        ('op, .op and .(expression)op', 'One base operation, depths 0/1/evaluated n; .(0) equals op; repeated leading dots are not depth syntax; .( always starts an operator/function depth modifier and is never a decimal point; Array indices and T[](N)/T@(N) type forms retain their own syntax'),
        ('effectful or unused depth expression', 'Ordinary P0/Expression semantics; evaluate once on the reached receiver demand, never while grouping or in a skipped RAW branch'),
        ('negative or non-int depth', 'Translator/interpreter profile-admission diagnostic before any leaf operation or destination write; no new LMX exception, coercion or truncation'),
        ('flat shape (2 2), depth 0/1/2 multiplication', {'inputs': {'A': {'shape': [2, 2], 'values': [1, 2, 3, 4]}, 'B': {'shape': [2, 2], 'values': [5, 6, 7, 8]}}, 'depth0': {'profile': 'matrix multiplication', 'shape': [2, 2], 'values': [19, 22, 43, 50]}, 'depth1': {'profile': 'corresponding row-vector dot products', 'shape': [2], 'values': [17, 53]}, 'depth2': {'profile': 'scalar componentwise products', 'shape': [2, 2], 'values': [5, 12, 21, 32]}, 'storage': 'One flat Array and logical dimension metadata; no allocated row Arrays or separate array-of-arrays kind'}),
        ('logical axes and original scalar fixed point', 'Each step consumes the next outer axis from the ordinary shape descriptor. Only original scalar actuals broadcast; incompatible selected dimensions or exhausted Array rank diagnose before a leaf or write. All-original-scalar inputs reach a fixed point without synthetic dimensions'),
        ('Structure @[] and explicit referenced indexing', 'struct[i] selects a reference; struct[i]\\[j] indexes its target under the ordinary reference and Array contracts. This does not introduce an array-of-arrays entity or an alternative definition of axis depth'),
        ('exact value result at runtime-selected depth', 'PD01 derives the complete actual result requirement from depth and admitted shape; never promise scalar R for an Array result or erase all public returns to @'),
        ('empty lifted Array and void source', 'Empty result type comes from the full contract without a probe call; void performs reached effects without Array<void> allocation'),
        ('whole TYPE/RAW/PLACE/Maybe/Pattern profile', 'Preserve the receiver role and declared depth policy; an unsupported positive depth is a translator/interpreter diagnostic, never a synthetic throw or an eager generic graph traversal'),
        ('prefix absence and empty right', 'Keep missing left distinct from a present value and from an empty right Array; do not move right[0] into left before the method'),
        ('native result ABI and dependent preparation', 'Do not reuse a scalar native return ABI for a lifted Array or implicitly compile; require the real dependent result/provider integration before claiming native execution')]:add('DEPTH', scenario, expected)
    catalog=json.loads((ROOT/'catalog.json').read_text())
    for row in catalog:
        for variant in row['variants']:
            add('FORM',row['name']+' / '+variant['family']+' ordinary versus operand',
                {'call':variant['call'],'operand':variant['operand'],'roles':variant['roles'],
                 'contract':variant['implementation_contract'],
                 'observation':'Same existing body/owner and actual result, evaluation order, accepted argument mapping, finite effects and short-circuit behavior'})
    result={'scope':'Required semantic acceptance after implementation of the documented publication hooks; no LMX runtime has been executed',
        'runtime_executed':False,'source_fixture':'generic_operations.lmx',
        'specifications':['../../../GENERIC_EQUALITY.md','../../../MONADIC_OPERATIONS.md','../../../GENERIC_OPERATIONS.md','../../../OPERATION_FORMS.md','../../../OPERATOR_DEPTH.en.md','../PUBLICATION_CONTRACT.md'],
        'canonical_operations':len(catalog),'canonical_variants':sum(len(x['variants']) for x in catalog),'cases':cases}
    (ROOT/'tests/generic_operations_acceptance.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'prepared_cases':len(cases),'canonical_variants':result['canonical_variants'],'runtime_executed':False}))

if __name__=='__main__':main()
