"""
    MetaGraphsNext

A package for graphs with vertex labels and metadata in Julia. Its main export is the [`MetaGraph`](@ref) type.
"""
module MetaGraphsNext

using Bijections: Bijection, inverse
using Graphs

export AbstractMetaGraph
export @labels
export get_graph, get_label, get_vertex
export get_data, set_data!
export MetaGraph

include("abstractmetagraph.jl")
include("metagraph.jl")

end # module
