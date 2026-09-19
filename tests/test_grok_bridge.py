import importlib.util
from pathlib import Path
import queue
import unittest

spec = importlib.util.spec_from_file_location('grok_bridge', Path(__file__).resolve().parents[1] / 'claude_chat/grok.py')
grok = importlib.util.module_from_spec(spec)
spec.loader.exec_module(grok)


class ProtocolTests(unittest.TestCase):
    def client(self, messages):
        client = grok.ACP.__new__(grok.ACP)
        client.next_id = 0
        client.timeout = 0.01
        client.messages = []
        client.queue = queue.Queue()
        client.sent = []
        client.write = client.sent.append
        for message in messages:
            client.queue.put(message)
        return client

    def test_stream_is_collected_until_matching_completion(self):
        client = self.client([
            {'method': 'session/update', 'params': {'update': {'sessionUpdate': 'agent_message_chunk', 'content': {'type':'text','text':'hello'}}}},
            {'id': 123, 'result': {'stopReason':'unrelated'}},
            {'method': 'session/update', 'params': {'update': {'sessionUpdate': 'agent_message_chunk', 'content': {'type':'text','text':' world'}}}},
            {'id': 1, 'result': {'stopReason':'end_turn'}},
        ])
        self.assertEqual(client.request('session/prompt', {})['stopReason'], 'end_turn')
        self.assertEqual(''.join(client.messages), 'hello world')

    def test_permission_request_is_not_approved(self):
        client = self.client([
            {'id': 22, 'method': 'session/request_permission', 'params': {}},
            {'id': 1, 'result': {}},
        ])
        client.request('session/prompt', {})
        self.assertEqual(client.sent[1]['result']['outcome']['outcome'], 'cancelled')

    def test_disconnect_is_not_success(self):
        with self.assertRaisesRegex(RuntimeError, 'exited'):
            self.client([None]).request('session/prompt', {})

    def test_timeout_is_not_success(self):
        with self.assertRaisesRegex(RuntimeError, 'uncertain'):
            self.client([]).request('session/prompt', {})

    def test_error_is_not_success(self):
        with self.assertRaisesRegex(RuntimeError, 'failed'):
            self.client([{'id':1,'error':{'code':-1,'message':'test'}}]).request('session/prompt', {})


if __name__ == '__main__':
    unittest.main()
