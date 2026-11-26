"""Common operand-depth validation and demanded transport, not an LMX parser.

The caller supplies an ALREADY parsed .(expression) occurrence and its context.
P0 owns the .( versus decimal-point boundary; this helper sees no delimiters.
No source token, repeated-dot parser, literal-name decoder, graph rewrite or
elementwise lifting implementation is present in this module.
"""
from dataclasses import dataclass
from typing import Any, Callable


class DepthError(ValueError):
    """Host diagnostic model: translator/interpreter error, not an LMX throw."""


@dataclass(frozen=True)
class DepthExpression:
    expression: Any
    context: Any
    origin: Any = None


def admit_depth(value):
    """Validate one nonnegative int; invalid depth is an execution diagnostic."""
    if type(value) is not int or value < 0:
        raise DepthError("depth requires one nonnegative int value")
    return value


def resolve_depth(source, obtain: Callable):
    """Obtain once only AFTER the enclosing operation has been demanded.

    `obtain(expression, context)` is the ordinary namespace value request.
    The context and source occurrence are passed unchanged. Never cache this
    result across distinct demands/activations, even for shared graph nodes.
    """
    value = (obtain(source.expression, source.context)
             if isinstance(source, DepthExpression) else source)
    return admit_depth(value)


@dataclass(frozen=True)
class OperandArguments:
    left: Any
    depth: int
    right: Any


def prepare_operand_arguments(left, depth_source, right, obtain):
    """Prepare only the common depth input, preserving both argument sides.

    The ordinary demand/role machinery owns all surrounding evaluation order.
    In particular this helper neither reads a PLACE as VALUE nor promotes
    right[0] to an absent left. `right` retains the supplied Array identity.
    """
    return OperandArguments(left, resolve_depth(depth_source, obtain), right)
