# # Basics

using Graphs
using MetaGraphsNext
using Test  #src

# ## Creating a `MetaGraph`

# ### Easiest constructor

# We provide a convenience constructor for creating empty graphs, which looks as follows:

colors = MetaGraph(
    Graph();  # underlying graph structure
    label_type=Symbol,  # color name
    vertex_data_type=NTuple{3,Int},  # RGB code
    edge_data_type=Symbol,  # result of the addition between two colors
    graph_data="additive colors",  # tag for the whole graph
)

# The `label_type` argument defines how vertices will be referred to, it can be anything but an integer type (to avoid confusion with codes, see below). The `vertex_data_type` and `edge_data_type` type determine what kind of data will be associated with each vertex and edge. Finally, `graph_data` can contain an arbitrary object associated with the graph as a whole.

# ### Type stability

# However, since this constructor receives types as keyword arguments, it is type-unstable. Casual users may not care, but if your goal is performance, you might need one of the following alternatives: either wrap the constructor in a function...

function colors_constructor()
    return MetaGraph(
        Graph();
        label_type=Symbol,
        vertex_data_type=NTuple{3,Int},
        edge_data_type=Symbol,
        graph_data="additive colors",
    )
end

colors_constructor()

@test @inferred colors_constructor() == colors  #src

# ... or switch to positional arguments (be careful with the order!)

MetaGraph(Graph(), Symbol, NTuple{3,Int}, Symbol, "additive colors")

@test (@inferred MetaGraph(  #src
    Graph(),  #src
    Symbol,  #src
    NTuple{3,Int},  #src
    Symbol,  #src
    "additive colors",  #src
) == colors)  #src

# ## Modifying the graph

# Modifications of graph elements and the associated metadata can always be done using `setindex!` (as in a dictionary) with the relevant labels.

# ### Vertices

# Use `setindex!` with one key to add a new vertex with the given label and metadata. If a vertex with the given label does not exist, it will be created automatically. Otherwise, the function will simply modify the metadata for the existing vertex.

colors[:red] = (255, 0, 0);
colors[:green] = (0, 255, 0);
colors[:blue] = (0, 0, 255);

# ### Edges

# Use `setindex!` with two keys to add a new edge between the given labels and containing the given metadata. Beware that this time, nonexistent labels will throw an error.

colors[:red, :green] = :yellow;
colors[:red, :blue] = :magenta;
colors[:green, :blue] = :cyan;

# ### Creating a non-empty graph

# There is a final constructor we haven't mentioned, which allows you to build and fill the `MetaGraph` in one fell swoop. Here's how it works:

graph = Graph(Edge.([(1, 2), (1, 3), (2, 3)]))
vertices_description = [:red => (255, 0, 0), :green => (0, 255, 0), :blue => (0, 0, 255)]
edges_description = [
    (:red, :green) => :yellow, (:red, :blue) => :magenta, (:green, :blue) => :cyan
]

colors2 = MetaGraph(graph, vertices_description, edges_description, "additive colors")
colors2 == colors

@test (@inferred MetaGraph(  #src
    graph,  #src
    vertices_description,  #src
    edges_description,  #src
    "additive colors",  #src
) == colors)  #src

# ## Accessing graph properties

# To retrieve graph properties, we still follow a dictionary-like interface based on labels.

# ### Existence

# To check the presence of a vertex or edge, use `haskey`:

haskey(colors, :red)
@test @inferred haskey(colors, :red)  #src
#-
haskey(colors, :black)
@test !haskey(colors, :black)  #src
#-
haskey(colors, :red, :green) && haskey(colors, :green, :red)
@test (@inferred haskey(colors, :red, :green)) && haskey(colors, :green, :red)  #src
#-
!haskey(colors, :red, :black)
@test !haskey(colors, :red, :black)  #src

# ### Metadata

# All kinds of metadata can be accessed with `getindex`:

colors[]
@test @inferred colors[] == "additive colors"  #src
#-
colors[:blue]
@test @inferred colors[:blue] == (0, 0, 255)  #src
#-
colors[:green, :blue]
@test @inferred colors[:green, :blue] == :cyan  #src

# ## Using vertex codes

# In the absence of removal, vertex codes correspond to order of insertion in the underlying graph. They are the ones used by most algorithms in the Graphs.jl ecosystem.

code_for(colors, :red)
@test @inferred code_for(colors, :red) == 1  #src
#-
code_for(colors, :blue)
@test code_for(colors, :blue) == 3  #src

# You can retrieve the associated labels as follows:

label_for(colors, 1)
@test @inferred label_for(colors, 1) == :red  #src
#-
label_for(colors, 3)
@test label_for(colors, 3) == :blue  #src

# Test coherence  #src

for label in labels(colors)  #src
    @test label_for(colors, code_for(colors, label)) == label  #src
end  #src

for code in vertices(colors)  #src
    @test code_for(colors, label_for(colors, code)) == code  #src
end  #src

# Delete vertex in a copy and test again  #src

colors_copy = copy(colors)  #src
rem_vertex!(colors_copy, 1)  #src

for label in labels(colors_copy)  #src
    @test label_for(colors_copy, code_for(colors_copy, label)) == label  #src
end  #src

for code in vertices(colors_copy)  #src
    @test code_for(colors_copy, label_for(colors_copy, code)) == code  #src
end  #src

# ## Handling weights

# You can use the `weight_function` field to specify a function which will transform edge metadata into a weight. This weight must always have the same type as the `default_weight`, which is the value returned in case an edge does not exist.

weighted = MetaGraph(
    Graph();
    label_type=Symbol,
    edge_data_type=Float64,
    weight_function=ed -> ed^2,
    default_weight=Inf,
);

weighted[:alice] = nothing;
weighted[:bob] = nothing;
weighted[:charlie] = nothing;

weighted[:alice, :bob] = 2.0;
weighted[:bob, :charlie] = 3.0;
#-
weight_matrix = Graphs.weights(weighted)
@test @inferred Graphs.weights(weighted) == weight_matrix  #src
#-
default_weight(weighted)
@test @inferred default_weight(weighted) ≈ Inf  #src
#-
size(weight_matrix)
@test size(weight_matrix) == (3, 3)  #src
#-
weight_matrix[1, 2]
@test @inferred weight_matrix[1, 2] ≈ 4.0  #src
#-
weight_matrix[2, 3]
@test @inferred weight_matrix[2, 3] ≈ 9.0  #src
#-
weight_matrix[1, 3]
@test @inferred weight_matrix[1, 3] ≈ Inf  #src
#-
wf = get_weight_function(weighted)
@test @inferred get_weight_function(weighted) == wf  #src
wf(4.0)
@test @inferred wf(4.0) ≈ 16.0  #src

# You can then use all functions from Graphs.jl that require weighted graphs (see the rest of the tutorial).
