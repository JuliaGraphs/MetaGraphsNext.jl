struct MetaGraph{
    T<:Integer,
    Label,
    Graph,
    VertexMeta,
    EdgeMeta,
    GraphMeta,
    WeightFunction,
    U<:Real,
} <: AbstractGraph{T}
    graph::Graph
    vprops::Dict{Label,Tuple{T,VertexMeta}}
    eprops::Dict{Tuple{Label,Label},EdgeMeta}
    gprops::GraphMeta
    weightfunction::WeightFunction
    defaultweight::U
    metaindex::Dict{T,Label}
end

#= MetaGraph(
    g::Graph,
    vprops::Dict{Label,Tuple{T,VertexMeta}},
    eprops::Dict{Tuple{Label,Label},EdgeMeta},
    gprops::GraphMeta,
    weightfunction::WeightFunction,
    defaultweight::U,
    metaindex::Dict{T,Label}
) where {
    Label,
    T,
    Graph,
    VertexMeta,
    EdgeMeta,
    GraphMeta,
    WeightFunction,
    U,
} = MetaGraph{
    T,
    Label,
    Graph,
    VertexMeta,
    EdgeMeta,
    GraphMeta,
    WeightFunction,
    U
}(
    g,
    vprops,
    metaindex,
    eprops,
    gprops,
    weightfunction,
    defaultweight
)
=#

"""
    MetaGraph(g;
        Label = Symbol,
        VertexMeta = nothing,
        EdgeMeta = nothing,
        gprops = nothing,
        weightfunction = eprops -> 1.0,
        defaultweight = 1.0
    )

Construct a new meta graph based on `g`, where `Label` is the type of the vertex labels, `VertexMeta` is the type
of the metadata at a vertex, and `EdgeMeta` is the type of the metadata at an
edge. You can also attach arbitrary graph level metadata as `gprops`. It is recommended not
to set `Label` to `Int` to avoid confusion between vertex labels and codes.

```jldoctest example
julia> using LightGraphs

julia> using MetaGraphsNext

julia> colors = MetaGraph(Graph(), VertexMeta = Int, EdgeMeta = Symbol, gprops = "special")
Meta graph based on a {0, 0} undirected simple Int64 graph with vertices indexed by Symbol(s), Int64(s) vertex metadata, Symbol(s) edge metadata, "special" as graph metadata, and default weight 1.0
```

Use `setindex!` to add a new vertex with the given metadata.

```jldoctest example
julia> colors[:red] = 1;

julia> colors[:yellow] = 2;

julia> colors[:blue] = 3;
```

You can access and change the metadata using indexing: zero arguments for graph metadata,
one label for vertex metadata, and two labels for edge metadata.

```jldoctest example
julia> colors[]
"special"

julia> colors[:blue] = 4;

julia> colors[:blue]
4

julia> colors[:red, :yellow] = :orange;

julia> colors[:red, :yellow]
:orange
```

You can delete vertices and edges with `delete!`.

```jldoctest example
julia> delete!(colors, :red, :yellow);

julia> delete!(colors, :blue);
```

You can use the `weightfunction` keyword to specify a function which will
transform vertex metadata into a weight. This weight must always be the same
type as the `defaultweight`.

```jldoctest example
julia> weighted = MetaGraph(Graph(), EdgeMeta = Float64, weightfunction = identity);

julia> weighted[:red] = nothing; weighted[:blue] = nothing; weighted[:yellow] = nothing;

julia> weighted[:red, :blue] = 1.0; weighted[:blue, :yellow] = 2.0;

julia> the_weights = LightGraphs.weights(weighted)
metaweights

julia> size(the_weights)
(3, 3)

julia> the_weights[1, 3]
1.0

julia> diameter(weighted)
3.0
```

MetaGraphs inherit many methods from LightGraphs. In general, inherited methods refer to
vertices by codes, not labels.

```jldoctest example
julia> is_directed(colors)
false

julia> nv(zero(colors))
0

julia> ne(copy(colors))
0

julia> add_vertex!(colors, :white, 4)
true

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

julia> LightGraphs.SimpleGraphs.fadj(colors, 1) == Int[]
true

julia> LightGraphs.SimpleGraphs.badj(colors, 1) == Int[]
true

julia> colors == colors
true

julia> issubset(colors, colors)
true

julia> SimpleGraph(colors)
{2, 0} undirected simple Int64 graph
```

You can seemlessly make MetaGraphs based on DiGraphs as well.

```jldoctest example
julia> rock_paper_scissors = MetaGraph(DiGraph(), Label = Symbol, EdgeMeta = Symbol);

julia> rock_paper_scissors[:rock] = nothing; rock_paper_scissors[:paper] = nothing; rock_paper_scissors[:scissors] = nothing;

julia> rock_paper_scissors[:rock, :scissors] = :rock_beats_scissors; rock_paper_scissors[:scissors, :paper] = :scissors_beats_paper; rock_paper_scissors[:paper, :rock] = :paper_beats_rock;

julia> is_directed(rock_paper_scissors)
true

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
"""
function MetaGraph(
    g::AbstractGraph{T};
    Label = Symbol,
    VertexMeta = Nothing,
    EdgeMeta = Nothing,
    gprops = nothing,
    weightfunction = eprops -> 1.0,
    defaultweight = 1.0,
) where {Vertex,T}
    MetaGraph(
        g,
        Dict{Label,Tuple{T,VertexMeta}}(),
        Dict{Tuple{Label,Label},EdgeMeta}(),
        gprops,
        weightfunction,
        defaultweight,
        Dict{T,Label}(),
    )
end

const MetaUndirectedGraph = MetaGraph{<:Any,<:Any,<:SimpleGraph}

SimpleGraph(g::MetaUndirectedGraph) = g.graph

is_directed(::Type{<:MetaUndirectedGraph}) = false

function arrange(g::MetaUndirectedGraph, label_1, label_2)
    vprops = g.vprops
    arrange(g::MetaUndirectedGraph, label_1, label_2, vprops[label_1], vprops[label_2])
end

function arrange(g::MetaUndirectedGraph, label_1, label_2, u, v)
    if u > v
        (label_2, label_1)
    else
        (label_1, label_2)
    end
end

zero(
    g::MetaGraph{T,Label,Graph,VertexMeta,EdgeMeta,GraphMeta},
) where {T,Label,Graph,VertexMeta,EdgeMeta,GraphMeta} = MetaGraph(
    Graph();
    Label = Label,
    VertexMeta = VertexMeta,
    EdgeMeta = EdgeMeta,
    gprops = g.gprops,
    weightfunction = g.weightfunction,
    defaultweight = g.defaultweight,
)
