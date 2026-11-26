#!/usr/bin/env python3
"""Classify each actual COMMON-LISP external symbol; never infer runtime PASS."""
from collections import Counter
from pathlib import Path
import csv
import io
import json
import re

ROOT = Path(__file__).resolve().parents[1]
SOURCE = 'https://www.lispworks.com/documentation/HyperSpec/Body/01_i.htm'
INDEX = 'https://www.lispworks.com/documentation/HyperSpec/Front/Contents.htm'
inventory = json.loads((ROOT / 'validation/common_lisp_symbols.json').read_text())
symbols = {row['symbol'] for row in inventory['symbols']}
decisions = {}


def assign(names, family, decision, target, note):
    for name in names.split():
        if name not in symbols:
            raise ValueError('Misspelled/nonstandard symbol: ' + name)
        decisions[name] = dict(family=family, decision=decision, lmx=target,
                               qualification=note)


def matching(pattern, family, decision, target, note):
    names = sorted(n for n in symbols if re.search(pattern, n))
    assign(' '.join(names), family, decision, target, note)


matching(r'^&|^LAMBDA-(?:LIST-KEYWORDS|PARAMETERS-LIMIT)$|^CALL-ARGUMENTS-LIMIT$|^MULTIPLE-VALUES-LIMIT$',
         'argument syntax and limits', 'native_or_metadata',
         'ordinary DATA formals, named actuals, defaults, required; finite runtime resources',
         'These are syntax markers or implementation limits, not separate executable conveniences; CL &rest/&key details are not silently imposed on LMX.')
matching(r'^\*|^\+\+|^//|^-$|^OTHERWISE$|^STANDARD$|^VARIABLE$',
         'environment variables and markers', 'profile_or_metadata',
         'ordinary explicit/dynamic owner fields and selected host profile',
         'A CL dynamic configuration variable or REPL/history marker is not an LMX function; task-specific policy can be an ordinary owner field. Exact CL global state is not emulated.')
matching(r'PACKAGE|^INTERN$|^UNINTERN$|^EXPORT$|^UNEXPORT$|^IMPORT$|^SHADOW$|^SHADOWING-IMPORT$|^GENSYM$|^GENTEMP$|SYMBOL|^KEYWORD|^GET$|^SET$|^REMPROP$|^BOUNDP$|^FBOUNDP$|^FDEFINITION$|^FMAKUNBOUND$|^MAKUNBOUND$',
         'symbols and namespaces', 'dialect_gap',
         'names / sys\\name / import / ordinary graph paths; explicit symbol provider only for CL compatibility',
         'LMX names and imports solve ordinary naming, but CL interned-symbol identity, package tables and symbol value/function/plist cells are not claimed. See TZ gap L02.')
matching(r'READTABLE|MACRO-CHARACTER|DISPATCH-MACRO|^SET-SYNTAX-FROM-CHAR$|^READ$|^READ-FROM-STRING$|^READ-DELIMITED-LIST$|^READ-PRESERVING-WHITESPACE$|^READER-ERROR$',
         'reader and readtables', 'dialect_gap',
         'existing P0 / fromLmx / ordinary raw Expression receiver',
         'Custom operation notation uses the single LMX operand template. A CL readtable with reader macros or exact Lisp datum syntax would need a separate compatibility contract, not a new LMX parser mode. L03.')
matching(r'CLASS|METHOD|GENERIC-FUNCTION|INSTANCE|^SLOT-|^WITH-SLOTS$|^WITH-ACCESSORS$|^STANDARD-OBJECT$|^STRUCTURE-(?:CLASS|OBJECT)$|^BUILT-IN-CLASS$',
         'CLOS and object protocol', 'native_with_gap',
         'ordinary Structure methods / full structural requirements / copy / merge / graph-field access',
         'Ordinary object tasks use native Structures. Full CLOS multiple dispatch, method combination, class redefinition and the MOP are not equated with a single LMX method call. L04.')
