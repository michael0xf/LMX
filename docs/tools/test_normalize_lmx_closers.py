#!/usr/bin/env python3
"""Regression checks for bounded closer normalization; not LMX P0 tests."""
import unittest

from normalize_lmx_closers import normalize_markdown, normalize_text


class CloserNormalization(unittest.TestCase):
    def check_case(self, source, count):
        result, report = normalize_text(source)
        self.assertEqual(len(report['removed']), count)
        self.assertTrue(report['projection_equal'])
        self.assertEqual(normalize_text(result)[0], result)
        return result

    def test_one_level(self):
        self.check_case('Root:\n    Item:\n        int: x 1\n    ---\n    Next:\n        int: y 2\n', 1)

    def test_multilevel_cut_stays(self):
        self.check_case('Root:\n    Item:\n        Inner:\n            int: x 1\n    ---\n    Next:\n        int: y 2\n', 0)

    def test_anonymous_group_marker_stays(self):
        self.check_case('Root:\n    ---\n        int: x 1\n', 0)

    def test_eof_closes(self):
        self.check_case('Root:\n    Item:\n        int: x 1\n---\n', 1)

    def test_blank_closes(self):
        self.check_case('Root:\n    Item:\n        int: x 1\n---\n\nNext:\n    int: y 2\n', 1)

    def test_root_cutter_before_exactly_one_blank_with_comments(self):
        source = ('Root:\n    Item:\n        int: x 1\n'
                  '--- # root cutter\n# retained comment\n\n'
                  '# next root field\nNext:\n    int: y 2\n')
        result = self.check_case(source, 1)
        self.assertEqual(result.count('\n\n'), 1)
        self.assertIn('# root cutter\n# retained comment\n\n# next root field\nNext:', result)

    def test_root_cutter_with_comments_before_eof(self):
        source = 'Root:\n    Item:\n        int: x 1\n---\n# final comment\n'
        result = self.check_case(source, 1)
        self.assertTrue(result.endswith('# final comment\n'))

    def test_root_comment_without_blank_does_not_replace_multilevel_cut(self):
        source = ('Root:\n    Item:\n        int: x 1\n---\n'
                  '# not an empty text line\nNext:\n    int: y 2\n')
        self.check_case(source, 0)

    def test_checked_named_close(self):
        self.check_case('Root:\n    Item:\n        int: x 1\n    end: Item\n    Next:\n        int: y 2\n', 1)

    def test_unknown_end_target_stays(self):
        self.check_case('Root:\n    Item:\n        int: x 1\n    end: Wrong\n', 0)

    def test_literals_are_payload(self):
        self.check_case('Root:\n    []char: text "--- end: Root"\n', 0)
        self.check_case('Root:\n    []char: text """\n---\nend: Root\n"""\n', 0)
        self.check_case('Root:\n    `name\n---\nend: Root`: 1\n', 0)

    def test_raw_block_and_comment_are_payload(self):
        self.check_case('===\n---\nend: Root\n===\n', 0)
        self.check_case('***\n---\nend: Root\n***\n', 0)

    def test_comment_survives(self):
        result = self.check_case('Root:\n    int: x 1\n--- # explanation\n', 1)
        self.assertIn('# explanation\n', result)

    def test_cascaded_eof(self):
        self.check_case('Root:\n    Item:\n        int: x 1\n    ---\n---\n', 2)

    def test_multilevel_named_cut_stays(self):
        self.check_case('Root:\n    Item:\n        Inner:\n            int: x 1\n    end: Item\n    Next:\n        int: y 2\n', 0)

    def test_paired_form_conservatively_preserved(self):
        self.check_case('Root: (\n    Item:\n        int: x 1\n    ---\n)\n', 0)

    def test_comment_is_not_blank_boundary(self):
        self.check_case('Root:\n    Item:\n        int: x 1\n    ---\n    # note\n    Next:\n        int: y 2\n', 1)

    def test_crlf_preserved(self):
        result = self.check_case('Root:\r\n    int: x 1\r\n---\r\n', 1)
        self.assertEqual(result, 'Root:\r\n    int: x 1\r\n')

    def test_mix_left_to_real_parser(self):
        self.check_case('Root:\n    print: {value}\n---\n', 0)

    def test_column_zero_joined_dot_token_is_conservative(self):
        self.check_case('.+ a b\n---\n', 0)
        self.check_case('.: a b\n---\n', 0)

    def test_canonical_dotted_cut_still_normalizes(self):
        self.check_case('Root:\n. Item:\n.. int: x 1\n.---\n', 1)

    def test_markdown_rule_and_other_languages_unchanged(self):
        source = '# Header\n\n---\n\n```python\n---\n```\n\n```lmx\nRoot:\n    int: x 1\n---\n```\n'
        result, report = normalize_markdown(source)
        self.assertEqual(len(report['removed']), 1)
        self.assertIn('\n---\n\n```python\n---\n```', result)

    def test_markdown_non_lmx_outer_fence_is_not_reentered(self):
        source = '````markdown\n```lmx\nRoot:\n    int: x 1\n---\n```\n````\n'
        self.assertEqual(normalize_markdown(source)[0], source)


if __name__ == '__main__':
    unittest.main()
