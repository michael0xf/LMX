"""Executable specification model; consumes views of ALREADY parsed LMX.

The dataclasses are test views, not additions to the P0 graph format.
Canonical names, operation resolution and role consumption already exist.
"""

from dataclasses import dataclass, replace
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
from operand_depth_reference import admit_depth, resolve_depth


class FormError(ValueError):
    pass


@dataclass(frozen=True)
class Actual:
    node: object
    context: object


@dataclass(frozen=True)
class OperationUse:
    name: str
    actuals: tuple[Actual, ...]
    context: object
    depth: object = 0


@dataclass(frozen=True)
class AttachedUpdate:
    # A view of an already grouped unary occurrence, not a name scanner.
    operator: str
    operatorBeforeAtom: bool
    atom: Actual
    context: object
    depth: object = 0


def normalizeUse(use):
    if isinstance(use, OperationUse):
        # Includes @, @name, ++counter and ++var as exact whole names.
        # No startswith(), splitting, unquoting or wildcard matching here.
        return use
    if not isinstance(use, AttachedUpdate):
        raise FormError("expected an already parsed operation use")
    if use.operator not in ("++", "--"):
        raise FormError("not an update pattern")
    if type(use.operatorBeforeAtom) is not bool:
        raise FormError("missing parsed placement")
    name = (use.operator + "var" if use.operatorBeforeAtom
            else "var" + use.operator)
    return OperationUse(name, (use.atom,), use.context, use.depth)


def translateOperation(use, core):
    site = normalizeUse(use)
    selected = core.resolveExistingOperation(site)
    # The existing lowering owns roles, argument admission, effects and scope.
    # There is no eager VALUE conversion or additional call activation here.
    return core.lowerExistingOperation(selected, site)


def prepareInvocation(use, obtainDepth):
    """After demand, obtain the named/common depth input without moving actuals.

    This is not called by translation or grouping. OperationUse.actuals holds
    the receiver's ordinary user arguments unchanged; the descriptor's depth
    represents its ordinary named `depth` input after name mapping. The
    operand adapter separately supplies the ABI order left, depth, right.
    """
    site = normalizeUse(use)
    return replace(site, depth=resolve_depth(site.depth, obtainDepth))


@dataclass(frozen=True)
class UpdateRule:
    direction: int
    returnPrevious: bool


# Reference descriptions of the four declared variants. In production these
# are properties of the selected operation, NOT a second runtime registry.
UPDATE_RULES = {
    "++var": UpdateRule(+1, False),
    "var++": UpdateRule(+1, True),
    "--var": UpdateRule(-1, False),
    "var--": UpdateRule(-1, True),
}


def lowerUpdate(rule, site, backend):
    # The zero-level scalar body, called after operation/PLACE selection.
    # Shared lifting lowers deeper applications before invoking this body.
    if admit_depth(site.depth) != 0:
        raise FormError("nonzero depth requires the shared lifting boundary")
    if len(site.actuals) != 1:
        raise FormError("update expects one PLACE argument")
    place = backend.resolvePlace(site.actuals[0], site.context)
    previous = backend.readValue(place)
    following = backend.stepValue(previous, rule.direction)
    stored = backend.storeValue(place, following)
    return previous if rule.returnPrevious else stored


# The real interpreter/native backend provides the four operations above.
# readValue saves a value, not a live alias of the place. stepValue uses the
# selected numeric/type profile. storeValue preserves admission and returns
# the stored typed value without reading the place again. Exceptions propagate.