matching(r'RESTART|^ABORT$|^CONTINUE$|^USE-VALUE$|^STORE-VALUE$|^MUFFLE-WARNING$|^CERROR$|^HANDLER-BIND$|^SIGNAL$|^WITH-CONDITION-RESTARTS$',
         'resumable conditions', 'dialect_gap',
         'ordinary callbacks / explicit continuation protocols / throw-catch-finally',
         'Named nonlocal exits are available. Stack-resuming CL restarts and non-unwinding handler search require an explicit contract/provider if that exact feature is requested; no fake restart wrapper. L05.')
matching(r'CONDITION|ERROR|WARNING|^WARN$|^ASSERT$|^CHECK-TYPE$',
         'conditions and diagnostics', 'native_with_gap',
         'throws / throw / catch / sys\\assert / ordinary typed payload',
         'Concrete named failures map directly on the stated task. CL condition inheritance and restart behavior do not follow from this mapping.')
matching(r'PATHNAME|NAMESTRING|^DIRECTORY$|^TRUENAME$|^PROBE-FILE$|^DELETE-FILE$|^RENAME-FILE$|^ENSURE-DIRECTORIES-EXIST$|^FILE-',
         'filesystem and paths', 'provider_gap',
         'ordinary host/provider functions through the C/host boundary',
         'Path parsing, OS effects, filesystem metadata and CL logical-pathname translations require a concrete host profile. This archive supplies no fabricated filesystem implementation. L07.')
matching(r'STREAM|^OPEN$|^CLOSE$|^LISTEN$|^READ-(?:BYTE|CHAR|CHAR-NO-HANG|LINE|SEQUENCE)$|^WRITE-(?:BYTE|CHAR|LINE|SEQUENCE|STRING)$|^PEEK-CHAR$|^UNREAD-CHAR$|^(?:CLEAR|FINISH|FORCE)-(?:INPUT|OUTPUT)$',
         'streams and I/O', 'provider_gap',
         'ordinary resource values / finally or bracket / host I/O provider',
         'Resource control is available; actual stream I/O, buffering, encoding, interactive behavior and Gray-style extension need provider contracts. L07.')
matching(r'PPRINT|^PRINT|^PRIN[1C]$|^PRIN[1C]-TO-STRING$|^FORMAT$|^FORMATTER$|^TERPRI$|^FRESH-LINE$|^WRITE$|^WRITE-TO-STRING$',
         'printing and FORMAT', 'provider_or_library_gap',
         'toLmx / format / limited positional format / explicit text operations',
         'These shorten serialization/display tasks, but full CL FORMAT directives, pretty-printer dispatch and readably round-tripping arbitrary Lisp objects are not implemented by positional format. L06.')
matching(r'TIME|^SLEEP$|^RANDOM|^MAKE-RANDOM-STATE$|^MACHINE-|^SOFTWARE-|^LISP-IMPLEMENTATION-|^SHORT-SITE-NAME$|^LONG-SITE-NAME$',
         'time randomness and host identity', 'provider_gap',
         'selected host clock, wait, randomness and metadata provider',
         'A concrete clock unit, timezone/calendar, entropy/state and host contract is required; no implicit busy wait, unsafe RNG or fabricated metadata. L08.')
matching(r'HASH|^SXHASH$',
         'hash tables', 'provider_or_library_gap',
         'assoc / explicit same callback / memoize; hash provider when complexity is required',
         'Linear association/memo lookup covers finite tasks without pretending O(1) hashing. General hashing consistent with equality, weak keys, mutation and identity needs its own contract. L09.')
matching(r'^ARRAY|^ADJUST|^MAKE-ARRAY$|^AREF$|^ROW-MAJOR-AREF$|^SVREF$|^VECTOR|^SIMPLE-(?:ARRAY|VECTOR|BIT-VECTOR)|^BIT-VECTOR|^SBIT$|^FILL-POINTER$|^UPGRADED-ARRAY-ELEMENT-TYPE$',
         'arrays and storage', 'native_with_gap',
         '[]T / ordinary indexing / length / resize / reserve / slice / append / insertAt / deleteAt',
         'LMX Arrays have an existing typed storage/capacity contract. CL displaced arrays, fill-pointer behavior and exact rank/layout reflection are not silently aliases of one-dimensional sequence helpers.')
