## Basic Graphs.jl interface

function Base.eltype(::Type{<:MetaGraph{Code}}) where {Code}
    return Code
end
function Base.eltype(::MetaGraphType) where {MetaGraphType<:MetaGraph}
    return eltype(MetaGraphType)
end

function Graphs.edgetype(meta_graph::MetaGraph)
    return edgetype(meta_graph.graph)
end

function Graphs.nv(meta_graph::MetaGraph)
    return nv(meta_graph.graph)
end

function Graphs.ne(meta_graph::MetaGraph)
    return ne(meta_graph.graph)
end

function Graphs.vertices(meta_graph::MetaGraph)
    return vertices(meta_graph.graph)
end

function Graphs.edges(meta_graph::MetaGraph)
    return edges(meta_graph.graph)
end

function Graphs.has_vertex(meta_graph::MetaGraph, code::Integer)
    return has_vertex(meta_graph.graph, code)
end

function Graphs.has_edge(meta_graph::MetaGraph, code_1::Integer, code_2::Integer)
    return has_edge(meta_graph.graph, code_1, code_2)
end

function Graphs.inneighbors(meta_graph::MetaGraph, code::Integer)
    return inneighbors(meta_graph.graph, code)
end

function Graphs.outneighbors(meta_graph::MetaGraph, code::Integer)
    return outneighbors(meta_graph.graph, code)
end

function Graphs.all_neighbors(meta_graph::MetaGraph, code::Integer)
    return all_neighbors(meta_graph.graph, code)
end

function Base.issubset(meta_graph::MetaGraph, h::MetaGraph)
    # no checking of: matching vertex label, or matching edge data
    return issubset(meta_graph.graph, h.graph)
end

## List labels

"""
    labels(meta_graph)

Iterate through all vertex labels, in the same order as the codes obtained by `vertices(meta_graph)`.
"""
function labels(meta_graph::MetaGraph)
    return (label_for(meta_graph, code) for code in vertices(meta_graph))
end

"""
    edge_labels(meta_graph)

Iterate through all tuples of edge labels, in the same order as the tuples of codes obtained by `edges(meta_graph)`.
"""
function edge_labels(meta_graph::MetaGraph)
    return (
        (label_for(meta_graph, src(ed)), label_for(meta_graph, dst(ed))) for
        ed in edges(meta_graph)
    )
end

"""
    neighbor_labels(meta_graph, label)

Iterate through all labels of neighbors of the vertex `code` with label `label`, in the same order as the codes obtained by `neighbors(meta_graph, code)`.
"""
function neighbor_labels(meta_graph::MetaGraph, label)
    code_1 = code_for(meta_graph, label)
    return (label_for(meta_graph, code_2) for code_2 in neighbors(meta_graph, code_1))
end

"""
    outneighbor_labels(meta_graph, label)

Iterate through all labels of outneighbors of the vertex `code` with label `label`, in the same order as the codes obtained by `outneighbors(meta_graph, code)`.
"""
function outneighbor_labels(meta_graph::MetaGraph, label)
    code_1 = code_for(meta_graph, label)
    return (label_for(meta_graph, code_2) for code_2 in outneighbors(meta_graph, code_1))
end

"""
    inneighbor_labels(meta_graph, label)

Iterate through all labels of inneighbors of the vertex `code` with label `label`, in the same order as the codes obtained by `inneighbors(meta_graph, code)`.
"""
function inneighbor_labels(meta_graph::MetaGraph, label)
    code_2 = code_for(meta_graph, label)
    return (label_for(meta_graph, code_1) for code_1 in inneighbors(meta_graph, code_2))
end

"""
    all_neighbor_labels(meta_graph, label)

Iterate through all labels of all neighbors of the vertex `code` with label `label`, in the same order as the codes obtained by `all_neighbors(meta_graph, code)`.
"""
function all_neighbor_labels(meta_graph::MetaGraph, label)
    code_1 = code_for(meta_graph, label)
    return (label_for(meta_graph, code_2) for code_2 in all_neighbors(meta_graph, code_1))
