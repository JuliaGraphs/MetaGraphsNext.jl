"""
    AbstractUnlabeledMetaGraph

# Required methods
- all those from [`AbstractMetaGraph`](@ref)
- `Graphs.add_vertex!(mg, data)`
- `Graphs.add_edge!(mg, i, j, data)`
"""
abstract type AbstractUnlabeledMetaGraph{T,G<:AbstractGraph{T}} <: AbstractMetaGraph{T,G} end

"""
    mg[i] = data
"""
function Base.setindex!(mg::AbstractUnlabeledMetaGraph, data, i::Integer)
    if has_vertex(mg, i)
        set_data!(mg, i, data)
    elseif i == nv(mg) + 1
        add_vertex!(mg, data)
    else
        throw(ArgumentError("No vertex $i"))
    end
    return data
end
