"""
    MetaGraphsNext

A package for graphs with vertex labels and metadata in Julia. Its main export is the `MetaGraph` type.
"""
module MetaGraphsNext

using Graphs
using SimpleTraits

export MetaGraph
export label_for, code_for
export labels,
    edge_labels, neighbor_labels, outneighbor_labels, inneighbor_labels, all_neighbor_labels
export set_data!
export weighttype, default_weight, get_weight_function
export MGFormat, DOTFormat

include("metagraph.jl")
include("directedness.jl")
include("graphs.jl")
include("dict_utils.jl")
include("weights.jl")
include("persistence.jl")

function __init__()
    # Register error hint for the `loadmg` and `savemg`
    if isdefined(Base.Experimental, :register_error_hint)
        Base.Experimental.register_error_hint(MethodError) do io, exc, _, _
            if exc.f === loadmg
                print(
                    io,
                    "\n\nIn order to load meta graphs from binary files, you need to load \
                    the JLD2.jl package.",
                )
            elseif exc.f === savemg
                print(
                    io,
                    "\n\nIn order to save meta graphs to binary files, you need to load \
                    the JLD2.jl package.",
                )
            end
        end
    end
end

end # module
