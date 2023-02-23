# undirected MetaGraph
colors = MetaGraph(
    Graph();
    label_type=Symbol,
    vertex_data_type=String,
    edge_data_type=Symbol,
    graph_data="graph_of_colors",
)
@test istrait(IsDirected{typeof(colors)}) == is_directed(colors) == false
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
dcolors = MetaGraph(
    SimpleDiGraph();
    label_type=Symbol,
    vertex_data_type=String,
    edge_data_type=Symbol,
    graph_data="graph_of_colors",
)
@test istrait(IsDirected{typeof(dcolors)}) == is_directed(dcolors) == true
labels = [:red, :yellow, :blue]
values = ["warm", "warm", "cool"]
for (label, value) in zip(labels, values)
    dcolors[label] = value
end
dcolors[:red, :yellow] = :redyellow
@test MetaGraphsNext.arrange(dcolors, :yellow, :blue) == (:yellow, :blue)
