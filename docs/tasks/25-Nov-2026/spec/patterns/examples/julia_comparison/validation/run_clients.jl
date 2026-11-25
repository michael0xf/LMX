using Test

const SUITE = normpath(joinpath(@__DIR__, ".."))
function loadClient(id)
    namespace = Module(Symbol("Client" * id))
    Base.include(namespace, joinpath(SUITE, "source", "julia", id * ".jl"))
    getfield(namespace, :example)
end
function observe(id, value, args)
    if id == "J24"
        return [collect(pair) for pair in value]
    elseif id == "J12"
        return Dict{String,Any}((key ? "true" : "false") => value[key] for key in keys(value))
    elseif id == "J15"
        return isnothing(value) ? Dict{String,Any}("present"=>false) : Dict{String,Any}("present"=>true, "value"=>value)
    elseif id == "J17"
        return Dict{String,Any}("returned"=>value, "target"=>args[1], "same_target"=>value === args[1])
    elseif id == "J18"
        return Dict{String,Any}("removed"=>value, "target"=>args[1])
    elseif id == "J20"
        return [Dict{String,Any}("key"=>x.key, "id"=>x.id) for x in value]
    end
    value
end

@testset "J01" begin
    call = loadClient("J01")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = (1, 8, 2)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J01", value, args) == [1, 3, 5, 7]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (5, -2, -2)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J01", value, args) == [5, 3, 1, -1]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = (4, 4, 1)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J01", value, args) == Int[]
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = (1, 8, 0)
    before = deepcopy(args)
    @test_throws ArgumentError Base.invokelatest(call, args...)
    @test args == before
end

@testset "J02" begin
    call = loadClient("J02")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([10, 20, 30, 40, 50], 1, 4)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J02", value, args) == [20, 30, 40]
    @test args == before
    @test value !== args[1]
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2], 2, 2)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J02", value, args) == Int[]
    @test args == before
    @test value !== args[1]
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([1], 0, 2)
    before = deepcopy(args)
    @test_throws BoundsError Base.invokelatest(call, args...)
    @test args == before
end

@testset "J03" begin
    call = loadClient("J03")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([7, 3, 7, 2, 3, 9],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J03", value, args) == [9, 3, 2, 7]
    @test args == before
    @test value !== args[1]
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J03", value, args) == Int[]
    @test args == before
    @test value !== args[1]
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([1, 1, 2, 1],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J03", value, args) == [1, 2]
    @test args == before
    @test value !== args[1]
end

@testset "J04" begin
    call = loadClient("J04")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([10, 20, 30, 40], [1, 0, -2, 0])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J04", value, args) == [10, 30]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], Int[])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J04", value, args) == Int[]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2], [1])
    before = deepcopy(args)
    @test_throws DimensionMismatch Base.invokelatest(call, args...)
    @test args == before
end

@testset "J05" begin
    call = loadClient("J05")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([4, 7, 5], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J05", value, args) == 5
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], 10)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J05", value, args) == 0
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([-3, 0, 4], 0)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J05", value, args) == 25
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([5, 5], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J05", value, args) == 0
    @test args == before
end

@testset "J06" begin
    call = loadClient("J06")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([-3, -2, 1, 5, -3, 1, 4],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J06", value, args) == [-3, 1, 5]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J06", value, args) == Int[]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([2, 4],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J06", value, args) == Int[]
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([3, 3, 1, 3],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J06", value, args) == [3, 1]
    @test args == before
end

@testset "J07" begin
    call = loadClient("J07")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([13, -5, 3], 10)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J07", value, args) == 2
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], 7)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J07", value, args) == 7
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([-5, 13, 3], 10)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J07", value, args) == 0
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([2, 3], 10)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J07", value, args) == 5
    @test args == before
end

@testset "J08" begin
    call = loadClient("J08")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([-8, 2, -5, 10], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J08", value, args) == [-3, -1, -6]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], 7)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J08", value, args) == Int[]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = (Int[], -2)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J08", value, args) == [-2]
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([1, -1], 0)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J08", value, args) == Int[]
    @test args == before
end

@testset "J09" begin
    call = loadClient("J09")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([5, 2, 7], [3, 4])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J09", value, args) == 2
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], [1])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J09", value, args) == 0
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([5, 2, 9], [1, 1, 3, 99])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J09", value, args) == 11
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([1], [2, 3])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J09", value, args) == 0
    @test args == before
