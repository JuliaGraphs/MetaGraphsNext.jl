# Metagraphs files are simply JLD2 files.

"""
    struct MGFormat <: AbstractGraphFormat end

You can save `MetaGraph`s in a `MGFormat`, currently based on `JLD2`.
"""
struct MGFormat <: Graphs.AbstractGraphFormat end

"""
    struct DOTFormat <: AbstractGraphFormat end

If all metadata types support `pairs` or are `Nothing`, you can save `MetaGraph`s in `DOTFormat`.
"""
struct DOTFormat <: Graphs.AbstractGraphFormat end

function loadmg(file::AbstractString)
    @load file meta_graph
    return meta_graph
end

function savemg(file::AbstractString, meta_graph::MetaGraph)
    @save file meta_graph
    return 1
end

Graphs.loadgraph(file::AbstractString, ::String, ::MGFormat) = loadmg(file)
Graphs.savegraph(file::AbstractString, meta_graph::MetaGraph) = savemg(file, meta_graph)

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
    return nothing
end

function savedot(io::IO, meta_graph::MetaGraph)
    graph_data = meta_graph.graph_data
    edge_data = meta_graph.edge_data

    if is_directed(meta_graph)
        write(io, "digraph G {\n")
        dash = "->"
    else
        write(io, "graph T {\n")
        dash = "--"
    end

    if graph_data !== nothing
        for (key, value) in pairs(graph_data)
            write(io, "    ")
            write(io, key)
            write(io, " = ")
            show(io, value)
            write(io, '\n')
        end
    end

    for label in keys(meta_graph.vertex_properties)
        write(io, "    ")
        write(io, '"')
        write(io, label)
        write(io, '"')
        show_meta_list(io, meta_graph[label])
        write(io, '\n')
    end

    for (label_1, label_2) in keys(edge_data)
        write(io, "    ")
        write(io, '"')
        write(io, label_1)
        write(io, '"')
        write(io, ' ')
        write(io, dash)
        write(io, ' ')
        write(io, '"')
        write(io, label_2)
        write(io, '"')
        show_meta_list(io, edge_data[arrange(meta_graph, label_1, label_2)])
        write(io, "\n")
    end
    write(io, "}\n")
    return nothing
end

function Graphs.savegraph(file::AbstractString, meta_graph::MetaGraph, ::DOTFormat)
    open(file, "w") do io
        savedot(io, meta_graph)
    end
    return nothing
end
