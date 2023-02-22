# # Basics

using Graphs
using MetaGraphsNext
using Test  #src

# ## Creating a `MetaGraph`

# We provide a default constructor which looks as follows:

colors = MetaGraph(
    Graph();  # underlying graph structure
    Label=Symbol,  # color name
    VertexData=NTuple{3,Int},  # RGB code
    EdgeData=String,  # result of the addition between two colors
    graph_data="additive colors",  # tag for the whole graph
)

# The `Label` type defines how vertices will be referred to, it can be anything but an integer type (to avoid confusion with codes, see below). The `VertexData` and `EdgeData` type determine what kind of data will be associated with each vertex and edge. Finally, `graph_data` can contain an arbitrary object associated with the graph as a whole.

# ## Modifying the graph

# Modifications of graph elements and the associated metadata can always be done using `setindex!` (as in a dictionary) with the relevant labels.

# ### Vertices

# Use `setindex!` with one key to add a new vertex with the given label and metadata. If a vertex with the given label does not exist, it will be created automatically. Otherwise, the function will simply modify the metadata for the existing vertex.

colors[:red] = (255, 0, 0);
colors[:green] = (0, 255, 0);
colors[:blue] = (0, 0, 255);

# ### Edges

# Use `setindex!` with two keys to add a new edge between the given labels and containing the given metadata. Beware that this time, nonexistent labels will throw an error.

colors[:red, :green] = "yellow";
colors[:red, :blue] = "magenta";
colors[:green, :blue] = "cyan";

# ## Accessing graph properties

# To retrieve graph properties, we still follow a dictionary-like interface based on labels.

# ### Existence

# To check the presence of a vertex or edge, use `haskey`:

haskey(colors, :red)
@test haskey(colors, :red)  #src
#-
haskey(colors, :black)
@test !haskey(colors, :black)  #src
#-
haskey(colors, :red, :green) && haskey(colors, :green, :red)
@test haskey(colors, :red, :green) && haskey(colors, :green, :red)  #src
#-
!haskey(colors, :red, :black)
@test !haskey(colors, :red, :black)  #src

# ### Metadata

# All kinds of metadata can be accessed with `getindex`:

colors[]
@test colors[] == "additive colors"  #src
#-
colors[:blue]
@test colors[:blue] == (0, 0, 255)  #src
#-
colors[:green, :blue]
@test colors[:green, :blue] == "cyan"  #src

# ## Using vertex codes

# In the absence of removal, vertex codes correspond to order of insertion in the underlying graph. They are the ones used by most algorithms in the Graphs.jl ecosystem.

code_for(colors, :red)
@test code_for(colors, :red) == 1  #src
#-
code_for(colors, :blue)
@test code_for(colors, :blue) == 3  #src

# You can retrieve the associated labels as follows:

label_for(colors, 1)
@test label_for(colors, 1) == :red  #src
#-
label_for(colors, 3)
@test label_for(colors, 3) == :blue  #src

# ## Adding weights

# The most simple way to add edge weights is to speficy a default weight for all of them.

weighted_default = MetaGraph(Graph(); default_weight=2);
#-
default_weight(weighted_default)
@test default_weight(weighted_default) == 2  #src
#-
weighttype(weighted_default)
@test weighttype(weighted_default) == Int  #src

# You can use the `weight_function` keyword to specify a function which will transform edge metadata into a weight. This weight must always be the same type as the `default_weight`.

weighted = MetaGraph(Graph(); EdgeData=Float64, weight_function=ed -> ed^2);

weighted[:alice] = nothing;
weighted[:bob] = nothing;
weighted[:alice, :bob] = 2.0;
#-
weight_matrix = Graphs.weights(weighted)
#-
size(weight_matrix)
@test size(weight_matrix) == (2, 2)  #src
#-
weight_matrix[1, 2]
@test weight_matrix[1, 2] ≈ 4.0  #src
#-
wf = get_weight_function(weighted)
wf(3)
@test wf(3) == 9  #src

# You can then use all functions from Graphs.jl that require weighted graphs (see the rest of the tutorial).
