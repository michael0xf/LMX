import unittest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from grok_uds_pull import is_grok_ticket


ID = 'GROK-EXAMPLE-20260921-01'


class GrokTicketRoutingTest(unittest.TestCase):
    def test_explicit_unicode_route_marker_delivers(self):
        self.assertTrue(is_grok_ticket(f'lmx_uds → grok\nFrom relay. Ticket {ID}.'))

    def test_explicit_ascii_route_marker_delivers(self):
        self.assertTrue(is_grok_ticket(f'lmx_uds -> grok\nFrom relay. Ticket {ID}.'))

    def test_codex_address_is_case_insensitive(self):
        self.assertTrue(is_grok_ticket(f'NEW TICKET FROM CODEX: TO GROK. {ID}.'))

    def test_codex_ticket_and_request_forms_deliver(self):
        self.assertTrue(is_grok_ticket(f'From Codex. Ticket {ID}.'))
        self.assertTrue(is_grok_ticket(f'From Codex. Request {ID}.'))

    def test_bare_id_in_status_report_does_not_deliver(self):
        self.assertFalse(is_grok_ticket(f'Status: {ID} is complete and its ACK was accepted.'))

    def test_codex_inbound_report_does_not_deliver(self):
        text = f'codex_inbound.py send --sender lmx_uds --request-id {ID} "report only"'
        self.assertFalse(is_grok_ticket(text))

    def test_unaddressed_codex_narration_does_not_deliver(self):
        self.assertFalse(is_grok_ticket(f'From Codex. The completed item was {ID}.'))

    def test_outbound_reply_never_loops(self):
        self.assertFalse(is_grok_ticket(f'From Grok. REPLY {ID}. lmx_uds -> grok'))

    def test_missing_id_never_delivers(self):
        self.assertFalse(is_grok_ticket('From Codex. To Grok. This has no request id.'))

    def test_quoted_route_marker_is_still_explicit_intent(self):
        # A marker-bearing quotation remains deliverable by design.  Relays must not quote a
        # published route row verbatim unless they intend a follow-up.
        quoted = f'Quoted row: lmx_uds -> grok From Codex. Ticket {ID}.'
        self.assertTrue(is_grok_ticket(quoted))


if __name__ == '__main__':
    unittest.main()
