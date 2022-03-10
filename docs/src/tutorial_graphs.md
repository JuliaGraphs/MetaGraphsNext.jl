# Graphs.jl  interface

```jldoctest graphs
julia> using Graphs

julia> using MetaGraphsNext
```

`MetaGraph`s inherit many methods from Graphs.jl. In general, inherited methods refer to vertices by codes, not labels, for compatibility with AbstractGraph. Vertex codes get reassigned after `rem_vertex!` to remain contiguous, so we recommend using labels if possible.

## Undirected graphs

```jldoctest graphs
julia> colors = MetaGraph(Graph(), VertexMeta = String, EdgeMeta = Symbol, gprops = "special");

julia> colors[:red] = "warm";

julia> colors[:yellow] = "warm";

julia> is_directed(colors)
false

julia> nv(zero(colors))
0

julia> ne(copy(colors))
0

julia> add_vertex!(colors, :white, "neutral")
true

julia> nv(colors)
3

julia> add_vertex!(colors, :white, "neutral")
false

julia> nv(colors)
3

julia> add_edge!(colors, 1, 3, :pink)
true

julia> rem_edge!(colors, 1, 3)
true

julia> rem_vertex!(colors, 3)
true

julia> rem_vertex!(colors, 3)
false

julia> eltype(colors) == Int
true

julia> edgetype(colors) == Edge{Int}
true

julia> vertices(colors)
Base.OneTo(2)

julia> has_edge(colors, 1, 2)
false

julia> has_vertex(colors, 1)
true

julia> Graphs.SimpleGraphs.fadj(colors, 1) == Int[]
true

julia> Graphs.SimpleGraphs.badj(colors, 1) == Int[]
true

julia> colors == colors
true

julia> issubset(colors, colors)
true

julia> SimpleGraph(colors)
{2, 0} undirected simple Int64 graph
```

## Directed graphs

You can seemlessly make MetaGraphs based on DiGraphs as well.

```jldoctest graphs
julia> rock_paper_scissors = MetaGraph(DiGraph(), Label = Symbol, EdgeMeta = Symbol);

julia> rock_paper_scissors[:rock] = nothing; rock_paper_scissors[:paper] = nothing; rock_paper_scissors[:scissors] = nothing;

julia> rock_paper_scissors[:rock, :scissors] = :rock_beats_scissors; rock_paper_scissors[:scissors, :paper] = :scissors_beats_paper; rock_paper_scissors[:paper, :rock] = :paper_beats_rock;

julia> is_directed(rock_paper_scissors)
true

julia> haskey(rock_paper_scissors, :scissors, :rock)
false

julia> haskey(reverse(rock_paper_scissors), :scissors, :rock)
true

julia> SimpleDiGraph(rock_paper_scissors)
{3, 3} directed simple Int64 graph

julia> sub_graph, _ = induced_subgraph(rock_paper_scissors, [1, 3]);

julia> haskey(sub_graph, :rock, :scissors)
true

julia> delete!(rock_paper_scissors, :paper);

julia> rock_paper_scissors[:rock, :scissors]
:rock_beats_scissors
```