module MetaGraphsNextJLD2Ext

using Graphs
using JLD2
using MetaGraphsNext

function MetaGraphsNext.loadmg(file::AbstractString)
    @load file meta_graph
    return meta_graph
end

function MetaGraphsNext.savemg(file::AbstractString, meta_graph::MetaGraph)
    @save file meta_graph
    return 1
end

end
