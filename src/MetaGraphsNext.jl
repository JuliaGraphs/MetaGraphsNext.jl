module MetaGraphsNext

using JLD2
using LightGraphs

import Base:
    Tuple,
    ==,
    copy,
    delete!,
    eltype,
    getindex,
    haskey,
    issubset,
    length,
    setindex!,
    show,
    size,
    zero

import LightGraphs:
    AbstractGraph,
    AbstractGraphFormat,
    add_edge!,
    add_vertex!,
    edges,
    edgetype,
    has_edge,
    has_vertex,
    induced_subgraph,
    inneighbors,
    is_directed,
    loadgraph,
    ne,
    nv,
    outneighbors,
    rem_edge!,
    rem_vertex!,
    reverse,
    savegraph,
    vertices,
    weights

import LightGraphs.SimpleGraphs: SimpleGraph, SimpleDiGraph, fadj, badj

export MetaGraph, weighttype, defaultweight, weightfunction
export MGFormat, DOTFormat
export reverse
export label_for, code_for

include("metagraph.jl")
include("metaundigraph.jl")
include("metadigraph.jl")
include("lightgraphs.jl")
include("weights.jl")
include("dict_utils.jl")
include("overrides.jl")
include("persistence.jl")

end # module
