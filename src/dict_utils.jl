"""
    getindex(g)

Return graph metadata.
"""
Base.getindex(g::MetaGraph) = g.gprops

"""
    getindex(g, label)

Return vertex metadata for `label`.
"""
Base.getindex(g::MetaGraph, label) = g.vprops[label]

"""
    getindex(g, label_1, label_2)

Return edge metadata for the edge between `label_1` and `label_2`.
"""
Base.getindex(g::MetaGraph, label_1, label_2) = g.eprops[arrange(g, label_1, label_2)]

"""
    haskey(g, label)

Determine whether a graph `g` contains the vertex `label`.
"""
Base.haskey(g::MetaGraph, label) = haskey(g.vprops, label)

"""
    haskey(g, label_1, label_2)

Determine whether a graph `g` contains an edge from `label_1` to `label_2`.

The order of `label_1` and `label_2` only matters if `g` is a digraph.
"""
function Base.haskey(g::MetaGraph, label_1, label_2)
    return (
        haskey(g, label_1) &&
        haskey(g, label_2) &&
        haskey(g.eprops, arrange(g, label_1, label_2))
    )
end

"""
    setindex!(g, data, label)

Set vertex metadata for `label` to `data`.
"""
function Base.setindex!(g::MetaGraph, data, label)
    if haskey(g, label)
        set_data!(g, label, data)
    else
        add_vertex!(g, label, data)
    end
    return nothing
end

"""
    setindex!(g, data, label_1, label_2)

Set edge metadata for `(label_1, label_2)` to `data`.
"""
function Base.setindex!(g::MetaGraph, data, label_1, label_2)
    if haskey(g, label_1, label_2)
        set_data!(g, label_1, label_2, data)
    else
        add_edge!(g, label_1, label_2, data)
    end
    return nothing
end

"""
    delete!(g, label)

Delete vertex `label`.
"""
function Base.delete!(g::MetaGraph, label)
    if haskey(g, label)
        v = code_for(g, label)
        _rem_vertex!(g, label, v)
    end
    return nothing
end

"""
    delete!(g, label_1, label_2)

Delete edge `(label_1, label_2)`.
"""
function Base.delete!(g::MetaGraph, label_1, label_2)
    v1, v2 = code_for(g, label_1), code_for(g, label_2)
    rem_edge!(g, v1, v2)
    return nothing
end

"""
    _copy_props!(oldg, newg, vmap)

Copy properties from `oldg` to `newg` following vertex map `vmap`.
"""
function _copy_props!(oldg::G, newg::G, vmap) where {G<:MetaGraph}
    for (newv, oldv) in enumerate(vmap)
        oldl = oldg.labels[oldv]
        data = oldg.vprops[oldl]
        newg.labels[newv] = oldl
        newg.vcodes[oldl] = newv
        newg.vprops[oldl] = data
    end
    for newe in edges(newg.graph)
        labels = newg.labels
        v1, v2 = Tuple(newe)
        label_1 = labels[v1]
        label_2 = labels[v2]
        newg.eprops[arrange(newg, label_1, label_2, v1, v2)] = oldg.eprops[arrange(
            oldg, label_1, label_2
        )]
    end
    return nothing
end

# TODO - It would be nice to be able to apply a function to properties.
# Not sure how this might work, but if the property is a vector,
# a generic way to append to it would be a good thing.