end

@testset "J10" begin
    call = loadClient("J10")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2, 3], [4, 5, 6], 20)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J10", value, args) == [29, 42]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], Int[], 0)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J10", value, args) == Int[]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([2], [-3], 13)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J10", value, args) == [13]
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2], [3], 0)
    before = deepcopy(args)
    @test_throws DimensionMismatch Base.invokelatest(call, args...)
    @test args == before
end

@testset "J11" begin
    call = loadClient("J11")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([0, 2, 2],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J11", value, args) == [0, 1, 2, 3]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J11", value, args) == Int[]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([3, 1],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J11", value, args) == [2, 3, 4, 0, 1]
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([-2],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J11", value, args) == Int[]
    @test args == before
end

@testset "J12" begin
    call = loadClient("J12")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([3, 2, 5, 4, 3, 2],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J12", value, args) == Dict{String,Any}("true"=>[3, 5], "false"=>[2, 4])
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J12", value, args) == Dict{String,Any}()
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([2, 4, 2],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J12", value, args) == Dict{String,Any}("false"=>[2, 4])
    @test args == before
end

@testset "J13" begin
    call = loadClient("J13")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([1, 9, 2, 8, 9], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J13", value, args) == true
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J13", value, args) == false
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([9], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J13", value, args) == false
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([9, 1, 9], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J13", value, args) == false
    @test args == before
    # Случай 4: подготовка и assertions вне сравниваемого кода.
    args = ([6, 6], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J13", value, args) == true
    @test args == before
end

@testset "J14" begin
    call = loadClient("J14")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([2, 1, 4], [3, 1, 6])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J14", value, args) == true
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], Int[])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J14", value, args) == true
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([1, 0], [2, 2])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J14", value, args) == false
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([3], [2])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J14", value, args) == false
    @test args == before
    # Случай 4: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2], [9])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J14", value, args) == false
    @test args == before
end

@testset "J15" begin
    call = loadClient("J15")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([2, 8, 9], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J15", value, args) == Dict{String,Any}("present"=>true, "value"=>1)
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = ([9], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J15", value, args) == Dict{String,Any}("present"=>true, "value"=>0)
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = (Int[], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J15", value, args) == Dict{String,Any}("present"=>false)
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J15", value, args) == Dict{String,Any}("present"=>false)
    @test args == before
end

@testset "J16" begin
    call = loadClient("J16")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([9, 10, 11, 12, 20], 10, 12)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J16", value, args) == 600
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], 0, 1)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J16", value, args) == 0
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([0, 1, 2], 1, 1)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J16", value, args) == 333
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2], 3, 4)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J16", value, args) == 0
    @test args == before
    # Случай 4: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2], 0, 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J16", value, args) == 1000
    @test args == before
end

@testset "J17" begin
    call = loadClient("J17")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2, 3], [4, 5], 3)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J17", value, args) == Dict{String,Any}("returned"=>[3, 4, 5], "target"=>[3, 4, 5], "same_target"=>true)
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], Int[], 2)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J17", value, args) == Dict{String,Any}("returned"=>Int[], "target"=>Int[], "same_target"=>true)
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([1], [2], 0)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J17", value, args) == Dict{String,Any}("returned"=>Int[], "target"=>Int[], "same_target"=>true)
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([1], [2], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J17", value, args) == Dict{String,Any}("returned"=>[1, 2], "target"=>[1, 2], "same_target"=>true)
end

@testset "J18" begin
    call = loadClient("J18")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2, 3, 4], 1, 3, [9, 8, 7])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J18", value, args) == Dict{String,Any}("removed"=>[2, 3], "target"=>[1, 9, 8, 7, 4])
    @test value !== args[1]
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2], 1, 1, [9])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J18", value, args) == Dict{String,Any}("removed"=>Int[], "target"=>[1, 9, 2])
    @test value !== args[1]
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([1, 2], 0, 2, Int[])
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J18", value, args) == Dict{String,Any}("removed"=>[1, 2], "target"=>Int[])
    @test value !== args[1]
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([1], 0, 2, Int[])
    before = deepcopy(args)
    @test_throws BoundsError Base.invokelatest(call, args...)
    @test args == before
