# Graphs.jl  interface

```jldoctest graphs
julia> using Graphs

julia> using MetaGraphsNext
```

`MetaGraph`s inherit many methods from Graphs.jl. In general, inherited methods refer to vertices by codes, not labels, for compatibility with the `AbstractGraph` interface.

Note that vertex codes get reassigned after `rem_vertex!` operations to remain contiguous, so we recommend systematically converting to and from labels.

## Undirected graphs

We can make `MetaGraph`s based on (undirected) `Graph`s.

```jldoctest graphs
julia> cities = MetaGraph(Graph(), VertexData = String, EdgeData = Int, weight_function = identity, default_weight = 0);
```

Let us add some cities and the distance between them:

```jldoctest graphs
julia> cities[:Paris] = "France";

julia> cities[:London] = "UK";

julia> cities[:Berlin] = "Germany";

julia> cities[:Paris, :London] = 344;

julia> cities[:Paris, :Berlin] = 878;
```

The general properties of the graph are as expected:

```jldoctest graphs
julia> is_directed(cities)
false

julia> eltype(cities)
Int64

julia> edgetype(cities)
Graphs.SimpleGraphs.SimpleEdge{Int64}

julia> SimpleGraph(cities)
{3, 2} undirected simple Int64 graph
```

We can check the set of vertices:

```jldoctest graphs
julia> nv(cities)
3

julia> Tuple(collect(vertices(cities)))
(1, 2, 3)

julia> has_vertex(cities, 2)
true

julia> has_vertex(cities, 4)
false
```

We then check the set of edges:

```jldoctest graphs
julia> ne(cities)
2

julia> Tuple(collect(edges(cities)))
(Edge 1 => 2, Edge 1 => 3)

julia> has_edge(cities, 1, 2)
true

julia> has_edge(cities, 2, 3)
false
```

From this initial graph, we can create some others:

```jldoctest graphs
julia> copy(cities) == cities
true

julia> zero(cities) == cities
false

julia> nv(zero(cities))
0
```

Since `cities` is a weighted graph, we can leverage the whole Graphs.jl machinery of graph analysis and traversal:

```jldoctest graphs
julia> diameter(cities)
1222

julia> ds = dijkstra_shortest_paths(cities, 2); Tuple(ds.dists)
(344, 0, 1222)
```

Finally, let us remove some edges and vertices

```jldoctest graphs
julia> rem_edge!(cities, 1, 3)
true

julia> rem_vertex!(cities, 3)
true

julia> rem_vertex!(cities, 3)
false

julia> has_vertex(cities, 1)
true

julia> has_vertex(cities, 3)
false
```

## Directed graphs

We can make `MetaGraph`s based on `DiGraph`s as well.

```jldoctest graphs
julia> rock_paper_scissors = MetaGraph(DiGraph(), Label = Symbol, EdgeData = Symbol);

julia> for label in [:rock, :paper, :scissors]; rock_paper_scissors[label] = nothing; end;

julia> rock_paper_scissors[:rock, :scissors] = :rock_beats_scissors; rock_paper_scissors[:scissors, :paper] = :scissors_beat_paper; rock_paper_scissors[:paper, :rock] = :paper_beats_rock;
```

We see that the underlying graph has changed:

```jldoctest graphs
julia> is_directed(rock_paper_scissors)
true

julia> SimpleDiGraph(rock_paper_scissors)
{3, 3} directed simple Int64 graph
```

Directed graphs can be reversed:

``` jldoctest graphs
julia> haskey(rock_paper_scissors, :scissors, :rock)
false

julia> haskey(reverse(rock_paper_scissors), :scissors, :rock)
true
```

Finally, let us take a subgraph:

```jldoctest graphs
julia> rock_paper, _ = induced_subgraph(rock_paper_scissors, [1, 2]);

julia> issubset(rock_paper, rock_paper_scissors)
true

julia> haskey(rock_paper, :paper, :rock)
true

julia> haskey(rock_paper, :rock, :scissors)
false
```