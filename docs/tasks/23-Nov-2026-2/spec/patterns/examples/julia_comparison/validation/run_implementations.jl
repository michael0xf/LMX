using Test
const COMPARE = normpath(joinpath(@__DIR__, "..", "library_comparisons"))
include(joinpath(COMPARE, "JI01_ordered.jl"))
include(joinpath(COMPARE, "JI02_arrays.jl"))
include(joinpath(COMPARE, "JI03_mutation.jl"))
include(joinpath(COMPARE, "JI04_order_group.jl"))
using .JuliaOrderedReference
using .JuliaArrayReference
using .JuliaMutationReference
using .JuliaOrderGroupReference

@testset "Полезные значения не ограничены int" begin
    @test mapValues(x -> (value=x,), ["a", "b"]) == [(value="a",), (value="b",)]
    @test mapValues(identity, Any[]) == Any[]
    @test filterValues(x -> x != "b", ["a", "b", "c"]) == ["a", "c"]
    @test filterValues(c -> '0' <= c <= '9', "a0-9") == "09"
    @test foldValues(*, "", ["a", "b"]) == "ab"
    @test foldValues(+, 7, Int[]) == 7
    @test scanValues(*, "", ["a", "b"]) == ["", "a", "ab"]
    @test scanValues(+, 7, Int[]) == [7]
    @test zipValues([1, 2], ["a"]) == [(1, "a")]
    @test zipWithValues((a, b) -> (a, b), [1, 2], ["a"]) == [(1, "a")]
    @test flatMapValues(x -> (x, x), ["a", "b"]) == ["a", "a", "b", "b"]
    @test flatMapValues(x -> Any[], [1, 2]) == Any[]
    @test_throws ArgumentError flatMapValues(identity, [1])
    @test_throws ArgumentError anyValues(x -> 1.5, [1])
    @test_throws ErrorException mapValues(x -> error("callback"), [1])
    target = Ref(7)
    @test recordValue(target) === target
end
@testset "Порядок и короткое замыкание" begin
    trace = Int[]
    accepts(x) = (push!(trace, x); x > 2)
    @test anyValues(accepts, [1, 3, 4])
    @test trace == [1, 3]
    empty!(trace)
    @test !allValues(accepts, [3, 1, 4])
    @test trace == [3, 1]
    empty!(trace)
    @test indexValue(accepts, [3, 4]) == 0
    @test trace == [3]
    @test isnothing(indexValue(identity, Int[]))
    @test !anyValues(identity, Int[])
    @test allValues(identity, Int[])
    @test countValues(iseven, [0, 1, 2]) == 2
    @test countValues(identity, Int[]) == 0
    @test foldValues(-, 100, [1, 2, 3]) == 94
end
@testset "Форма, границы, пустые и крайние диапазоны" begin
    @test rangeValues(5, -2, -2) == [5, 3, 1, -1]
    @test rangeValues(4, 4) == Int[]
    @test rangeValues(typemax(Int) - 1, typemax(Int), 2) == [typemax(Int) - 1]
    @test rangeValues(typemin(Int) + 1, typemin(Int), -2) == [typemin(Int) + 1]
    @test_throws ArgumentError rangeValues(0, 2, 0)
    @test_throws OverflowError rangeValues(typemin(Int), typemax(Int), 1)
    @test sliceValues(["a", "b"], 1, 2) == ["b"]
    @test sliceValues([1], 1, 1) == Int[]
    @test_throws BoundsError sliceValues([1], 0, 2)
    @test_throws BoundsError sliceValues([1], 1, 0)
    @test reverseValues(["a", "b"]) == ["b", "a"]
    @test reverseValues(Int[]) == Int[]
    @test compressValues(["a", "b", "c"], [1, 0, -1]) == ["a", "c"]
    @test_throws DimensionMismatch compressValues([1], Int[])
    @test_throws ArgumentError compressValues([1], [0.5])
    @test concatValues([[1, 2], Int[], [3]]) == [1, 2, 3]
    @test concatValues(Any[]) == Any[]
    @test concatValues(Any[[1], ["x"]]) == Any[1, "x"]
    @test transposeRows([[1, 2], [3, 4]]) == [[1, 3], [2, 4]]
    @test transposeRows(Any[]) == Any[]
    @test transposeRows([Int[], Int[]]) == Any[]
    @test_throws DimensionMismatch transposeRows([[1], [2, 3]])
    referenced = Ref("value")
    @test sliceValues([referenced], 0, 1)[1] === referenced
end
@testset "Полное изменение диапазона" begin
    target = [1, 2, 3]
    @test replaceRange!(target, 1, 2, [8, 9]) === target
    @test target == [1, 8, 9, 3]
    @test spliceValues!(target, 1, 3, [7]) == [8, 9]
    @test target == [1, 7, 3]
    @test spliceValues!(target, 1, 1, [8]) == Int[]
    @test target == [1, 8, 7, 3]
    @test spliceValues!(target, 0, 4, Int[]) == [1, 8, 7, 3]
    @test isempty(target)
    @test appendValues!(target, [1, 2]) === target
    @test target == [1, 2]
    @test appendValues!(target, target) === target
    @test target == [1, 2, 1, 2]
    target = [1, 2, 3, 4]
    @test spliceValues!(target, 1, 3, @view(target[2:4])) == [2, 3]
    @test target == [1, 2, 3, 4, 4]
    target = [1, 2]
    @test_throws InexactError replaceRange!(target, 0, 1, [1.5])
    @test target == [1, 2]
    @test_throws BoundsError replaceRange!(target, 0, 3, [7])
    @test target == [1, 2]
end
@testset "Устойчивость, равенство и группы" begin
    items = [(key=2,id="a"), (key=1,id="b"), (key=2,id="c")]
    before = copy(items)
    compare(a,b) = a.key < b.key ? -1 : a.key > b.key ? 1 : 0
    result = sortValues(compare, items)
    @test result == [(key=1,id="b"), (key=2,id="a"), (key=2,id="c")]
    @test items == before
    @test result !== items
    @test sortValues(compare, empty(items)) == empty(items)
    @test_throws ArgumentError sortValues((a,b) -> false, [1, 2])
    @test_throws ErrorException sortValues((a,b) -> error("compare"), [2, 1])
    @test uniqueValues(==, ["b", "a", "b"]) == ["b", "a"]
    @test uniqueValues(==, Any[]) == Any[]
    @test_throws ArgumentError uniqueValues((a,b) -> "yes", [1, 1])
    keysSeen = Int[]
    keyOf(x) = (push!(keysSeen, x); isodd(x))
    groups = groupValues(keyOf, ==, [3, 2, 5, 4])
    @test groups == [(key=true,items=Any[3,5]), (key=false,items=Any[2,4])]
    @test keysSeen == [3, 2, 5, 4]
    @test groupValues(identity, ==, Any[]) == Any[]
    @test_throws ErrorException groupValues(x -> error("key"), ==, [1])
end
