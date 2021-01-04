module MetaGraphsNext
using LightGraphs
using JLD2

import Base:
    eltype,
    show,
    ==,
    Tuple,
    copy,
    length,
    size,
    issubset,
    zero,
    getindex,
    haskey,
    setindex!,
    delete!

import LightGraphs:
    AbstractGraph,
    edgetype,
    nv,
    ne,
    vertices,
    edges,
    is_directed,
    add_vertex!,
    add_edge!,
    rem_vertex!,
    rem_edge!,
    has_vertex,
    has_edge,
    inneighbors,
    outneighbors,
    weights,
    induced_subgraph,
    loadgraph,
    savegraph,
    AbstractGraphFormat,
    reverse

import LightGraphs.SimpleGraphs: SimpleGraph, SimpleDiGraph, fadj, badj

export MetaGraph, weighttype, defaultweight, weightfunction, MGFormat, DOTFormat, reverse

include("metagraph.jl")

function show(
    io::IO,
    g::MetaGraph{<:Any,Label,<:Any,VertexMeta,EdgeMeta},
) where {Label,VertexMeta,EdgeMeta}
    print(
        io,
        "Meta graph based on a $(g.graph) with vertices indexed by $Label(s), $VertexMeta(s) vertex metadata, $EdgeMeta(s) edge metadata, $(repr(g.gprops)) as graph metadata, and default weight $(g.defaultweight)",
    )
end

@inline fadj(g::MetaGraph, x...) = fadj(g.graph, x...)
@inline badj(g::MetaGraph, x...) = badj(g.graph, x...)


eltype(g::MetaGraph) = eltype(g.graph)
edgetype(g::MetaGraph) = edgetype(g.graph)
nv(g::MetaGraph) = nv(g.graph)
vertices(g::MetaGraph) = vertices(g.graph)

ne(g::MetaGraph) = ne(g.graph)
edges(g::MetaGraph) = edges(g.graph)

has_vertex(g::MetaGraph, x...) = has_vertex(g.graph, x...)
@inline has_edge(g::MetaGraph, x...) = has_edge(g.graph, x...)

inneighbors(g::MetaGraph, v::Integer) = inneighbors(g.graph, v)
outneighbors(g::MetaGraph, v::Integer) = fadj(g.graph, v)

issubset(g::T, h::T) where {T<:MetaGraph} = issubset(g.graph, h.graph)

"""
    add_edge!(g, u, v, val)

Add an edge `(u, v)` to MetaGraph `g` having value `val`.

Return true if the edge has been added, false otherwise.
"""
function add_edge!(g::MetaGraph, u::Integer, v::Integer, val)
    added = add_edge!(g.graph, u, v)
    if added
        metaindex = g.metaindex
        g.eprops[arrange(g, metaindex[u], metaindex[v], u, v)] = val
    end
    added
end

@inline function rem_edge!(g::MetaGraph, u::Integer, v::Integer)
    metaindex = g.metaindex
    removed = rem_edge!(g.graph, u, v)
    if removed
        delete!(g.eprops, arrange(g, metaindex[u], metaindex[v], u, v))
    end
    removed
end

"""
    add_vertex!(g, label, val)

Add a vertex to MetaGraph `g` with label `label` having value `val`.

Return true if the vertex has been added, false otherwise.
"""
function add_vertex!(g::MetaGraph, label, val)
    added = add_vertex!(g.graph)
    if added
        v = nv(g)
        g.vprops[label] = (v, val)
        g.metaindex[v] = label
    end
    added
end

function _rem_vertex!(g, label, v)
    vprops = g.vprops
    eprops = g.eprops
    metaindex = g.metaindex
    lastv = nv(g)
    for n in outneighbors(g, v)
        delete!(eprops, arrange(g, label, metaindex[n], v, n))
    end
    for n in inneighbors(g, v)
        delete!(eprops, arrange(g, metaindex[n], label, n, v))
    end
    removed = rem_vertex!(g.graph, v)
    if removed
        if v != lastv # ignore if we're removing the last vertex.
            lastl = metaindex[lastv]
            _, lastvprops = vprops[lastl]
            vprops[lastl] = v, lastvprops
            metaindex[v] = lastl
        end
        delete!(vprops, label)
        delete!(metaindex, lastv)
    end
    removed
