# Working with metagraphs

```jldoctest example
julia> using Graphs

julia> using MetaGraphsNext
```

## Creating a `MetaGraph`

We provide a default constructor in which you only need to specify types:

```jldoctest example
julia> colors = MetaGraph(Graph(), VertexMeta = String, EdgeMeta = Symbol, gprops = "special")
Meta graph based on a {0, 0} undirected simple Int64 graph with vertices indexed by Symbol(s), vertex metadata of type String, edge metadata of type Symbol, graph metadata given by "special", and default weight 1.0
```

## Adding and modifying vertices

Use `setindex!` (as you would do with a dictionary) to add a new vertex with the given metadata. If a vertex with the given label does not exist, it will be created automatically. Otherwise, `setindex!` will modify the metadata for the existing vertex.

```jldoctest example
julia> colors[:red] = "warm";

julia> colors[:yellow] = "warm";

julia> colors[:blue] = "cool";
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

## Accessing metadata

You can access and change the metadata using indexing: zero arguments for graph metadata, one label for vertex metadata, and two labels for edge metadata.

```jldoctest example
julia> colors[]
"special"

julia> colors[:blue] = "very cool";

julia> colors[:blue]
"very cool"

julia> colors[:red, :yellow] = :orange;

julia> colors[:red, :yellow]
:orange
```

Checking the presence of a vertex or edge can be done with `haskey`:

```jldoctest example
julia> haskey(colors, :red)
true

julia> haskey(colors, :green)
false

julia> haskey(colors, :red, :yellow)
true

julia> haskey(colors, :yellow, :red) # undirected graph, so vertex order doesn't matter
true

julia> haskey(colors, :red, :green)
false
```

## Deleting vertices and edges

You can delete vertices and edges with `delete!`.

```jldoctest example
julia> delete!(colors, :red, :yellow);

julia> delete!(colors, :blue);
```

## Adding weights

The most simple way to add edge weights is to speficy a default weight for all of them.

```jldoctest example
julia> defaultweight(MetaGraph(Graph(), defaultweight = 2))
2

julia> weighttype(MetaGraph(Graph(), defaultweight = 2))
Int64
```

You can use the `weightfunction` keyword to specify a function which will transform edge metadata into a weight. This weight must always be the same type as the `defaultweight`.

```jldoctest example
julia> weighted = MetaGraph(Graph(), EdgeMeta = Float64, weightfunction = identity);

julia> weighted[:red] = nothing; weighted[:blue] = nothing; weighted[:yellow] = nothing;

julia> weighted[:red, :blue] = 1.0; weighted[:blue, :yellow] = 2.0;

julia> the_weights = Graphs.weights(weighted)
MetaWeights of size (3, 3)

julia> size(the_weights)
(3, 3)

julia> the_weights[1, 3]
1.0

julia> diameter(weighted)
3.0

julia> weightfunction(weighted)(0)
0
```