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
    @testset verbose = true "Code formatting (JuliaFormatter.jl)" begin
        @test format(MetaGraphsNext; verbose=false, overwrite=false)
    end
    @testset verbose = true "Doctests (Documenter.jl)" begin
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
    end
    @testset verbose = true "Labels, codes, directedness" begin
        include("labels_codes_directedness.jl")
    end
end