end

function rem_vertex!(g::MetaGraph, v::Integer)
    exists = has_vertex(g, v)
    if exists
        _rem_vertex!(g, g.metaindex[v], v)
    else
        false
    end
end

struct MetaWeights{InnerMetaGraph,U<:Real} <: AbstractMatrix{U}
    meta_graph::InnerMetaGraph
end

show(io::IO, x::MetaWeights) = print(io, "metaweights")
show(io::IO, z::MIME"text/plain", x::MetaWeights) = show(io, x)

MetaWeights(g::MetaGraph) = MetaWeights{typeof(g),weighttype(g)}(g)

function getindex(w::MetaWeights, u::Int, v::Int)
    g = w.meta_graph
    metaindex = g.metaindex
    if has_edge(g, u, v)
        g.weightfunction(g[arrange(g, metaindex[u], metaindex[v], u, v)...])
    else
        g.defaultweight
    end
end

function size(d::MetaWeights)
    vertices = nv(d.meta_graph)
    (vertices, vertices)
end

weights(g::MetaGraph) = MetaWeights(g)

getindex(g::MetaGraph) = g.gprops
function getindex(g::MetaGraph, label)
    _, val = g.vprops[label]
    val
end
getindex(g::MetaGraph, label_1, label_2) = g.eprops[arrange(g, label_1, label_2)]

"""
    haskey(g, :label)

Determine whether a graph `g` contains the vertex `:label`.

```jldoctest; setup = :(using MetaGraphsNext; using LightGraphs: Graph)
julia> colors = MetaGraph(Graph(), VertexMeta = String, EdgeMeta = Symbol, gprops = "special");

julia> colors[:red] = "warm";

julia> haskey(colors, :red)
true

julia> haskey(colors, :blue)
false
```
"""
haskey(g::MetaGraph, label) = haskey(g.vprops, label)

"""
    haskey(g, :v1, :v2)

Determine whether a graph `g` contains an edge from `:v1` to `:v2`. The order of `:v1` and `:v2`
only matters if `g` is a digraph.

```jldoctest; setup = :(using MetaGraphsNext; using LightGraphs: Graph)
julia> colors = MetaGraph(Graph(), VertexMeta = String, EdgeMeta = Symbol, gprops = "special");

julia> colors[:red] = "warm"; colors[:blue] = "cool"; colors[:red, :blue] = :purple
:purple

julia> haskey(colors, :red, :blue) && haskey(colors, :blue, :red)
true

julia> haskey(colors, :red, :yellow)
false
```
"""
haskey(g::MetaGraph, label_1, label_2) = haskey(g, label_1) && haskey(g, label_2) && haskey(g.eprops, arrange(g, label_1, label_2))

function setindex!(g::MetaGraph, val, label)
    vprops = g.vprops
    v = if haskey(vprops, label)
        (v, _) = vprops[label]
        v
    else
        add_vertex!(g.graph)
        v = nv(g)
        g.metaindex[v] = label
        v
    end
    vprops[label] = (v, val)
    return nothing
end

function setindex!(g::MetaGraph, val, label_1, label_2)
    vprops = g.vprops
    u, _ = vprops[label_1]
    v, _ = vprops[label_2]
    add_edge!(g.graph, u, v)
    g.eprops[arrange(g, label_1, label_2, u, v)] = val
    return nothing
end

function delete!(g::MetaGraph, label)
    if haskey(g, label)
        v, _ = g.vprops[label]
        _rem_vertex!(g, label, v)
    end
    return nothing
end
function delete!(g::MetaGraph, label_1, label_2)
    vprops = g.vprops
    u, _ = vprops[label_1]
    v, _ = vprops[label_2]
    rem_edge!(g.graph, u, v)
    delete!(g.eprops, arrange(g, label_1, label_2, u, v))
    return nothing
