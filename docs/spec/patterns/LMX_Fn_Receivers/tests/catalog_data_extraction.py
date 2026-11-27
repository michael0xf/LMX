"""Build-time metadata checks; these do not execute or validate LMX programs."""
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from catalog_data import owner_data


class OwnerDataExtraction(unittest.TestCase):
    def test_method_code_is_not_owner_data(self):
        text = '''Owner:
    private:
        @: first
        int: count
    required: first count
    return: @
    before:
        throws: Failure
        private: int: local 0
        if: local = 0
            throw: Failure()
        return: first
    after:
        private:
            @: localRecord
        return: localRecord
'''
        data = owner_data(text)
        self.assertEqual(data['declared_inputs'], ['@: first', 'int: count'])
        self.assertEqual(data['required'], ['first count'])
        self.assertEqual(data['result_declaration'], '@')
        for forbidden in ('before:', 'after:', 'throws:', 'if:', 'throw:', 'local'):
            self.assertNotIn(forbidden, data['source_declaration'])

    def test_method_order_and_header_position_do_not_change_contract(self):
        a = '    first:\n        private: int: local 1\n        return: local\n'
        b = '    second:\n        throws: Failure\n        throw: Failure()\n'
        header = '    private: @: value\n    required: value\n    return: @\n'
        expected = owner_data('Owner:\n' + header + a + b)
        self.assertEqual(expected, owner_data('Owner:\n' + b + header + a))
        self.assertEqual(expected, owner_data('Owner:\n' + a + b + header))

    def test_only_data_modifiers_expose_inputs(self):
        data = owner_data('''Owner:
    private:
        @: value
        helper:
            private: int: hidden 1
            throws: Failure
            return: hidden
        const: int: READY 1
    const:
        int: PRIORITY 1
    Nested:
        int: notAnInput
    run:
        int: local 2
''')
        self.assertEqual(data['declared_inputs'], ['@: value'])
        self.assertNotIn('hidden', data['source_declaration'])
        self.assertNotIn('notAnInput', data['source_declaration'])
        self.assertNotIn('local', data['source_declaration'])

    def test_explicit_copy_sources_are_recorded_without_expansion(self):
        data = owner_data('''Owner:
    copy: Header
    copy(OtherHeader)
    private: copy: PrivateHeader
    run:
        copy: LocalBody
        private: copy(OtherLocal)
''')
        self.assertEqual(data['declared_inputs'], [])
        self.assertEqual(data['declaration_copies'],
                         ['copy: Header', 'copy(OtherHeader)', 'private: copy: PrivateHeader'])
        self.assertEqual(data['result_declaration'], 'inherited via declaration_copies')
        self.assertNotIn('Local', data['source_declaration'])

    def test_no_return_and_no_copy_is_void(self):
        self.assertEqual(owner_data('Owner:\n    run:\n        return\n')
                         ['result_declaration'], 'void')

    def test_real_catalogue_has_no_code_as_input(self):
        rows = json.loads((ROOT / 'catalog.json').read_text())
        expected = {
            r'RxRepeatOperands\optional': ['@: left', 'int: depth', '[]@: right'],
            r'FxStdCut\drop': ['@: items', 'int: count'],
            r'FxTextTrim\trimEnd': ['[]char: text', '[]char: chars " \\t\\r\\n\\v\\f"',
                                     '@: predicate 0', '@: same 0'],
        }
        seen = set()
        for row in rows:
            for variant in row['variants']:
                api = variant['api']
                declared = variant['implementation_contract']['declared_inputs']
                for value in declared:
                    self.assertNotRegex(value, r'^(?:throws|if|throw|return|while):')
                if api in expected:
                    self.assertEqual(declared, expected[api])
                    seen.add(api)
        self.assertEqual(seen, set(expected))


if __name__ == '__main__':
    unittest.main()
