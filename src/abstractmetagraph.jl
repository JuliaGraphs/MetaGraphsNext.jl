abstract type AbstractMetaGraph{T,G<:AbstractGraph{T},L,VD,ED,GD} <: AbstractGraph{T} end

function get_graph end
function get_vertex end
function get_label end
function has_label end

function set_data! end
function get_data end

macro labels(ex::Expr)
    if ex.head == :call
        f = ex.args[1]
        f_labels = Symbol(f, "_labels")
        ex_labels = Expr(ex.head, f_labels, esc.(ex.args[2:end])...)
        return ex_labels
    elseif ex.head == :(=) && ex.args[1].head == :ref
        ref_ex = ex.args[1]
        val_ex = ex.args[2]
        ex_labels = Expr(
            :call,
            :setindex!_labels,
            esc(ref_ex.args[1]),
            esc(val_ex),
            esc.(ref_ex.args[2:end])...,
        )
        return ex_labels
    else
        throw(
            ArgumentError(
                "@labels can only be applied on a function call or a dict assignment"
            ),
        )
    end
end

## Graphs interface

Base.eltype(::Type{<:AbstractMetaGraph{G}}) where {G} = eltype(G)
Graphs.is_directed(::Type{<:AbstractMetaGraph{G}}) where {G} = is_directed(G)

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

## Graphs interface with labels

for op in (:has_vertex, :inneighbors, :outneighbors)
    op_labels = Symbol(op, :_labels)
    @eval function $op_labels(mg::AbstractMetaGraph, li)
        return $op(mg, get_vertex(mg, li))
    end
end

for op in (:set_data!,)
    op_labels = Symbol(op, :_labels)
    @eval function $op_labels(mg::AbstractMetaGraph, li, data)
        return $op(mg, get_vertex(mg, li)m, data)
    end
end

for op in (:has_edge,)
    op_labels = Symbol(op, :_labels)
    @eval function $op_labels(mg::AbstractMetaGraph, li, lj)
        return $op(mg, get_vertex(mg, li), get_vertex(mg, lj))
    end
end

for op in (:add_edge!,)
    op_labels = Symbol(op, :_labels)
    @eval function $op_labels(mg::AbstractMetaGraph, li, lj, data)
        return $op(mg, get_vertex(mg, li), get_vertex(mg, lj), data)
    end
end

## Dict interface

Base.getindex(mg::AbstractMetaGraph) = get_data(mg)
Base.getindex(mg::AbstractMetaGraph, i::Integer) = get_data(mg, i)
Base.getindex(mg::AbstractMetaGraph, i::Integer, j::Integer) = get_data(mg, i, j)

getindex_labels(mg::AbstractMetaGraph, li) = mg[get_vertex(mg, li)]
getindex_labels(mg::AbstractMetaGraph, li, lj) = mg[get_vertex(mg, li), get_vertex(mg, lj)]

function Base.setindex!(mg::AbstractMetaGraph, data, i::Integer)
    if has_vertex(mg, i)
        set_data!(mg, i, data)
    elseif i == nv(mg) + 1
        add_vertex!(mg, data)
    else
        throw(ArgumentError("No vertex $i"))
    end
    return data
end

function Base.setindex!(mg::AbstractMetaGraph, data, i::Integer, j::Integer)
    if has_edge(mg, i, j)
        set_data!(mg, i, j, data)
    elseif has_vertex(mg, i) && has_vertex(mg, j)
        add_edge!(mg, i, j, data)
    else
        throw(ArgumentError("No edge ($i, $j)"))
    end
    return data
end

function setindex!_labels(mg::AbstractMetaGraph, data, li)
    if has_label(mg, li)
        mg[get_vertex(mg, li)] = data
    else
        @labels add_vertex!(mg, li, data)
    end
    return data
end

function setindex!_labels(mg::AbstractMetaGraph, data, li, lj)
    if has_label(mg, li) && has_label(mg, lj)
        mg[get_vertex(mg, li), get_vertex(mg, lj)] = data
    else
        throw(ArgumentError("No edge labeled ($li, $lj)"))
    end
    return data
end
