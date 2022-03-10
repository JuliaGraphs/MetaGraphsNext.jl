"""
    MetaWeights{InnerMetaGraph<:MetaGraph,U<:Real} <: AbstractMatrix{U}

Matrix-like wrapper for edge weights on a metagraph of type `InnerMetaGraph`.
"""

struct MetaWeights{InnerMetaGraph<:MetaGraph,U<:Real} <: AbstractMatrix{U}
    g::InnerMetaGraph
end

Base.show(io::IO, mv::MetaWeights) = print(io, "MetaWeights of size $(size(mv))")
Base.show(io::IO, ::MIME"text/plain", x::MetaWeights) = show(io, x)

MetaWeights(g::MetaGraph) = MetaWeights{typeof(g),weighttype(g)}(g)

"""
    weigths(g)

Return a matrix-like `MetaWeights` object containing the edge weights for graph `g`.
"""
Graphs.weights(g::MetaGraph) = MetaWeights(g)

function Base.size(w::MetaWeights)
    vertices = nv(w.g)
    return (vertices, vertices)
end

"""
    weighttype(g)

Return the weight type for metagraph `g`.
"""
function weighttype(
    g::MetaGraph{<:Any,<:Any,<:Any,<:Any,<:Any,<:Any,<:Any,Weight}
) where {Weight}
    return Weight
end

"""
    weight_function(g)

Return the weight function for metagraph `g`.
"""
weight_function(g::MetaGraph) = g.weight_function

"""
    default_weight(g)

Return the default weight for metagraph `g`.
"""
default_weight(g::MetaGraph) = g.default_weight

"""
    getindex(w::MetaWeights, v1, v2)

Get the weight of edge `(v1, v2)`.
"""
function Base.getindex(w::MetaWeights, v1::Integer, v2::Integer)
    g = w.g
    if has_edge(g, v1, v2)
        labels = g.vertex_labels
        wf = weight_function(g)
        return wf(g[arrange(g, labels[v1], labels[v2], v1, v2)...])
    else
        dw = default_weight(g)
        return dw
    end
end
