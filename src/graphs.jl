
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
outneighbors(g::MetaGraph, v::Integer) = fadj(g.graph, v)  # TODO: why not outneighbors?

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

Return true if the vertex has been added, false incase the label already exists or edge was not added.
"""
function add_vertex!(g::MetaGraph, label, val)
    added = add_vertex!(g.graph)
    if g.haskey(label)
        return false
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