end

## Set vertex and edge data

"""
    set_data!(meta_graph, label, data)

Set vertex metadata for `label` to `data`.

Return `true` if the operation succeeds, and `false` if `meta_graph` has no such vertex.
"""
function set_data!(meta_graph::MetaGraph, label, data)
    if haskey(meta_graph.vertex_properties, label)
        code, _ = meta_graph.vertex_properties[label]
        meta_graph.vertex_properties[label] = (code, data)
        return true
    else
        return false
    end
end

"""
    set_data!(meta_graph, label_1, label_2, data)

Set edge metadata for `(label_1, label_2)` to `data`.

Return `true` if the operation succeeds, and `false` if `meta_graph` has no such edge.
"""
function set_data!(meta_graph::MetaGraph, label_1, label_2, data)
    edge_labels = arrange(meta_graph, label_1, label_2)
    present = haskey(meta_graph.edge_data, edge_labels)
    if present
        meta_graph.edge_data[edge_labels] = data
    end
    return present
end

## Add vertices and edges with labels

"""
    add_vertex!(meta_graph, label, data)

Add a vertex to MetaGraph `meta_graph` with label `label` having metadata `data`.
If the `VertexData` type of `meta_graph` is `Nothing`, `data` can be omitted.

Return true if the vertex has been added, false in case the label already exists or vertex was not added.
"""
function Graphs.add_vertex!(meta_graph::MetaGraph, label, data)
    if haskey(meta_graph, label)
        return false
    end
    nv_prev = nv(meta_graph.graph)
    code = nv_prev + 1
    meta_graph.vertex_labels[code] = label
    meta_graph.vertex_properties[label] = (code, data)
    add_vertex!(meta_graph.graph)
    if nv(meta_graph.graph) == nv_prev  # undo
        delete!(meta_graph.vertex_labels, code)
        delete!(meta_graph.vertex_properties, label)
        return false
    else
        return true
    end
end

function Graphs.add_vertex!(meta_graph::MetaGraph{<:Any,<:Any,<:Any,Nothing}, label)
    return Graphs.add_vertex!(meta_graph, label, nothing)
end

"""
    add_edge!(meta_graph, label_1, label_2, data)

Add an edge `(label_1, label_2)` to MetaGraph `meta_graph` with metadata `data`.
If the `EdgeData` type of `meta_graph` is `Nothing`, `data` can be omitted.

Return `true` if the edge has been added, `false` otherwise.
If one of the labels does not exist, nothing happens and `false` is returned (the label is not inserted).
If `(label_1, label_2)` already exists, its data is updated to `data` and `false` is returned nonetheless.
"""
function Graphs.add_edge!(meta_graph::MetaGraph, label_1, label_2, data)
    if !haskey(meta_graph, label_1) || !haskey(meta_graph, label_2)
        return false
    end
    code_1, code_2 = code_for(meta_graph, label_1), code_for(meta_graph, label_2)
    label_tup = arrange(meta_graph, label_1, label_2)
    meta_graph.edge_data[label_tup] = data
    if has_edge(meta_graph.graph, code_1, code_2)
        return false
    end
    ne_prev = ne(meta_graph.graph)
    add_edge!(meta_graph.graph, code_1, code_2)
    if ne(meta_graph.graph) == ne_prev  # undo
        delete!(meta_graph.edge_data, label_tup)
        return false
    else
        return true
    end
end

function Graphs.add_edge!(
    meta_graph::MetaGraph{<:Any,<:Any,<:Any,<:Any,Nothing}, label_1, label_2
)
    return Graphs.add_edge!(meta_graph, label_1, label_2, nothing)
end

## Remove vertex

