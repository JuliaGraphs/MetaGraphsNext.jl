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

function Base.issubset(meta_graph::MetaGraph, h::MetaGraph)
    return issubset(meta_graph.graph, h.graph)
end

function Graphs.is_directed(
    ::MetaGraph{Code,Label,Graph}
) where {Code,Label,Graph<:AbstractGraph}
    return is_directed(Graph)
end

function Graphs.is_directed(
    ::Type{<:MetaGraph{Code,Label,Graph}}
) where {Code,Label,Graph<:AbstractGraph}
    return is_directed(Graph)
end

## Link between graph codes and metagraph labels

"""
    code_for(meta_graph::MetaGraph, label)

Find the vertex code (or index) associated with label `label`.

This can be useful to pass to methods inherited from `Graphs`. Note, however, that vertex codes can be reassigned after vertex deletion.
"""
function code_for(meta_graph::MetaGraph, label)
    return meta_graph.vertex_properties[label][1]
end

"""
    label_for(meta_graph::MetaGraph, code)

Find the label associated with code `code`.

This can be useful to interpret the results of methods inherited from `Graphs`. Note, however, that vertex codes can be reassigned after vertex deletion.
"""
function label_for(meta_graph::MetaGraph, code::Integer)
    return meta_graph.vertex_labels[code]
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

Return true if the vertex has been added, false incase the label already exists or vertex was not added.
"""
function Graphs.add_vertex!(meta_graph::MetaGraph, label, data)
    if haskey(meta_graph, label)
        return false
    end
    added = add_vertex!(meta_graph.graph)
    if added
        code = nv(meta_graph)
        meta_graph.vertex_labels[code] = label
        meta_graph.vertex_properties[label] = (code, data)
    end
    return added
end

"""
    add_edge!(meta_graph, label_1, label_2, data)

Add an edge `(label_1, label_2)` to MetaGraph `meta_graph` with metadata `data`.

Return `true` if the edge has been added, `false` otherwise.
"""
function Graphs.add_edge!(meta_graph::MetaGraph, label_1, label_2, data)
    code_1, code_2 = code_for(meta_graph, label_1), code_for(meta_graph, label_2)
    added = add_edge!(meta_graph.graph, code_1, code_2)
    if added
        meta_graph.edge_data[arrange(meta_graph, label_1, label_2, code_1, code_2)] = data
    end
    return added
end

## Remove vertex

function _rem_vertex!(meta_graph::MetaGraph, label, code)
    vertex_labels = meta_graph.vertex_labels
    vertex_properties = meta_graph.vertex_properties
    edge_data = meta_graph.edge_data
    last_vertex_code = nv(meta_graph)
    for out_neighbor in outneighbors(meta_graph, code)
        delete!(
            edge_data,
            arrange(meta_graph, label, vertex_labels[out_neighbor], code, out_neighbor),
        )
    end
    for in_neighbor in inneighbors(meta_graph, code)
        delete!(
            edge_data,
            arrange(meta_graph, vertex_labels[in_neighbor], label, in_neighbor, code),
        )
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
    if removed
        label_1, label_2 = label_for(meta_graph, code_1), label_for(meta_graph, code_2)
        delete!(meta_graph.edge_data, arrange(meta_graph, label_1, label_2, code_1, code_2))
    end
    return removed
end

## Miscellaneous

function Graphs.induced_subgraph(
    meta_graph::MetaGraph, vertex_codes::AbstractVector{<:Integer}
)
    inducedgraph, code_map = induced_subgraph(meta_graph.graph, vertex_codes)
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

@traitfn function Graphs.reverse(meta_graph::MetaGraph::IsDirected)
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