matching(r'^BIT(?:-|$)|^BOOLE|^LOG(?:AND|IOR|XOR|NOT|EQV|NAND|NOR|ORC|TEST|BITP|COUNT)|^ASH$|^BYTE(?:-|$)|^LDB|^DPB$|^DEPOSIT-FIELD$|^MASK-FIELD$|^INTEGER-LENGTH$',
         'integer and bit operations', 'native_or_composition',
         'ordinary &, |, ^, ~, shifts and numeric context; explicit masks/counting when needed',
         'Boolean bit formulas compose native operators. Arbitrary-size two-complement field rules and optimized bit-count providers must match the selected integer profile; no claim that machine int equals CL bignum.')
matching(r'^LEAST-|^MOST-|FLOAT|^FIXNUM$|^BIGNUM$|^INTEGERP?$|^RATIO$|^RATIONAL|^REAL|^NUMBER|^COMPLEX|^SIGNED-BYTE$|^UNSIGNED-BYTE$|^PI$|^DENOMINATOR$|^NUMERATOR$|^UPGRADED-COMPLEX-PART-TYPE$|^(?:GCD|LCM|MIN|MAX|SIGNUM|PARSE-INTEGER)$',
         'numeric families and profiles', 'native_with_gap',
         'LMX int / bigint / rational / complex and ordinary complete type contracts',
         'Existing numeric families solve the task; exact CL format limits, float decomposition, rounding and conversion profiles need explicit implementation evidence. L10 tracks missing profile operations.')
matching(r'^CHAR|^BASE-CHAR$|^BASE-STRING$|^STANDARD-CHAR|^EXTENDED-CHAR$|^ALPHA-CHAR-P$|^ALPHANUMERICP$|^BOTH-CASE-P$|^GRAPHIC-CHAR-P$|^UPPER-CASE-P$|^LOWER-CASE-P$|^DIGIT-CHAR|^CODE-CHAR$|^NAME-CHAR$',
         'characters and Unicode', 'profile_or_library_gap',
         '[]char / utf8Text / byteText / explicit codepoint profile',
         'Byte and Unicode scalar profiles are distinct. Complete Unicode properties and contextual case conversion require versioned tables; ASCII mapping is not advertised as Unicode. L11.')
assign('STRING STRINGP STRING-CAPITALIZE STRING-DOWNCASE STRING-UPCASE NSTRING-CAPITALIZE NSTRING-DOWNCASE NSTRING-UPCASE STRING-EQUAL STRING-GREATERP STRING-LESSP STRING-NOT-EQUAL STRING-NOT-GREATERP STRING-NOT-LESSP STRING-LEFT-TRIM STRING-RIGHT-TRIM STRING-TRIM STRING/= STRING< STRING<= STRING= STRING> STRING>= SIMPLE-BASE-STRING SIMPLE-STRING SIMPLE-STRING-P BASE-STRING MAKE-STRING SCHAR',
         'text operations', 'core_with_limits',
         'equalFields / compare / trim / trimStart / trimEnd / replaceText / splitText / join / text profiles',
         'Content/trim operations use documented text profiles; CL string designators, destructive NSTRING case operations and locale/Unicode case rules are not universally covered. L11.')
matching(r'^(?:ACOS|ACOSH|ASIN|ASINH|ATAN|ATANH|COS|COSH|SIN|SINH|TAN|TANH|EXP|LOG|SQRT|ISQRT|CIS|CONJUGATE|PHASE|IMAGPART|REALPART|CEILING|FCEILING|FLOOR|FFLOOR|ROUND|FROUND|TRUNCATE|FTRUNCATE|SCALE-FLOAT|DECODE-FLOAT|INTEGER-DECODE-FLOAT)$',
         'mathematical functions', 'provider_or_library_gap',
         'selected numeric context and explicitly implemented math provider',
         'The language has scalar arithmetic and numeric families; this inventory does not invent complete transcendental, rounding/remainder or float-decomposition bodies. L10.')
