using Documenter
using MetaGraphsNext
using Test
using Graphs
using SimpleTraits

@testset "MetaGraphsNext" begin
    doctest(MetaGraphsNext)

    colors = MetaGraph( Graph(), VertexData = String, EdgeData = Symbol, graph_data = "graph_of_colors")
    @test istrait(IsDirected{typeof(colors)}) == is_directed(colors) == false
    @test SimpleGraph(colors) isa SimpleGraph
    @test_throws MethodError SimpleDiGraph(colors)

    labels = [:red, :yellow, :blue]
    values = ["warm", "warm", "cool"]
    for (label, value) in zip(labels, values)
        colors[label] = value
    end
    for label in labels
        @test label_for(colors, code_for(colors, label)) == label
    end
    #delete an entry and test again
    rem_vertex!(colors, 1)
    popfirst!(labels)
    popfirst!(values)
    for label in labels
        @test label_for(colors, code_for(colors, label)) == label
    end
    @test MetaGraphsNext.arrange(colors, :yellow, :blue) == (:blue, :yellow)


    # directed MetaGraph
    dcolors = MetaGraph( SimpleDiGraph(), VertexData = String, EdgeData = Symbol, graph_data = "graph_of_colors")
    @test istrait(IsDirected{typeof(dcolors)}) == is_directed(dcolors) == true
    @test SimpleDiGraph(dcolors) isa SimpleDiGraph
    @test_throws MethodError SimpleGraph(dcolors)
    labels = [:red, :yellow, :blue]
    values = ["warm", "warm", "cool"]
    for (label, value) in zip(labels, values)
        dcolors[label] = value
    end
    dcolors[:red, :yellow] = :redyellow
    @test MetaGraphsNext.arrange(dcolors, :yellow, :blue) == (:yellow, :blue)
end
