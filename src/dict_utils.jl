"""
    getindex(meta_graph)

Return meta_graph metadata.
"""
function Base.getindex(meta_graph::MetaGraph)
    return meta_graph.graph_data
end

"""
    getindex(meta_graph, label)

Return vertex metadata for `label`.
"""
function Base.getindex(meta_graph::MetaGraph, label)
    return meta_graph.vertex_properties[label][2]
end

"""
    getindex(meta_graph, label_1, label_2)

Return edge metadata for the edge between `label_1` and `label_2`.
"""
function Base.getindex(meta_graph::MetaGraph, label_1, label_2)
    return meta_graph.edge_data[arrange(meta_graph, label_1, label_2)]
end

"""
    haskey(meta_graph, label)

Determine whether a meta_graph `meta_graph` contains the vertex `label`.
"""
function Base.haskey(meta_graph::MetaGraph, label)
    return haskey(meta_graph.vertex_properties, label)
end

"""
    haskey(meta_graph, label_1, label_2)

Determine whether a meta_graph `meta_graph` contains an edge from `label_1` to `label_2`.

The order of `label_1` and `label_2` only matters if `meta_graph` is a digraph.
"""
function Base.haskey(meta_graph::MetaGraph, label_1, label_2)
    return haskey(meta_graph, label_1) &&
           haskey(meta_graph, label_2) &&
           haskey(meta_graph.edge_data, arrange(meta_graph, label_1, label_2))
end

"""
    setindex!(meta_graph, data, label)

Set vertex metadata for `label` to `data`.
"""
function Base.setindex!(meta_graph::MetaGraph, data, label)
    if haskey(meta_graph, label)
        set_data!(meta_graph, label, data)
    else
        add_vertex!(meta_graph, label, data)
    end
    return nothing
end

"""
    setindex!(meta_graph, data, label_1, label_2)

Set edge metadata for `(label_1, label_2)` to `data`.
"""
function Base.setindex!(meta_graph::MetaGraph, data, label_1, label_2)
    if haskey(meta_graph, label_1, label_2)
        set_data!(meta_graph, label_1, label_2, data)
    else
        add_edge!(meta_graph, label_1, label_2, data)
    end
    return nothing
end

"""
    delete!(meta_graph, label)

Delete vertex `label`.
"""
function Base.delete!(meta_graph::MetaGraph, label)
    if haskey(meta_graph, label)
        _rem_vertex!(meta_graph, label, code_for(meta_graph, label))
    end
    return nothing
end

"""
    delete!(meta_graph, label_1, label_2)

Delete edge `(label_1, label_2)`.
"""
function Base.delete!(meta_graph::MetaGraph, label_1, label_2)
    rem_edge!(meta_graph, code_for(meta_graph, label_1), code_for(meta_graph, label_2))
    return nothing
end

"""
    _copy_props!(old_meta_graph, new_meta_graph, code_map)

Copy properties from `old_meta_graph` to `new_meta_graph` following vertex map `code_map`.
"""
function _copy_props!(old_meta_graph::MetaGraph, new_meta_graph::MetaGraph, code_map)
    for (new_code, old_code) in enumerate(code_map)
        old_label = old_meta_graph.vertex_labels[old_code]
        _, data = old_meta_graph.vertex_properties[old_label]
        new_meta_graph.vertex_labels[new_code] = old_label
        new_meta_graph.vertex_properties[old_label] = (new_code, data)
    end
    for new_edge in edges(new_meta_graph.graph)
        vertex_labels = new_meta_graph.vertex_labels
        code_1, code_2 = Tuple(new_edge)
        label_1 = vertex_labels[code_1]
        label_2 = vertex_labels[code_2]
        new_meta_graph.edge_data[arrange(new_meta_graph, label_1, label_2, code_1, code_2)] = old_meta_graph.edge_data[arrange(
            old_meta_graph, label_1, label_2
        )]
    end
    return nothing
end
