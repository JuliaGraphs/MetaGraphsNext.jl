# Working with metagraphs

```jldoctest example
julia> using Graphs

julia> using MetaGraphsNext
```

## Creating a `MetaGraph`

We provide a default constructor in which you only need to specify types:

```jldoctest example
julia> colors = MetaGraph( Graph(), VertexData = String, EdgeData = Symbol, graph_data = "graph_of_colors")
Meta graph based on a Graphs.SimpleGraphs.SimpleGraph{Int64}(0, Vector{Int64}[]) with vertex labels of type Symbol, vertex metadata of type String, edge metadata of type Symbol, graph metadata given by "graph_of_colors", and default weight 1.0
```

## Modifying the graph

Modifications of graph elements and the associated metadata can always be done using `setindex!` (as in a dictionary) with the relevant labels.

### Vertices

Use `setindex!` with one key to add a new vertex with the given label and metadata. If a vertex with the given label does not exist, it will be created automatically. Otherwise, the function will simply modify the metadata for the existing vertex.

```jldoctest example
julia> colors[:red] = "warm";

julia> colors[:yellow] = "warm";

julia> colors[:blue] = "warm";  # wrong metadata

julia> colors[:blue] = "cool";
```

### Edges

Use `setindex!` with two keys to add a new edge between the given labels and containing the given metadata. Beware that this time, nonexistent labels will throw an error.

```jldoctest example
julia> colors[:red, :yellow] = :orange;

julia> colors[:red, :blue] = :violet;

julia> colors[:yellow, :blue] = :green;
```

## Accessing graph properties

To retrieve graph properties, we still follow a dictionary-like interface based on labels.

### Existence

To check the presence of a vertex or edge, use `haskey`:

```jldoctest example
julia> haskey(colors, :red)
true

julia> haskey(colors, :black)
false

julia> haskey(colors, :red, :yellow) && haskey(colors, :yellow, :red)
true

julia> haskey(colors, :red, :black)
false
```

### Metadata

All kinds of metadata can be accessed with `getindex`:

```jldoctest example
julia> colors[]
"graph_of_colors"

julia> colors[:blue]
"cool"

julia> colors[:yellow, :blue]
:green
```

## Using vertex codes

In the absence of removal, vertex codes correspond to order of insertion in the underlying graph:

```jldoctest example
julia> code_for(colors, :red)
1

julia> code_for(colors, :blue)
3
```

You can retrieve the associated labels as follows:

```jldoctest example
julia> label_for(colors, 1)
:red

julia> label_for(colors, 3)
:blue
```

## Adding weights

The most simple way to add edge weights is to speficy a default weight for all of them.

```jldoctest example
julia> weighted_default = MetaGraph(Graph(), default_weight = 2);

julia> default_weight(weighted_default)
2

julia> weighttype(weighted_default)
Int64
```

You can use the `weight_function` keyword to specify a function which will transform edge metadata into a weight. This weight must always be the same type as the `default_weight`.

```jldoctest example
julia> weighted = MetaGraph(Graph(), EdgeData = Float64, weight_function = identity);

julia> weighted[:red] = nothing; weighted[:blue] = nothing; weighted[:yellow] = nothing;

julia> weighted[:red, :blue] = 1.0; weighted[:blue, :yellow] = 2.0;

julia> weight_matrix = Graphs.weights(weighted)
MetaWeights of size (3, 3)

julia> size(weight_matrix)
(3, 3)

julia> weight_matrix[1, 3]
1.0

julia> get_weight_function(weighted)(0)
0
```

You can then use all functions from Graphs.jl that require weighted graphs (see the rest of the tutorial).