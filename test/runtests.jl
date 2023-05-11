using Aqua
using Documenter
using Graphs
using JuliaFormatter
using MetaGraphsNext
using Test

DocMeta.setdocmeta!(MetaGraphsNext, :DocTestSetup, :(using MetaGraphsNext); recursive=true)

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
end
