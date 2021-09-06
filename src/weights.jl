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

"""
    weighttype(g)

Return the weight type for metagraph `g`.
"""
weighttype(g::MetaGraph{<:Any,<:Any,<:Any,<:Any,<:Any,<:Any,<:Any,Weight}) where {Weight} =
    Weight

"""
    weightfunction(g)

Return the weight function for metagraph `g`.
"""
weightfunction(g::MetaGraph) = g.weightfunction

"""
    defaultweight(g)

Return the default weight for metagraph `g`.
"""
defaultweight(g::MetaGraph) = g.defaultweight
