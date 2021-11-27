"""
    MetaWeights{InnerMetaGraph<:MetaGraph,U<:Real} <: AbstractMatrix{U}

Matrix-like wrapper for edge weights on a metagraph of type `InnerMetaGraph`.
"""

struct MetaWeights{InnerMetaGraph<:MetaGraph,U<:Real} <: AbstractMatrix{U}
    g::InnerMetaGraph
end

show(io::IO, ::MetaWeights) = print(io, "MetaWeights")
show(io::IO, ::MIME"text/plain", x::MetaWeights) = show(io, x)

MetaWeights(g::MetaGraph) = MetaWeights{typeof(g),weighttype(g)}(g)

"""
    weigths(g)

Return a matrix-like `MetaWeights` object containing the edge weights for graph `g`.
"""
weights(g::MetaGraph) = MetaWeights(g)

function size(w::MetaWeights)
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
    weightfunction(g)

Return the weight function for metagraph `g`.
"""
weightfunction(g::MetaGraph) = g.weightfunction

"""
    defaultweight(g)

Return the default weight for metagraph `g`.
"""
defaultweight(g::MetaGraph) = g.defaultweight

"""
    getindex(w::MetaWeights, v1, v2)

Get the weight of edge `(v1, v2)`.
"""
function getindex(w::MetaWeights, v1::Integer, v2::Integer)
    g = w.g
    if has_edge(g, v1, v2)
        labels = g.labels
        wf = weightfunction(g)
        return wf(g[arrange(g, labels[v1], labels[v2], u, v)...])
    else
        dw = defaultweight(g)
        return dw
    end
end
