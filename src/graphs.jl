## Basic Graphs.jl interface

Base.eltype(::MetaGraph{T}) where {T} = T
Graphs.edgetype(g::MetaGraph) = edgetype(g.graph)
Graphs.nv(g::MetaGraph) = nv(g.graph)
Graphs.ne(g::MetaGraph) = ne(g.graph)
Graphs.vertices(g::MetaGraph) = vertices(g.graph)
Graphs.edges(g::MetaGraph) = edges(g.graph)

Graphs.has_vertex(g::MetaGraph, v::Integer) = has_vertex(g.graph, v)
Graphs.has_edge(g::MetaGraph, v1::Integer, v2::Integer) = has_edge(g.graph, v1, v2)

Graphs.inneighbors(g::MetaGraph, v::Integer) = inneighbors(g.graph, v)
Graphs.outneighbors(g::MetaGraph, v::Integer) = outneighbors(g.graph, v)

Base.issubset(g::G, h::G) where {G<:MetaGraph} = issubset(g.graph, h.graph)

## Link between graph codes and metagraph labels

"""
    code_for(g::MetaGraph, label)

Find the vertex code (or index) associated with label `label`.

This can be useful to pass to methods inherited from `Graphs`. Note, however, that vertex codes can be reassigned after vertex deletion.
"""
code_for(g::MetaGraph, label) = g.vertex_codes[label]

"""
    label_for(g::MetaGraph, v)

Find the label associated with code `v`.

This can be useful to interpret the results of methods inherited from `Graphs`. Note, however, that vertex codes can be reassigned after vertex deletion.
"""
label_for(g::MetaGraph, v::Integer) = g.vertex_labels[v]

## Set vertex and edge data

"""
    set_data!(g, label, data)

Set vertex metadata for `label` to `data`.

Return `true` if the operation succeeds, and `false` if `g` has no such vertex.
"""
function set_data!(g::MetaGraph, label, data)
    if haskey(g.vertex_data, label)
        g.vertex_data[label] = data
        return true
    else
        return false
    end
end

"""
    set_data!(g, label_1, label_2, data)

Set edge metadata for `(label_1, label_2)` to `data`.

Return `true` if the operation succeeds, and `false` if `g` has no such edge.
"""
function set_data!(g::MetaGraph, label_1, label_2, data)
    edge_labels = arrange(g, label_1, label_2)
    if haskey(g.edge_data, edge_labels)
        g.edge_data[edge_labels] = data
        return true
    else
        return false
    end
end

## Add vertices and edges with labels

"""
    add_vertex!(g, label, data)

Add a vertex to MetaGraph `g` with label `label` having metadata `data`.

Return true if the vertex has been added, false otherwise.
"""
function Graphs.add_vertex!(g::MetaGraph, label, data)
    added = add_vertex!(g.graph)
    if added
        v = nv(g)
        g.vertex_labels[v] = label
        g.vertex_codes[label] = v
        g.vertex_data[label] = data
    end
    return added
end

"""
    add_edge!(g, label_1, label_2, data)

Add an edge `(label_1, label_2)` to MetaGraph `g` with metadata `data`.

Return `true` if the edge has been added, `false` otherwise.
"""
function Graphs.add_edge!(g::MetaGraph, label_1, label_2, data)
    v1, v2 = code_for(g, label_1), code_for(g, label_2)
    added = add_edge!(g.graph, v1, v2)
    if added
        g.edge_data[arrange(g, label_1, label_2, v1, v2)] = data
    end
    return added
end

## Remove vertex

function _rem_vertex!(g::MetaGraph, label, v)
    vertex_labels = g.vertex_labels
    vertex_codes = g.vertex_codes
    vertex_data = g.vertex_data
    edge_data = g.edge_data
    lastv = nv(g)
    for n in outneighbors(g, v)
        delete!(edge_data, arrange(g, label, vertex_labels[n], v, n))
    end
    for n in inneighbors(g, v)
        delete!(edge_data, arrange(g, vertex_labels[n], label, n, v))
    end
    removed = rem_vertex!(g.graph, v)
    if removed
        if v != lastv # ignore if we're removing the last vertex.
            lastl = vertex_labels[lastv]
            lastvprop = vertex_data[lastl]
            vertex_labels[v] = lastl
            vertex_codes[lastl] = v
            vertex_data[lastl] = lastvprop
        end
        delete!(vertex_data, label)
        delete!(vertex_labels, lastv)
    end
    return removed
end

## Remove vertices and edges based on codes

function Graphs.rem_vertex!(g::MetaGraph, v::Integer)
    if has_vertex(g, v)
        label = label_for(g, v)
        return _rem_vertex!(g, label, v)
    else
        return false
    end
end

function Graphs.rem_edge!(g::MetaGraph, v1::Integer, v2::Integer)
    removed = rem_edge!(g.graph, v1, v2)
    if removed
        label_1, label_2 = label_for(g, v1), label_for(g, v2)
        delete!(g.edge_data, arrange(g, label_1, label_2, v1, v2))
    end
    return removed
end

## Miscellaneous

function Graphs.induced_subgraph(
    g::G, v::AbstractVector{U}
) where {G<:MetaGraph} where {U<:Integer}
    inducedgraph, vmap = induced_subgraph(g.graph, v)
    newg = MetaGraph(
        inducedgraph,
        empty(g.vertex_labels),
        empty(g.vertex_codes),
        empty(g.vertex_data),
        empty(g.edge_data),
        g.graph_data,
        g.weight_function,
        g.default_weight,
    )
    _copy_props!(g, newg, vmap)
    return newg, vmap
end

function Graphs.reverse(g::MetaDiGraph)
    rg = reverse(g.graph)
    rvertex_labels = copy(g.vertex_labels)
    rvertex_codes = copy(g.vertex_codes)
    rvertex_data = copy(g.vertex_data)
    redge_data = empty(g.edge_data)
    rgraph_data = g.graph_data
    rweight_function = g.weight_function
    rdefault_weight = g.default_weight

    for (u, v) in keys(g.edge_data)
        redge_data[(v, u)] = g.edge_data[(u, v)]
    end

    rg = MetaGraph(
        rg,
        rvertex_labels,
        rvertex_codes,
        rvertex_data,
        redge_data,
        rgraph_data,
        rweight_function,
        rdefault_weight,
    )

    return rg
end
