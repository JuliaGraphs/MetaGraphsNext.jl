using Aqua
using Documenter
using Graphs
using JuliaFormatter
using MetaGraphsNext
using SimpleTraits
using Test

@testset verbose = true "MetaGraphsNext" begin
    @testset verbose = true "Code quality (Aqua.jl)" begin
        Aqua.test_all(MetaGraphsNext; ambiguities=false)
    end
    @testset verbose = false "Code formatting (JuliaFormatter.jl)" begin
        @test format(MetaGraphsNext; verbose=false, overwrite=false)
    end
    @testset verbose = false "Doctests (Documenter.jl)" begin
        doctest(MetaGraphsNext)
    end
    @testset verbose = true "Tutorial" begin
        @testset verbose = true "Basics" begin
            include(joinpath("tutorial", "1_basics.jl"))
        end
        @testset verbose = true "Graphs" begin
            include(joinpath("tutorial", "2_graphs.jl"))
        end
        @testset verbose = true "Files" begin
            include(joinpath("tutorial", "3_files.jl"))
        end
        @testset verbose = true "Type stability" begin
            include(joinpath("tutorial", "4_type_stability.jl"))
        end
    end

    @testset verbose = true "Short-form add_vertex!/add_edge!" begin
        # short-form
        mg = MetaGraph(Graph(); Label=Symbol, VertexData=Nothing, EdgeData=Nothing)
        @test add_vertex!(mg, :A)
        @test add_vertex!(mg, :B)
        @test add_edge!(mg, :A, :B)

        # long-form
        mg′ = MetaGraph(Graph(); Label=Symbol, VertexData=Nothing, EdgeData=Nothing)
        @test add_vertex!(mg′, :A, nothing)
        @test add_vertex!(mg′, :B, nothing)
        @test add_edge!(mg′, :A, :B, nothing)

        # compare
        @test mg == mg′
    end
end