end

"""
    weighttype(g)

Return the weight type for metagraph `g`.

```jldoctest
julia> using MetaGraphsNext

julia> using LightGraphs: Graph

julia> weighttype(MetaGraph(Graph(), defaultweight = 1.0))
Float64
```
"""
weighttype(g::MetaGraph{<:Any,<:Any,<:Any,<:Any,<:Any,<:Any,<:Any,Weight}) where {Weight} =
    Weight

"""
    weightfunction(g)

Return the weight function for metagraph `g`.

```jldoctest
julia> using MetaGraphsNext

julia> using LightGraphs: Graph

julia> weightfunction(MetaGraph(Graph(), weightfunction = identity))(0)
0
```
"""
weightfunction(g::MetaGraph) = g.weightfunction

"""
    defaultweight(g)

Return the default weight for metagraph `g`.

```jldoctest
julia> using MetaGraphsNext

julia> using LightGraphs: Graph

julia> defaultweight(MetaGraph(Graph(), defaultweight = 2))
2
```
"""
defaultweight(g::MetaGraph) = g.defaultweight

function _copy_props!(oldg::T, newg::T, vmap) where {T<:MetaGraph}
    for (newv, oldv) in enumerate(vmap)
        oldl = oldg.metaindex[oldv]
        _, meta = oldg.vprops[oldl]
        newg.metaindex[newv] = oldl
        newg.vprops[oldl] = (newv, meta)
    end
    for newe in edges(newg.graph)
        metaindex = newg.metaindex
        u, v = Tuple(newe)
        label_1 = metaindex[u]
        label_2 = metaindex[v]
        newg.eprops[arrange(newg, label_1, label_2, u, v)] =
            oldg.eprops[arrange(oldg, label_1, label_2)]
    end
    return nothing
end

function induced_subgraph(
    g::T,
    v::AbstractVector{U},
) where {T<:MetaGraph} where {U<:Integer}
    inducedgraph, vmap = induced_subgraph(g.graph, v)
    newg = MetaGraph(
        inducedgraph,
        empty(g.vprops),
        empty(g.eprops),
        g.gprops,
        g.weightfunction,
        g.defaultweight,
        empty(g.metaindex),
    )
    _copy_props!(g, newg, vmap)
    return newg, vmap
end

# TODO - would be nice to be able to apply a function to properties. Not sure
# how this might work, but if the property is a vector, a generic way to append to
# it would be a good thing.

==(x::MetaGraph, y::MetaGraph) = x.graph == y.graph

copy(g::T) where {T<:MetaGraph} = deepcopy(g)

"""
    code_for(meta::MetaGraph, vertex_label)

Find the code associated with a `vertex_label`. This can be useful to pass
to methods inherited from `LightGraphs`. Note, however, that vertex codes could be
reassigned after vertex deletion.

```jldoctest
julia> using MetaGraphsNext

julia> using LightGraphs: Graph

julia> meta = MetaGraph(Graph());

julia> meta[:a] = nothing

julia> code_for(meta, :a)
1
```
"""
function code_for(meta::MetaGraph, vertex_label)
    code, _ = meta.vprops[vertex_label]
    code
end
export code_for

"""
    label_for(meta::MetaGraph, vertex_code)

Find the label associated with a `vertex_code`. This can be useful to interpret the results of methods
inherited from `LightGraphs`. Note, however, that vertex codes could be reassigned after vertex deletion.

```jldoctest
julia> using MetaGraphsNext

julia> using LightGraphs: Graph

julia> meta = MetaGraph(Graph());

julia> meta[:a] = nothing

julia> label_for(meta, 1)
:a
```
"""
function label_for(meta::MetaGraph, vertex_code)
    meta.metaindex[vertex_code]
end
export label_for

include("metadigraph.jl")
include("overrides.jl")
include("persistence.jl")

end # module
