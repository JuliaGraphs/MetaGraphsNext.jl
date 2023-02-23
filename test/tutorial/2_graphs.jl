# # Graphs.jl  interface

using Graphs
using MetaGraphsNext
using Test  #src

# `MetaGraph`s inherit many methods from Graphs.jl. In general, inherited methods refer to vertices by codes, not labels, for compatibility with the `AbstractGraph` interface.

# Note that vertex codes get reassigned after `rem_vertex!` operations to remain contiguous, so we recommend systematically converting to and from labels.

# ## Undirected graphs

# We can make `MetaGraph`s based on (undirected) `Graph`s.

cities = MetaGraph(
    Graph();
    label_type=Symbol,
    vertex_data_type=String,
    edge_data_type=Int,
    graph_data=nothing,
    weight_function=identity,
);

# Let us add some cities and the distance between them:

cities[:Paris] = "France";
cities[:London] = "UK";
cities[:Berlin] = "Germany";
cities[:Paris, :London] = 344;
cities[:Paris, :Berlin] = 878;

# The general properties of the graph are as expected:

is_directed(cities)
@test @inferred !is_directed(cities)  #src
@test !istrait(IsDirected{typeof(cities)})  #src
@test MetaGraphsNext.arrange(cities, :London, :Paris) == (:Paris, :London)
#-
eltype(cities)
@test @inferred eltype(cities) == Int  #src
#-
edgetype(cities)
@test @inferred edgetype(cities) == Graphs.SimpleEdge{Int}  #src

# We can check the set of vertices:

nv(cities)
@test @inferred nv(cities) == 3  #src
#-
collect(vertices(cities))
@test @inferred Tuple(collect(vertices(cities))) == (1, 2, 3)  #src
#-
has_vertex(cities, 2)
@test @inferred has_vertex(cities, 2)  #src
#-
has_vertex(cities, 4)
@test @inferred !has_vertex(cities, 4)  #src

# Note that we can't add the same city (i.e. vertex label) twice:

add_vertex!(cities, :London, "Italy")
#-
nv(cities)
@test nv(cities) == 3  #src
#-
cities[:London]
@test @inferred cities[:London] == "UK"  #src

# We then check the set of edges:

ne(cities)
@test @inferred ne(cities) == 2  #src
#-
collect(edges(cities))
@test @inferred Tuple(collect(edges(cities))) == (Edge(1, 2), Edge(1, 3))  #src
#-
has_edge(cities, 1, 2)
@test @inferred has_edge(cities, 1, 2)  #src
#-
has_edge(cities, 2, 3)
@test !has_edge(cities, 2, 3)  #src

# From this initial graph, we can create some others:

copy(cities)
@test copy(cities) == cities  #src
#-
zero(cities)
@test nv(zero(cities)) == 0  #src

# Since `cities` is a weighted graph, we can leverage the whole Graphs.jl machinery of graph analysis and traversal:

diameter(cities)
@test diameter(cities) == 344 + 878  #src
#-
ds = dijkstra_shortest_paths(cities, 2)
@test @inferred Tuple(dijkstra_shortest_paths(cities, 2).dists) == (344, 0, 344 + 878)  #src

# Finally, let us remove some edges and vertices

rem_edge!(cities, 1, 3);
rem_vertex!(cities, 3);
has_vertex(cities, 1) && !has_vertex(cities, 3)
@test has_vertex(cities, 1) && !has_vertex(cities, 3)  #src

# ## Directed graphs

# We can make `MetaGraph`s based on `DiGraph`s as well.

rock_paper_scissors = MetaGraph(DiGraph(); label_type=Symbol, edge_data_type=String);

for label in [:rock, :paper, :scissors]
    rock_paper_scissors[label] = nothing
end

rock_paper_scissors[:rock, :scissors] = "rock beats scissors"
rock_paper_scissors[:scissors, :paper] = "scissors beat paper"
rock_paper_scissors[:paper, :rock] = "paper beats rock";

# We see that the underlying graph has changed:

is_directed(rock_paper_scissors)
@test @inferred is_directed(rock_paper_scissors)  #src
@test istrait(IsDirected{typeof(rock_paper_scissors)}) #src
@test MetaGraphsNext.arrange(rock_paper_scissors, :paper, :rock) == (:paper, :rock)  #src

# Directed graphs can be reversed:

haskey(rock_paper_scissors, :scissors, :rock)
@test !haskey(rock_paper_scissors, :scissors, :rock)  #src
#-
haskey(reverse(rock_paper_scissors), :scissors, :rock)
@test haskey(reverse(rock_paper_scissors), :scissors, :rock)  #src

# Finally, let us take a subgraph:

rock_paper, _ = induced_subgraph(rock_paper_scissors, [1, 2])
@test @inferred induced_subgraph(rock_paper_scissors, [1, 2])[1] == rock_paper
#-
issubset(rock_paper, rock_paper_scissors)
@test @inferred issubset(rock_paper, rock_paper_scissors)  #src
#-
haskey(rock_paper, :paper, :rock)
@test haskey(rock_paper, :paper, :rock)  #src
#-
haskey(rock_paper, :rock, :scissors)
@test !haskey(rock_paper, :rock, :scissors)  #src
