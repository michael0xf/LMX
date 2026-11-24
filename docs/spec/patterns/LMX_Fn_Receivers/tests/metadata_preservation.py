"""Small preservation fixtures for build-time metadata, not LMX execution."""
import copy
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from sync_metadata import fill_missing_descriptions, select_variant


class MetadataPreservation(unittest.TestCase):
    def setUp(self):
        self.row = {
            'name': 'bind', 'signature': 'bind(input; next)',
            'scope': 'Maybe payload only',
            'variants': [
                {'family': 'Maybe', 'api': r'FxBind\bind'},
                {'family': 'Result', 'api': r'FxBindResult\bind'},
                {'family': 'Array', 'api': r'FxListBind\bind',
                 'arguments': 'items; next', 'scope': 'Ordered Array flattening'},
            ],
        }

    def test_authored_multifamily_text_and_other_fields_survive(self):
        entry = {'name': 'bind', 'api': r'FxBindResult\bind', 'family': 'Result',
                 'scope': 'Автор: Result, с сохранением исходной ошибки.  ',
                 'arguments': 'result; continuation\n',
                 'contracts': {'important': ['authored', 'values']}}
        before = copy.deepcopy(entry)
        variant = select_variant(entry, self.row, 'bind')
        self.assertEqual(variant['family'], 'Result')
        fill_missing_descriptions(entry, self.row, variant, 'bind')
        fill_missing_descriptions(entry, self.row, variant, 'bind')
        self.assertEqual(entry, before)
        self.assertEqual(entry['scope'].encode(), before['scope'].encode())
        self.assertEqual(entry['arguments'].encode(), before['arguments'].encode())

    def test_missing_fields_use_selected_family_or_explicit_reference(self):
        array = {'name': 'bind', 'family': 'Array'}
        variant = select_variant(array, self.row, 'bind')
        fill_missing_descriptions(array, self.row, variant, 'bind')
        self.assertEqual(array['arguments'], 'items; next')
        self.assertEqual(array['scope'], 'Ordered Array flattening')
        result = {'name': 'bind', 'family': 'Result'}
        variant = select_variant(result, self.row, 'bind')
        fill_missing_descriptions(result, self.row, variant, 'bind')
        self.assertIn(r'FxBindResult\bind', result['scope'])
        self.assertNotIn('Maybe', result['scope'])
        self.assertIn('implementation_contract', result['arguments'])
        before = copy.deepcopy(result)
        fill_missing_descriptions(result, self.row, variant, 'bind')
        self.assertEqual(result, before)
        with self.assertRaisesRegex(ValueError, 'choose API or family'):
            select_variant({'name': 'bind'}, self.row, 'bind')


if __name__ == '__main__':
    unittest.main()
