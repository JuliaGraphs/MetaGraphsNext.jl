module MetaGraphsNext

using JLD2
using Graphs

export MetaGraph, MetaDiGraph, MetaUndirectedGraph
export label_for, code_for, set_data
export weighttype, default_weight, get_weight_function
export MGFormat, DOTFormat

include("metagraph.jl")
include("metaundigraph.jl")
include("metadigraph.jl")
include("graphs.jl")
include("dict_utils.jl")
include("weights.jl")
include("persistence.jl")

end # module
