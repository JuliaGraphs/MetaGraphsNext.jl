using MetaGraphsNext

colors = MetaGraph(
    Graph(); VertexData=String, EdgeData=Symbol, graph_data="graph_of_colors"
)

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