matching(r'^C[AD]{1,4}R$|^CONS$|^CONSP$|^ATOM$|^LIST(?:P|\*|-LENGTH)?$|^NULL$|^NIL$|^ENDP$|^RPLAC|^TAILP$|^LDIFF$|^NTHCDR$|^REST$|^COPY-(?:ALIST|LIST|TREE)$|^TREE-EQUAL$|^SUBLIS$|^NSUBLIS$|^N?SUBST(?:-IF(?:-NOT)?)?$',
         'lists trees and cons identity', 'native_with_gap',
         'ordinary Array/Structure / index paths / copy / concat / slice / full typed references',
         'Finite sequence/tree tasks use LMX graphs. Cons-tail sharing, dotted/circular lists, recursive tree replacement and equality require the stated shape/identity contract; deep copy is not shallow copy-list. L12.')
matching(r'^(?:FIRST|SECOND|THIRD|FOURTH|FIFTH|SIXTH|SEVENTH|EIGHTH|NINTH|TENTH|NTH|ELT|LENGTH|BUTLAST|NBUTLAST|LAST|MAKE-LIST|MAKE-SEQUENCE|SEQUENCE|COPY-SEQ|COPY-STRUCTURE|APPEND|NCONC|REVAPPEND|NRECONC|REVERSE|NREVERSE|CONCATENATE|REPLACE|FILL|MAP|MAP-INTO|MAPC|MAPCAR|MAPCAN|MAPL|MAPLIST|MAPCON|REDUCE|SORT|STABLE-SORT|MERGE|SUBSEQ|REMOVE|REMOVE-IF|REMOVE-IF-NOT|DELETE|DELETE-IF|DELETE-IF-NOT|REMOVE-DUPLICATES|DELETE-DUPLICATES|SUBSTITUTE|SUBSTITUTE-IF|SUBSTITUTE-IF-NOT|NSUBSTITUTE|NSUBSTITUTE-IF|NSUBSTITUTE-IF-NOT|FIND|FIND-IF|FIND-IF-NOT|POSITION|POSITION-IF|POSITION-IF-NOT|COUNT|COUNT-IF|COUNT-IF-NOT|EVERY|SOME|NOTANY|NOTEVERY|SEARCH|MISMATCH)$',
         'sequences and traversal', 'core_with_limits',
         'map / filter / foldl / foldr / index / any / all / count / slice / concat / zip / sort / unique / replaceRange / searchSequence / mismatch / substitute',
         'The relevant reusable operation exists or composes from it. Full CL keyword matrix, :key/:count/:from-end and destructive cons-tail behavior are separate qualifications; match exact result/storage/effects before substitution.')
matching(r'^(?:MEMBER|MEMBER-IF|MEMBER-IF-NOT|ADJOIN|PUSHNEW|UNION|NUNION|INTERSECTION|NINTERSECTION|SET-DIFFERENCE|NSET-DIFFERENCE|SET-EXCLUSIVE-OR|NSET-EXCLUSIVE-OR|SUBSETP)$',
         'sets and membership', 'core_with_limits',
         'includes / adjoin / union / intersection / difference / symmetricDifference / isSubset / index',
         'Explicit equality and stable Array order are the LMX contract. CL MEMBER cons-tail results and destructive N* permissions are not copied into these names.')
matching(r'^(?:ASSOC|ASSOC-IF|ASSOC-IF-NOT|RASSOC|RASSOC-IF|RASSOC-IF-NOT|ACONS|PAIRLIS|GETF|GET-PROPERTIES|REMF)$',
         'association and property lists', 'added_core',
         'assoc / pairlis / getProperty / setProperty / removeProperty / getProperties',
         'One key search and generic mutation, explicit equality; assoc keyIndex=1 handles reverse lookup. Arrays/plist indices replace conses/tails. Predicate-only variants compose predicate selection; exact APIs in CORE_STANDARD_LISP.md.')
matching(r'^(?:APPLY|FUNCALL|FUNCTION|FUNCTIONP|COMPLEMENT|CONSTANTLY|IDENTITY|LAMBDA|DEFUN|FLET|LABELS|FUNCTION-LAMBDA-EXPRESSION|FUNCTION-KEYWORDS)$',
         'functions and closures', 'native_or_core',
         'ordinary callable / apply / partial / curry / compose / identity / signature / copy and explicit saved DATA',
         'Callable values and dynamic binding are native. Captured values have explicit ownership; copying never captures an expired activation implicitly. Reflection has its own source/provider boundary.')
