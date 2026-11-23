"""Limited checks of the specification model, not of an LMX implementation."""

from dataclasses import dataclass
from decimal import Decimal
import unittest

from translator_reference import (
    Actual, AttachedUpdate, FormError, OperationUse, UPDATE_RULES,
    lowerUpdate, normalizeUse, translateOperation,
)


@dataclass
class Cell:
    value: object


class Backend:
    def __init__(self, step=None, admit=None):
        self.events = []
        self.step = step or (lambda value, direction: value + direction)
        self.admit = admit or (lambda value: value)

    def resolvePlace(self, actual, context):
        self.events.append("place")
        self.actual = actual
        self.context = context
        return actual.node()

    def readValue(self, place):
        self.events.append("read")
        return place.value

    def stepValue(self, previous, direction):
        self.events.append("step")
        return self.step(previous, direction)

    def storeValue(self, place, value):
        self.events.append("admit")
        accepted = self.admit(value)
        self.events.append("write")
        place.value = accepted
        return accepted


class TranslatorChecks(unittest.TestCase):
    def setUp(self):
        self.context = object()
        self.cell = Cell(7)
        self.actual = Actual(lambda: self.cell, self.context)

    def site(self, name):
        return OperationUse(name, (self.actual,), self.context)

    def runVariant(self, operator, before, name, result, stored):
        form = AttachedUpdate(operator, before, self.actual, self.context)
        normalized = normalizeUse(form)
        self.assertEqual(normalized, self.site(name))
        for use in (normalized, self.site(name)):
            self.cell.value = 7
            backend = Backend()
            self.assertEqual(lowerUpdate(UPDATE_RULES[name], use, backend), result)
            self.assertEqual(self.cell.value, stored)
            self.assertEqual(backend.events, ["place", "read", "step", "admit", "write"])
            self.assertIs(backend.actual, self.actual)
            self.assertIs(backend.context, self.context)

    def test_increment_before(self):
        self.runVariant("++", True, "++var", 8, 8)

    def test_increment_after(self):
        self.runVariant("++", False, "var++", 7, 8)

    def test_decrement_before(self):
        self.runVariant("--", True, "--var", 6, 6)

    def test_decrement_after(self):
        self.runVariant("--", False, "var--", 7, 6)

    def test_exact_names_are_opaque(self):
        for name in ("@", "@name", "++counter", "counter++", "a+b", "a`b", "++var"):
            use = self.site(name)
            self.assertIs(normalizeUse(use), use)
            self.assertEqual(normalizeUse(use).name, name)

    def test_parameter_name_is_not_part_of_pattern_name(self):
        for actualName in ("x", "counter", "var", "@name"):
            actual = Actual(actualName, self.context)
            use = AttachedUpdate("++", True, actual, self.context)
            normalized = normalizeUse(use)
            self.assertEqual(normalized.name, "++var")
            self.assertIs(normalized.actuals[0], actual)

    def test_complete_compound_place_is_resolved_once(self):
        calls = []
        cells = [Cell(3), Cell(11)]
        def indexedPlace():
            calls.append("nextIndex")
            return cells[1]
        actual = Actual(indexedPlace, self.context)
        site = normalizeUse(AttachedUpdate("++", False, actual, self.context))
        backend = Backend()
        self.assertEqual(lowerUpdate(UPDATE_RULES[site.name], site, backend), 11)
        self.assertEqual([cell.value for cell in cells], [3, 12])
        self.assertEqual(calls, ["nextIndex"])

    def test_decimal_keeps_its_type(self):
        self.cell.value = Decimal("7.25")
        result = lowerUpdate(UPDATE_RULES["++var"], self.site("++var"), Backend())
        self.assertEqual(result, Decimal("8.25"))
        self.assertIs(type(result), Decimal)

    def test_original_actual_context_survives_forwarding(self):
        source = {"counter": Cell(7)}
        receiver = {"counter": Cell(100)}
        actual = Actual("counter", source)
        site = OperationUse("++var", (actual,), receiver)
        class ContextBackend(Backend):
            def resolvePlace(self, actual, context):
                self.events.append("place")
                self.receivingContext = context
                return actual.context[actual.node]
        backend = ContextBackend()
        self.assertEqual(lowerUpdate(UPDATE_RULES[site.name], site, backend), 8)
        self.assertEqual(source["counter"].value, 8)
        self.assertEqual(receiver["counter"].value, 100)
        self.assertIs(backend.receivingContext, receiver)

    def test_custom_profile_uses_same_algorithm(self):
        @dataclass(frozen=True)
        class Quantity:
            magnitude: int
        self.cell.value = Quantity(7)
        backend = Backend(step=lambda value, direction: Quantity(value.magnitude + direction))
        result = lowerUpdate(UPDATE_RULES["var--"], self.site("var--"), backend)
        self.assertEqual(result, Quantity(7))
        self.assertEqual(self.cell.value, Quantity(6))

    def test_invalid_arity_has_no_effects(self):
        for actuals in ((), (self.actual, self.actual)):
            backend = Backend()
            with self.assertRaises(FormError):
                lowerUpdate(UPDATE_RULES["++var"], OperationUse("++var", actuals, self.context), backend)
            self.assertEqual(backend.events, [])

    def test_step_failure_propagates_without_write(self):
        error = OverflowError("profile overflow")
        def fail(value, direction):
            raise error
        backend = Backend(step=fail)
        with self.assertRaises(OverflowError) as caught:
            lowerUpdate(UPDATE_RULES["++var"], self.site("++var"), backend)
        self.assertIs(caught.exception, error)
        self.assertEqual(self.cell.value, 7)
        self.assertEqual(backend.events, ["place", "read", "step"])

    def test_store_admission_failure_propagates(self):
        error = TypeError("destination requirement")
        def fail(value):
            raise error
        backend = Backend(admit=fail)
        with self.assertRaises(TypeError) as caught:
            lowerUpdate(UPDATE_RULES["var++"], self.site("var++"), backend)
        self.assertIs(caught.exception, error)
        self.assertEqual(self.cell.value, 7)
        self.assertEqual(backend.events, ["place", "read", "step", "admit"])

    def test_place_failure_has_no_read_or_write(self):
        error = IndexError("bad destination")
        def fail():
            raise error
        backend = Backend()
        site = OperationUse("++var", (Actual(fail, self.context),), self.context)
        with self.assertRaises(IndexError) as caught:
            lowerUpdate(UPDATE_RULES[site.name], site, backend)
        self.assertIs(caught.exception, error)
        self.assertEqual(backend.events, ["place"])

    def test_every_receiver_reaches_existing_lowering(self):
        selected = object()
        for name in ("@", "return", "finally", "copy", "some", "print", "++counter"):
            calls = []
            class Core:
                def resolveExistingOperation(self, site):
                    calls.append(("resolve", site))
                    return selected
                def lowerExistingOperation(self, operation, site):
                    calls.append(("lower", operation, site))
                    return site.context
            site = self.site(name)
            self.assertIs(translateOperation(site, Core()), self.context)
            self.assertEqual(calls, [("resolve", site), ("lower", selected, site)])

    def test_attached_and_receiver_use_one_resolver(self):
        seen = []
        class Core:
            def resolveExistingOperation(self, site):
                seen.append(site)
                return UPDATE_RULES[site.name]
            def lowerExistingOperation(self, rule, site):
                return lowerUpdate(rule, site, Backend())
        form = AttachedUpdate("++", True, self.actual, self.context)
        self.assertEqual(translateOperation(form, Core()), 8)
        self.cell.value = 7
        self.assertEqual(translateOperation(self.site("++var"), Core()), 8)
        self.assertEqual(seen[0], seen[1])

    def test_resolution_failure_does_not_lower(self):
        error = LookupError("unavailable operation")
        class Core:
            def resolveExistingOperation(self, site):
                raise error
            def lowerExistingOperation(self, selected, site):
                raise AssertionError("lowering must not be reached")
        with self.assertRaises(LookupError) as caught:
            translateOperation(self.site("++counter"), Core())
        self.assertIs(caught.exception, error)

    def test_missing_placement_is_not_guessed(self):
        use = AttachedUpdate("++", None, self.actual, self.context)
        with self.assertRaises(FormError):
            normalizeUse(use)


if __name__ == "__main__":
    unittest.main()
