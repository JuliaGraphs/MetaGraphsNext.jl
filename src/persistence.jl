# Metagraphs files are simply JLD2 files.

"""
    struct MGFormat <: AbstractGraphFormat end

You can save `MetaGraph`s in a `MGFormat`, currently based on `JLD2`.
"""
struct MGFormat <: Graphs.AbstractGraphFormat end

"""
    struct DOTFormat <: AbstractGraphFormat end

If all metadata types support `pairs` or are `nothing`, you can save `MetaGraph`s in `DOTFormat`.
"""
struct DOTFormat <: Graphs.AbstractGraphFormat end

function loadmg(fn::AbstractString)
    @load fn g
    return g
end

function savemg(fn::AbstractString, g::MetaGraph)
    @save fn g
    return 1
end

loadgraph(fn::AbstractString, gname::String, ::MGFormat) = loadmg(fn)
savegraph(fn::AbstractString, g::MetaGraph) = savemg(fn, g)

function show_meta_list(io::IO, meta)
    if meta !== nothing && length(meta) > 0
        next = false
        write(io, " [")
        for (key, value) in meta
            if next
                write(io, ", ")
            else
                next = true
            end
            write(io, key)
            write(io, " = ")
            show(io, value)
        end
        write(io, "]")
    end
end

function savedot(io::IO, g::MetaGraph)
    gprops = g.gprops
    metaindex = g.metaindex

    if is_directed(g)
        write(io, "digraph G {\n")
        dash = "->"
    else
        write(io, "graph T {\n")
        dash = "--"
    end

    if gprops !== nothing
        for (key, value) in pairs(gprops)
            write(io, "    ")
            write(io, key)
            write(io, " = ")
            show(io, value)
            write(io, '\n')
        end
    end

    for label in keys(g.vprops)
        write(io, "    ")
        write(io, label)
        show_meta_list(io, g[label])
        write(io, '\n')
    end

    for (label_1, label_2) in keys(g.eprops)
        write(io, "    ")
        write(io, label_1)
        write(io, ' ')
        write(io, dash)
        write(io, ' ')
        write(io, label_2)
        show_meta_list(io, g.eprops[arrange(g, label_1, label_2)])
        write(io, "\n")
    end
    return write(io, "}\n")
end

function savegraph(fn::AbstractString, g::MetaGraph, ::DOTFormat)
    open(fn, "w") do fp
        savedot(fp, g)
    end
end
