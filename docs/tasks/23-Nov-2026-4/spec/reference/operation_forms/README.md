# Operation-form translator reference

This executable reference consumes views of the already parsed graph. The parser already accepts receivers in Expression; canonical names and their exact-identifier rules remain at the existing base level.

The [operation-form specification](../../OPERATION_FORMS.md) defines the shared receiver/operand contract, original-context handling and the one-argument `++var`, `var++`, `--var`, `var--` variants. This directory contains its reference implementation and checks. It does not replace the production translator or introduce a new P0 node format.

Run from this directory:

```sh
python3 -m unittest -v test_translator_reference.py
```

The checks exercise the model only. LMX parser, runtime and native integration are separate acceptance stages; a passing Python check does not establish them.