matching(r'^(?:MULTIPLE-VALUE-BIND|MULTIPLE-VALUE-CALL|MULTIPLE-VALUE-LIST|MULTIPLE-VALUE-PROG1|MULTIPLE-VALUE-SETQ|VALUES|VALUES-LIST|NTH-VALUE|DESTRUCTURING-BIND)$',
         'multiple values and destructuring', 'native_composition',
         'ordinary structured return / positional destructuring / explicit copy field stream / apply',
         'LMX returns one ordinary value whose fields represent results; explicit consumers select/unpack it. This solves the task without pretending CL multiple-value arity/truncation semantics exist implicitly. L01.')
matching(r'^(?:IF|WHEN|UNLESS|COND|CASE|ECASE|CCASE|TYPECASE|ETYPECASE|CTYPECASE|AND|OR|NOT|LET|LET\*|SETQ|PSETQ|SETF|PSETF|SHIFTF|ROTATEF|INCF|DECF|PUSH|POP|PROGN|PROG1|PROG2|PROG|PROG\*|BLOCK|RETURN|RETURN-FROM|GO|TAGBODY|DO|DO\*|DOLIST|DOTIMES|LOOP|LOOP-FINISH|CATCH|THROW|UNWIND-PROTECT|HANDLER-CASE|IGNORE-ERRORS|PROGV|SPECIAL|DEFVAR|DEFPARAMETER|DEFCONSTANT)$',
         'control binding and places', 'native_or_composition',
         'if / else / while / break / return / := / compound assignment / throw-catch-finally / ordinary dynamic binding',
         'Use the existing receiver/Expression and typed place contract. CL generalized SETF macros, catch tag identity and restarts need their exact task qualification; no lexical-visibility restriction is added to dynamic names.')
matching(r'^(?:QUOTE|EVAL|DEFMACRO|MACROLET|MACROEXPAND|MACROEXPAND-1|MACRO-FUNCTION|DEFINE-COMPILER-MACRO|COMPILER-MACRO|COMPILER-MACRO-FUNCTION|DEFINE-MODIFY-MACRO|DEFINE-SETF-EXPANDER|DEFINE-SYMBOL-MACRO|DEFSETF|GET-SETF-EXPANSION|SYMBOL-MACROLET)$',
         'source transformation', 'native_with_gap',
         'ordinary raw receiver / sys\\eval / fromLmx / graph manipulation / asOperand',
         'Prepared callable adaptation does not implement arbitrary macroexpansion. Original occurrences retain their source context; raw evaluation and lexical macro environments keep separate contracts. L03.')
matching(r'^(?:TYPE|TYPEP|TYPE-OF|SUBTYPEP|DEFTYPE|THE|COERCE|SATISFIES|BOOLEAN|T|STRUCTURE|DEFSTRUCT|CONSTANTP|EQ|EQL|EQUAL|EQUALP)$',
         'types equality and structures', 'native_with_limits',
         'complete requirement / satisfies / sys\\typeof / ordinary Structure / explicit same callback',
         'Full LMX types and identity are native. Four CL equality predicates differ; choose an explicit comparator and do not replace deep/case/numeric equality indiscriminately.')
matching(r'^(?:COMPILE|COMPILE-FILE|COMPILE-FILE-PATHNAME|COMPILED-FUNCTION|COMPILED-FUNCTION-P|COMPILATION-SPEED|EVAL-WHEN|LOAD-TIME-VALUE|DECLAIM|DECLARE|DECLARATION|PROCLAIM|DYNAMIC-EXTENT|INLINE|NOTINLINE|FTYPE|IGNORE|IGNORABLE|OPTIMIZE|DEBUG|SAFETY|SPEED|SPACE|LOCALLY|WITH-COMPILATION-UNIT|MAKE-LOAD-FORM|MAKE-LOAD-FORM-SAVING-SLOTS|LOAD|PROVIDE|REQUIRE)$',
         'compilation and system construction', 'profile_or_metadata',
         'ordinary source/native profiles / explicit compilation / import / build tooling',
         'Compiler policy and load-time phases belong to the implementation/toolchain; no automatic recompilation or foreign ABI reuse is introduced as a source shortcut. L13.')
