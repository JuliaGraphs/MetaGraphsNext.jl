"""
    MetaGraphsNext

A Julia package for graphs with vertex labels and vertex or edge metadata.
"""
module MetaGraphsNext

using Bijections: Bijection, inverse
using Graphs: Graphs, AbstractGraph
using Graphs: eltype, edgetype, is_directed
using Graphs: nv, ne, vertices, edges, has_vertex, has_edge, add_vertex!, add_edge!
using Graphs: inneighbors, outneighbors

export AbstractMetaGraph, get_graph, get_data, set_data!
export AbstractUnlabeledMetaGraph
export AbstractLabeledMetaGraph, @labels, has_label, get_vertex, get_label, set_label

export UnlabeledMetaGraph
export LabeledMetaGraph

include("utils.jl")

include("abstract/abstractmetagraph.jl")
include("abstract/abstractunlabeledmetagraph.jl")
include("abstract/abstractlabeledmetagraph.jl")

include("concrete/unlabeledmetagraph.jl")
include("concrete/labeledmetagraph.jl")

end # module
