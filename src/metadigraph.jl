const MetaDiGraph = MetaGraph{<:Any,<:Any,<:DiGraph}

SimpleDiGraph(g::MetaDiGraph) = g.graph

is_directed(::Type{<:MetaDiGraph}) = true

function arrange(g::MetaDiGraph, label_1, label_2, code...)
    label_1, label_2
end
