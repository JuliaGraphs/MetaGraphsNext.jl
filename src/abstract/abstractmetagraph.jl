"""
    AbstractMetaGraph

# Required methods
- [`get_graph`](@ref)
- [`get_data`](@ref)
- [`set_data!`](@ref)
"""
abstract type AbstractMetaGraph{T,G<:AbstractGraph{T}} <: AbstractGraph{T} end

"""
    get_graph(mg)
"""
function get_graph end

"""
    get_data(mg)
    get_data(mg, i)
    get_data(mg, i, j)
"""
function get_data end

"""
    set_data!(mg, data)
    set_data!(mg, i, data)
    set_data!(mg, i, j, data)
"""
function set_data! end

Base.copy(mg::AbstractMetaGraph) = deepcopy(mg)

## Graphs interface

Base.eltype(::Type{<:AbstractMetaGraph{T,G}}) where {T,G} = eltype(G)
Graphs.is_directed(::Type{<:AbstractMetaGraph{T,G}}) where {T,G} = is_directed(G)

for op in (:eltype, :edgetype, :is_directed, :nv, :ne, :vertices, :edges)
    @eval Graphs.$op(mg::AbstractMetaGraph) = $op(get_graph(mg))
end

for op in (:has_vertex, :inneighbors, :outneighbors)
    @eval Graphs.$op(mg::AbstractMetaGraph, i::Integer) = $op(get_graph(mg), i)
end

for op in (:has_edge,)
    @eval function Graphs.$op(mg::AbstractMetaGraph, i::Integer, j::Integer)
        return $op(get_graph(mg), i, j)
    end
end

## Dict interface

"""
    mg[]
"""
Base.getindex(mg::AbstractMetaGraph) = get_data(mg)

"""
    mg[i]
"""
Base.getindex(mg::AbstractMetaGraph, i::Integer) = get_data(mg, i)

"""
    mg[i, j]
"""
Base.getindex(mg::AbstractMetaGraph, i::Integer, j::Integer) = get_data(mg, i, j)

"""
    mg[] = data
"""
function Base.setindex!(mg::AbstractMetaGraph, data)
    return set_data!(mg, data)
end

"""
    mg[i, j] = data
"""
function Base.setindex!(mg::AbstractMetaGraph, data, i::Integer, j::Integer)
    if has_edge(mg, i, j)
        set_data!(mg, i, j, data)
    elseif has_vertex(mg, i) && has_vertex(mg, j)
        add_edge!(mg, i, j, data)
    else
        throw(ArgumentError("No vertex pair ($i, $j)"))
    end
    return data
end
