"""
    AbstractLabeledMetaGraph{T,G,L}

# Required methods
- all those from [`AbstractMetaGraph`](@ref)
- [`has_label`](@ref)
- [`get_vertex`](@ref)
- [`get_label`](@ref)
- [`set_label!`](@ref)
- `Graphs.add_vertex!(mg, li, data)`
- `Graphs.add_edge!(mg, li, lj, data)`
"""
abstract type AbstractLabeledMetaGraph{T,G<:AbstractGraph{T},L} <: AbstractMetaGraph{T,G} end

"""
    has_label(lmg, li)
"""
function has_label end

"""
    get_vertex(lmg, li)
"""
function get_vertex end

"""
    get_label(lmg, i)
"""
function get_label end

"""
    set_label!(lmg, i, li)
"""
function set_label! end

## Core macro

"""
    @labels ex

Transform an expression `ex` to make use of labels instead of vertices.

Two cases are currently supported:
- `func(args...)` is transformed into `func_labels(args...)`
- `storage[tup...] = val` is transformed into `setindex!_labels(storage, val, tup...)`
"""
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

## Graphs interface with labels

for op in (:has_vertex, :inneighbors, :outneighbors)
    op_labels = Symbol(op, :_labels)
    @eval function $op_labels(lmg::AbstractLabeledMetaGraph, li)
        i = get_vertex(lmg, li)
        return $op(lmg, i)
    end
end

for op in (:has_edge,)
    op_labels = Symbol(op, :_labels)
    @eval function $op_labels(lmg::AbstractLabeledMetaGraph, li, lj)
        i, j = get_vertex(lmg, li), get_vertex(lmg, lj)
        return $op(lmg, i, j)
    end
end

## MetaGraph interface with labels

for op in (:get_data,)
    op_labels = Symbol(op, :_labels)
    @eval begin
        function $op_labels(lmg::AbstractLabeledMetaGraph, li)
            i = get_vertex(lmg, li)
            return $op(lmg, i)
        end
        function $op_labels(lmg::AbstractLabeledMetaGraph, li, lj)
            i, j = get_vertex(lmg, li), get_vertex(lmg, lj)
            return $op(lmg, i, j)
        end
    end
end

for op in (:set_data!,)
    op_labels = Symbol(op, :_labels)
    @eval begin
        function $op_labels(lmg::AbstractLabeledMetaGraph, li, data)
            i = get_vertex(lmg, li)
            return $op(lmg, i, data)
        end
        function $op_labels(lmg::AbstractLabeledMetaGraph, li, lj, data)
            i, j = get_vertex(lmg, li), get_vertex(lmg, lj)
            return $op(lmg, i, j, data)
        end
    end
end

## Dict interface with labels

"""
    @labels lmg[li]
"""
function getindex_labels(lmg::AbstractLabeledMetaGraph, li)
    return @labels get_data(lmg, li)
end

"""
    @labels lmg[li, lj]
"""
function getindex_labels(lmg::AbstractLabeledMetaGraph, li, lj)
    return @labels get_data(lmg, li, lj)
end

"""
    @labels lmg[li] = data
"""
function setindex!_labels(lmg::AbstractLabeledMetaGraph, data, li)
    if has_label(lmg, li)
        @labels set_data!(lmg, li, data)
    else
        add_vertex!(lmg, li, data)
    end
    return data
end

"""
    @labels lmg[li, lj] = data
"""
function setindex!_labels(lmg::AbstractLabeledMetaGraph, data, li, lj)
    if has_label(lmg, li) && has_label(lmg, lj)
        if @labels has_edge(lmg, li, lj)
            @labels set_data!(lmg, li, lj, data)
        else
            add_edge!(lmg, li, lj, data)
        end
    else
        throw(ArgumentError("No vertices labeled ($li, $lj)"))
    end
    return data
end
