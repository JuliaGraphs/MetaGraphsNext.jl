# # Basics

using Graphs
using MetaGraphsNext
using Test  #src

# ## Creating an empty `MetaGraph`

# We provide a convenience constructor for creating empty graphs, which looks as follows:

colors = MetaGraph(
    Graph();  # underlying graph structure
    label_type=Symbol,  # color name
    vertex_data_type=NTuple{3,Int},  # RGB code
    edge_data_type=Symbol,  # result of the addition between two colors
    graph_data="additive colors",  # tag for the whole graph
)

# The `label_type` argument defines how vertices will be referred to, it can be anything you want (although integer types are generally discouraged, to avoid confusion with the vertex codes used by Graphs.jl). The `vertex_data_type` and `edge_data_type` type determine what kind of data will be associated with each vertex and edge. Finally, `graph_data` can contain an arbitrary object associated with the graph as a whole.

# If you don't care about labels at all, using the integer vertex codes as labels may be reasonable. Just keep in mind that labels do not change with vertex deletion, whereas vertex codes get decreased, so the coherence will be broken.

# ## Modifying the graph

# Modifications of graph elements and the associated metadata can always be done using `setindex!` (as in a dictionary) with the relevant labels.

# ### Vertices

# Use `setindex!` with one key to add a new vertex with the given label and metadata. If a vertex with the given label does not exist, it will be created automatically. Otherwise, the function will simply modify the metadata for the existing vertex.

colors[:red] = (255, 0, 0);
colors[:green] = (0, 255, 0);
colors[:blue] = (0, 0, 255);

# Note that you cannot use labels or metadata that is incoherent with the types you specified at construction.

@test_throws MethodError colors[:red] = "(255, 0, 0)"  #src
@test_throws MethodError colors["red"] = (255, 0, 0)  #src

# ### Edges

# Use `setindex!` with two keys to add a new edge between the given labels and containing the given metadata. Beware that this time, nonexistent labels will throw an error.

colors[:red, :green] = :yellow;
colors[:red, :blue] = :magenta;
colors[:green, :blue] = :cyan;

# ## Creating a non-empty `MetaGraph`

# There is an alternative constructor which allows you to build and fill the graph in one fell swoop. Here's how it works:

graph = Graph(Edge.([(1, 2), (1, 3), (2, 3)]))
vertices_description = [:red => (255, 0, 0), :green => (0, 255, 0), :blue => (0, 0, 255)]
edges_description = [
    (:red, :green) => :yellow, (:red, :blue) => :magenta, (:green, :blue) => :cyan
]

colors2 = MetaGraph(graph, vertices_description, edges_description, "additive colors")
colors2 == colors

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

# ## Listing labels

# The functions `labels`, `edge_labels`, `(in/out)neighbor_labels` iterate through labels the same way that `vertices`, `edges` and `(in/out)neighbors` iterate through codes.

collect(labels(colors))
@test collect(labels(colors)) == [:red, :green, :blue]  #src
#-
collect(edge_labels(colors))
@test collect(edge_labels(colors)) == [(:red, :green), (:red, :blue), (:green, :blue)]  #src
#-
collect(neighbor_labels(colors, :red))
@test collect(neighbor_labels(colors, :red)) == [:green, :blue]  #src

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
