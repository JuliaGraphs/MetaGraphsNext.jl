getindex(g::MetaGraph) = g.gprops

function getindex(g::MetaGraph, label)
    _, val = g.vprops[label]
    val
end

getindex(g::MetaGraph, label_1, label_2) = g.eprops[arrange(g, label_1, label_2)]

"""
    haskey(g, :label)

Determine whether a graph `g` contains the vertex `:label`.
"""
haskey(g::MetaGraph, label) = haskey(g.vprops, label)

"""
    haskey(g, :v1, :v2)

Determine whether a graph `g` contains an edge from `:v1` to `:v2`. The order of `:v1` and `:v2` only matters if `g` is a digraph.
"""
function haskey(g::MetaGraph, label_1, label_2)
    return (
        haskey(g, label_1) &&
        haskey(g, label_2) &&
        haskey(g.eprops, arrange(g, label_1, label_2))
    )
end

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

# TODO - would be nice to be able to apply a function to properties. Not sure
# how this might work, but if the property is a vector, a generic way to append to
# it would be a good thing.

"""
    code_for(meta::MetaGraph, vertex_label)

Find the code associated with a `vertex_label`. This can be useful to pass to methods inherited from `Graphs`. Note, however, that vertex codes could be
reassigned after vertex deletion.
"""
function code_for(meta::MetaGraph, vertex_label)
    code, _ = meta.vprops[vertex_label]
    code
end

"""
    label_for(meta::MetaGraph, vertex_code)

Find the label associated with a `vertex_code`. This can be useful to interpret the results of methods inherited from `Graphs`. Note, however, that vertex codes could be reassigned after vertex deletion.
"""
function label_for(meta::MetaGraph, vertex_code)
    meta.metaindex[vertex_code]
end