function _rem_vertex!(meta_graph::MetaGraph, label, code)
    vertex_labels = meta_graph.vertex_labels
    vertex_properties = meta_graph.vertex_properties
    edge_data = meta_graph.edge_data
    last_vertex_code = nv(meta_graph)
    for out_neighbor in outneighbors(meta_graph, code)
        delete!(edge_data, arrange(meta_graph, label, vertex_labels[out_neighbor]))
    end
    for in_neighbor in inneighbors(meta_graph, code)
        delete!(edge_data, arrange(meta_graph, vertex_labels[in_neighbor], label))
    end
    removed = rem_vertex!(meta_graph.graph, code)
    if removed
        if code != last_vertex_code # ignore if we're removing the last vertex.
            last_label = vertex_labels[last_vertex_code]
            _, last_data = vertex_properties[last_label]
            vertex_labels[code] = last_label
            vertex_properties[last_label] = code, last_data
        end
        delete!(vertex_labels, last_vertex_code)
        delete!(vertex_properties, label)
    end
    return removed
end

## Remove vertices and edges based on codes

function Graphs.rem_vertex!(meta_graph::MetaGraph, code::Integer)
    if has_vertex(meta_graph, code)
        label = label_for(meta_graph, code)
        _rem_vertex!(meta_graph, label, code)
    else
        false
    end
end

function Graphs.rem_edge!(meta_graph::MetaGraph, code_1::Integer, code_2::Integer)
    removed = rem_edge!(meta_graph.graph, code_1, code_2)
    if removed # assume that vertex codes were not modified by edge removal
        label_1, label_2 = label_for(meta_graph, code_1), label_for(meta_graph, code_2)
        delete!(meta_graph.edge_data, arrange(meta_graph, label_1, label_2))
    end
    return removed
end

## Miscellaneous

function Base.copy(meta_graph::MetaGraph)
    return deepcopy(meta_graph)
end

function Base.zero(meta_graph::MetaGraph)
    return MetaGraph(
        zero(meta_graph.graph),
        empty(meta_graph.vertex_labels),
        empty(meta_graph.vertex_properties),
        empty(meta_graph.edge_data),
        deepcopy(meta_graph.graph_data),
        deepcopy(meta_graph.weight_function),
        deepcopy(meta_graph.default_weight),
    )
end

function meta_induced_subgraph(meta_graph::MetaGraph, selector)
    inducedgraph, code_map = induced_subgraph(meta_graph.graph, selector)
    new_graph = MetaGraph(
        inducedgraph,
        empty(meta_graph.vertex_labels),
        empty(meta_graph.vertex_properties),
        empty(meta_graph.edge_data),
        meta_graph.graph_data,
        meta_graph.weight_function,
        meta_graph.default_weight,
    )
    _copy_props!(meta_graph, new_graph, code_map)
    return new_graph, code_map
end

function Graphs.induced_subgraph(
    meta_graph::MetaGraph, vertex_codes::AbstractVector{<:Integer}
)
    return meta_induced_subgraph(meta_graph, vertex_codes)
end

function Graphs.induced_subgraph(
    meta_graph::MetaGraph, edges::AbstractVector{<:AbstractEdge}
)
    # separate method to avoid dispatch ambiguity
    return meta_induced_subgraph(meta_graph, edges)
end

@traitfn function Graphs.reverse(meta_graph::MG) where {MG <: MetaGraph; IsDirected{MG}}
    edge_data = meta_graph.edge_data
    reverse_edge_data = empty(edge_data)
    for (label_1, label_2) in keys(edge_data)
        reverse_edge_data[(label_2, label_1)] = edge_data[(label_1, label_2)]
    end
    return MetaGraph(
        reverse(meta_graph.graph),
        copy(meta_graph.vertex_labels),
        copy(meta_graph.vertex_properties),
        reverse_edge_data,
        meta_graph.graph_data,
        meta_graph.weight_function,
        meta_graph.default_weight,
    )
end
