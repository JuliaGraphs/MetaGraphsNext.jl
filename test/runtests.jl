using Documenter
using MetaGraphsNext
using Test
using Graphs

@testset "MetaGraphsNext" begin
    doctest(MetaGraphsNext)
    
    colors = MetaGraph( Graph(), VertexData = String, EdgeData = Symbol, graph_data = "graph_of_colors")
    
    labels = [:red, :yellow, :blue]
    values = ["warm", "warm", "cool"]
    for (lab,val) in zip(labels, values)
        colors[lab] = val
    end
    for lab in labels
        @test label_for(colors, code_for(colors, lab)) == lab
    end
    #delete an entry and test again
    rem_vertex!(colors, 1)
    popfirst!(labels); popfirst!(values)
    for lab in labels
        @test label_for(colors, code_for(colors, lab)) == lab
    end
end