matching(r'^(?:APROPOS|APROPOS-LIST|DESCRIBE|DESCRIBE-OBJECT|DOCUMENTATION|DISASSEMBLE|DRIBBLE|ED|INSPECT|INVOKE-DEBUGGER|BREAK|ROOM|STEP|TRACE|UNTRACE|Y-OR-N-P|YES-OR-NO-P)$',
         'interactive tools and debugging', 'profile_or_metadata',
         'LMX observation/debugging contract and explicit host tooling',
         'Interactive UI/debugger facilities are not algorithmic aliases. Runtime state inspection and stepping need real executor support; no transcript or inferred state is presented as execution. L13.')

# Exact small expressions / concrete public mappings override broad families.
assign('+ - * / /= < <= = > >= 1+ 1- INCF DECF EXPT MOD REM ZEROP PLUSP MINUSP EVENP ODDP ABS',
       'scalar arithmetic', 'native_or_composition',
       'ordinary + - * / != < <= = > >= ** % and explicit numeric context',
       'Use the native operation on the agreed numeric domain. CL MOD vs REM signs, division exactness, unary/variadic arity and overflow profiles must match; they are not silently identical.')
for names, target in [
    ('GCD','gcd'), ('LCM','lcm'), ('MIN','min / minimum'), ('MAX','max / maximum'),
    ('SIGNUM','sign'), ('PARSE-INTEGER','parse'),
    ('STRING=','equalFields'), ('STRING< STRING> STRING<= STRING>= STRING/=','compare'),
    ('STRING-TRIM','trim'), ('STRING-LEFT-TRIM','trimStart'), ('STRING-RIGHT-TRIM','trimEnd'),
    ('ASSOC RASSOC','assoc'), ('PAIRLIS','pairlis'), ('GETF','getProperty / setProperty'),
    ('REMF','removeProperty'), ('GET-PROPERTIES','getProperties'),
    ('SEARCH','searchSequence'), ('MISMATCH','mismatch'), ('SUBSTITUTE','substitute'),
    ('APPLY','apply'), ('REDUCE','foldl / foldr'), ('MAP MAPCAR','map'),
    ('FIND-IF','findFirst'), ('POSITION-IF','index'), ('COUNT-IF','count'),
    ('EVERY','all'), ('SOME','any'), ('REMOVE-IF-NOT','filter'),
    ('SORT STABLE-SORT','sort'), ('REMOVE-DUPLICATES','unique'),
    ('SUBSEQ','slice'), ('CONCATENATE APPEND','concat'), ('REPLACE','replaceRange'),
    ('REVERSE','reverse'), ('INTERSECTION NINTERSECTION','intersection'),
    ('UNION NUNION','union'), ('SET-DIFFERENCE NSET-DIFFERENCE','difference'),
    ('SET-EXCLUSIVE-OR NSET-EXCLUSIVE-OR','symmetricDifference'), ('SUBSETP','isSubset'),
    ('ADJOIN','adjoin'), ('MEMBER','includes / index')]:
    for name in names.split():
        base = decisions[name]
        decisions[name] = {**base, 'decision': 'core_with_limits', 'lmx': target,
                           'qualification': 'Concrete reusable core operation; use its documented LMX contract. ' + base['qualification']}

# Case/character properties remain real integration gaps despite broad text helpers.
matching(r'(?:UPCASE|DOWNCASE|CAPITALIZE)$|^(?:STRING-EQUAL|STRING-LESSP|STRING-GREATERP|STRING-NOT-EQUAL|STRING-NOT-LESSP|STRING-NOT-GREATERP)$',
         'Unicode case and case-insensitive text', 'provider_or_library_gap',
         'versioned Unicode property/case tables and explicit text profile',
         'Case folding, expansions, titlecase and contextual rules are not supplied by byte-wise equalFields/compare or positional format. L11.')

assign('DEFGENERIC SHARED-INITIALIZE UNBOUND-SLOT', 'CLOS and object protocol',
       'native_with_gap', 'ordinary Structure methods and named failure payloads',
       'Structural methods cover the object task; full generic dispatch, slot lifecycle and CL condition class identity remain explicit compatibility gaps. L04.')
