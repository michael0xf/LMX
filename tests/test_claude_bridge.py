import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('bridge', Path(__file__).resolve().parents[1] / 'tools/claude_bridge.py')
bridge = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bridge)


class BridgeTest(unittest.TestCase):
    def test_profiles_are_separate(self):
        self.assertNotEqual(bridge.profile_directory('grok'), bridge.profile_directory('claude_code'))
        for name in ('../L1', 'C:/L1', '', 'con', 'grok/other'):
            with self.assertRaises(ValueError):
                bridge.profile_directory(name)

    def test_two_profiles_have_different_sessions(self):
        def runner(args, directory, prompt, timeout):
            return subprocess.CompletedProcess(args, 0, json.dumps({'session_id': args[-1], 'result': 'ok'}), '')
        with tempfile.TemporaryDirectory() as tmp:
            a = bridge.ask(Path(tmp)/'a', 'one', runner=runner)
            b = bridge.ask(Path(tmp)/'b', 'two', runner=runner)
            self.assertNotEqual(a['session_id'], b['session_id'])

    def test_new_then_resume_same_session(self):
        calls = []
        def runner(args, directory, prompt, timeout):
            calls.append(args)
            return subprocess.CompletedProcess(args, 0, json.dumps({'session_id': args[-1], 'result': 'ok'}), '')
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            first = bridge.ask(root, 'one', runner=runner)
            second = bridge.ask(root, 'two', runner=runner)
            self.assertEqual(first['session_id'], second['session_id'])
            self.assertEqual(calls[0][-2], '--session-id')
            self.assertEqual(calls[1][-2], '--resume')
            self.assertNotIn('--continue', calls[1])

    def test_busy_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            with bridge.lock(root):
                with self.assertRaises(RuntimeError):
                    bridge.ask(root, 'blocked')

    def test_uncertain_delivery_not_repeated(self):
        def runner(*args):
            raise subprocess.TimeoutExpired('claude', 1)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            with self.assertRaises(subprocess.TimeoutExpired):
                bridge.ask(root, 'one', runner=runner)
            with self.assertRaisesRegex(RuntimeError, 'uncertain'):
                bridge.ask(root, 'two', runner=runner)

    def test_foreign_session_rejected(self):
        def runner(*args):
            return subprocess.CompletedProcess([], 0, '{"session_id":"foreign"}', '')
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(RuntimeError, 'Unexpected session'):
                bridge.ask(Path(tmp), 'one', runner=runner)

    def test_private_config(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = bridge.environment(Path(tmp))
            self.assertEqual(env['CLAUDE_CONFIG_DIR'], str(Path(tmp) / 'config'))
            self.assertEqual(env['DISABLE_AUTOUPDATER'], '1')


if __name__ == '__main__':
    unittest.main()