end

@testset "J19" begin
    call = loadClient("J19")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([2 4 6; 3 5 7], 1)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J19", value, args) == [3, 7, 11]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (reshape([7], 1, 1), 2)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J19", value, args) == [5]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = (Matrix{Int}(undef, 0, 0), 3)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J19", value, args) == Int[]
    @test args == before
end

@testset "J20" begin
    call = loadClient("J20")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([(key=2, id="a"), (key=1, id="b"), (key=2, id="c"), (key=1, id="d")], 3)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J20", value, args) == [Dict{String,Any}("key"=>1, "id"=>"b"), Dict{String,Any}("key"=>1, "id"=>"d"), Dict{String,Any}("key"=>2, "id"=>"a")]
    @test args == before
    @test value !== args[1]
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], 2)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J20", value, args) == Int[]
    @test args == before
    @test value !== args[1]
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([(key=2, id="a"), (key=1, id="b"), (key=2, id="c"), (key=1, id="d")], 0)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J20", value, args) == Int[]
    @test args == before
    @test value !== args[1]
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([(key=1, id="a"), (key=1, id="b")], 5)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J20", value, args) == [Dict{String,Any}("key"=>1, "id"=>"a"), Dict{String,Any}("key"=>1, "id"=>"b")]
    @test args == before
    @test value !== args[1]
end

@testset "J21" begin
    call = loadClient("J21")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([[3, 1, 3], Int[], [2, 1], [4, 2]],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J21", value, args) == [3, 1, 2, 4]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J21", value, args) == Int[]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([Int[], Int[]],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J21", value, args) == Int[]
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([[2, 2], [2]],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J21", value, args) == [2]
    @test args == before
end

@testset "J22" begin
    call = loadClient("J22")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ("invoice42-ref-09123",)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J22", value, args) == "9123"
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = ("",)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J22", value, args) == ""
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ("AB-09 x2!",)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J22", value, args) == "092"
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ("code-000012",)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J22", value, args) == "0012"
    @test args == before
    # Случай 4: подготовка и assertions вне сравниваемого кода.
    args = ("none",)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J22", value, args) == ""
    @test args == before
end

@testset "J23" begin
    call = loadClient("J23")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([[1, 2], Int[], [3], [4, 5]],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J23", value, args) == [5, 4, 3, 2, 1]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J23", value, args) == Int[]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([Int[], Int[]],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J23", value, args) == Int[]
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([[[1]], [[2]]],)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J23", value, args) == [[2], [1]]
    @test args == before
end

@testset "J24" begin
    call = loadClient("J24")
    # Случай 0: подготовка и assertions вне сравниваемого кода.
    args = ([2, 5], [3, 6], 8)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J24", value, args) == [[2, 3], [2, 6], [5, 3]]
    @test args == before
    # Случай 1: подготовка и assertions вне сравниваемого кода.
    args = (Int[], [1], 4)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J24", value, args) == Int[]
    @test args == before
    # Случай 2: подготовка и assertions вне сравниваемого кода.
    args = ([1], Int[], 4)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J24", value, args) == Int[]
    @test args == before
    # Случай 3: подготовка и assertions вне сравниваемого кода.
    args = ([5], [6], 10)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J24", value, args) == Int[]
    @test args == before
    # Случай 4: подготовка и assertions вне сравниваемого кода.
    args = ([1, 1], [2], 3)
    before = deepcopy(args)
    value = Base.invokelatest(call, args...)
    @test observe("J24", value, args) == [[1, 2], [1, 2]]
    @test args == before
end