assign('DIVISION-BY-ZERO END-OF-FILE UNBOUND-VARIABLE UNDEFINED-FUNCTION',
       'conditions and diagnostics', 'native_with_gap', 'ordinary runtime diagnostics / declared provider failures',
       'Use the actual arithmetic, binding or I/O contract; these CL condition classes are not fabricated as universal LMX catchable outcomes.')
assign('SPECIAL-OPERATOR-P', 'reflection of evaluation', 'profile_or_metadata',
       'ordinary receiver/operand structural discovery and signature inspection',
       'CL special-operator classification is not a new LMX callable kind; inspect the existing structural contract instead.')
assign('WITH-INPUT-FROM-STRING WITH-OUTPUT-TO-STRING WITH-OPEN-FILE WITH-STANDARD-IO-SYNTAX',
       'streams and I/O', 'provider_gap', 'ordinary text/resource state and finally / bracket / host I/O profile',
       'Control scaffolding is reusable; exact CL stream/syntax state still needs a provider. No claim that a string Array alone implements every stream operation. L07.')

assign('MERGE', 'sorted sequence merge', 'native_composition',
       'stable sort of concat for the admitted comparator and result profile',
       'This is not LMX graph merge. Composition can solve finite sorted-output tasks, with O(n log n) rather than a promised linear sorted merge; key effects and stability need their stated contract.')
decisions['SOME']['qualification'] += ' CL SOME returns the first non-NIL predicate value; LMX any returns int 0/1. Preserve that distinction; S05 explicitly normalizes it.'
decisions['REMOVE-DUPLICATES']['qualification'] += ' CL default duplicate retention differs from first-occurrence unique; select the matching :from-end profile, as in S08.'


def main():
    missing = sorted(symbols - decisions.keys())
    if missing:
        print('Unclassified:', ' '.join(missing))
        raise SystemExit(1)
    rows = [{**r, **decisions[r['symbol']], 'reviewed_for_shortening': True,
             'cl_source': SOURCE,
             'lmx_source': '../../../LMX_semantics.en.md',
             'lmx_runtime': 'NOT_RUN'} for r in inventory['symbols']]
    summary = Counter(r['decision'] for r in rows)
    result = {'inventory_source': 'validation/common_lisp_symbols.json',
              'inventory_method': 'Actual do-external-symbols on COMMON-LISP; values and function bodies not evaluated.',
              'scope': 'All 978 external COMMON-LISP symbols; SBCL extensions separately by capability family.',
              'classification': 'Every row reviewed for a source shortcut; coverage is not semantic/runtime equivalence.',
              'counts': dict(sorted(summary.items())), 'total': len(rows), 'symbols': rows}
    (ROOT / 'COMMON_LISP_COVERAGE.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    out=io.StringIO(newline='');fields=['symbol','family','decision','lmx','qualification','lmx_runtime','cl_source','lmx_source']
    writer=csv.DictWriter(out,fieldnames=fields,extrasaction='ignore');writer.writeheader();writer.writerows(rows)
    (ROOT / 'COMMON_LISP_COVERAGE.csv').write_text(out.getvalue())
    detail=['# Поимённый аудит COMMON-LISP','',
            'Источник списка — фактически запущенный SBCL `do-external-symbols`; 978 внешних символов. '+
            'Один символ может иметь несколько ролей. Отнесение к группе не объявляет все его варианты '+
            'тождественными LMX; ограничения даны в каждой строке. Исполнение LMX: **NOT_RUN**.','',
            '[Методика и выводы](COMMON_LISP_COVERAGE.md) · [JSON](COMMON_LISP_COVERAGE.json) · [CSV](COMMON_LISP_COVERAGE.csv)','',
            '| Символ | Семейство | Решение | LMX / ограничение |','| --- | --- | --- | --- |']
    for r in rows:
        text=(r['lmx']+' — '+r['qualification']).replace('|','\\|')
        detail.append(f"| `{r['symbol']}` | {r['family']} | `{r['decision']}` | {text} |")
    (ROOT / 'COMMON_LISP_SYMBOLS.md').write_text('\n'.join(detail)+'\n')
    print(json.dumps({'symbols':len(rows),'decisions':dict(summary)},ensure_ascii=False))


if __name__=='__main__':
    main()
