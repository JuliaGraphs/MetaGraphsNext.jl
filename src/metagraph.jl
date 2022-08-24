"""
    MetaGraph{Code<:Integer,Label,Graph,VertexData,EdgeData,GraphData,WeightFunction,Weight<:Real} <: AbstractGraph{Code}

A graph type with custom vertex labels containing vertex-, edge- and graph-level metadata.

Vertex labels have type `Label`, while vertex (resp. edge, resp. graph) metadata has type `VertexData` (resp. `EdgeData`, resp. `GraphData`).
It is recommended not to set `Label` to an integer type, so as to avoid confusion between vertex labels and vertex codes (which have type `Code<:Integer`).

# Fields
- `graph::Graph`: underlying, data-less graph with vertex indices of type `Code`
- `vertex_labels::Dict{Code,Label}`: dictionary mapping vertex codes to vertex labels
- `vertex_properties::Dict{Label,Tuple{Code,VertexData}}`: dictionary mapping vertex labels to vertex codes & data
- `edge_data::Dict{Tuple{Label,Label},EdgeData}`: dictionary mapping edge labels such as `(label_u, label_v)` to edge metadata
- `graph_data::GraphData`: graph metadata
- `weight_function::WeightFunction`: function defining edge weight from edge metadata
- `default_weight::Weight`: default weight for the edges
"""
struct MetaGraph{
    Code <: Integer,
    Label,
    Graph,
    VertexData,
    EdgeData,
    GraphData,
    WeightFunction,
    Weight <: Real,
} <: AbstractGraph{Code}
    graph::Graph
    vertex_labels::Dict{Code, Label}
    vertex_properties::Dict{Label, Tuple{Code, VertexData}}
    edge_data::Dict{Tuple{Label, Label}, EdgeData}
    graph_data::GraphData
    weight_function::WeightFunction
    default_weight::Weight
end

"""
    MetaGraph(
        graph;
        Label = Symbol,
        VertexData = Nothing,
        EdgeData = Nothing,
        graph_data = nothing,
        weight_function = edge_data -> 1.0,
        default_weight = 1.0
    )

Construct an empty `MetaGraph` with the given metadata types and weights.
"""
function MetaGraph(
    graph::AbstractGraph{Code};
    Label = Symbol,
    VertexData = Nothing,
    EdgeData = Nothing,
    graph_data = nothing,
    weight_function = edata -> 1.0,
    default_weight = 1.0,
) where {Code}
    if Label <: Integer
        @warn "Constructing a MetaGraph with integer labels is not advised."
    elseif nv(graph) > 0
        @warn "Constructing a MetaGraph with a nonempty underlying graph is not advised."
    end
    MetaGraph(
        graph,
        Dict{Code, Label}(),
        Dict{Label, Tuple{Code, VertexData}}(),
        Dict{Tuple{Label, Label}, EdgeData}(),
        graph_data,
        weight_function,
        default_weight,
    )
end

"""
    arrange(graph, label_1, label_2)

Sort two vertex labels in a default order (useful to uniquely express undirected edges).
"""
function arrange end

function Base.zero(
    meta_graph::MetaGraph{Code, Label, Graph, VertexData, EdgeData},
) where {Code, Label, Graph, VertexData, EdgeData}
    MetaGraph(
        Graph();
        Label = Label,
        VertexData = VertexData,
        EdgeData = EdgeData,
        graph_data = meta_graph.graph_data,
        weight_function = meta_graph.weight_function,
        default_weight = meta_graph.default_weight,
    )
end

function Base.:(==)(meta_graph_1::MetaGraph, meta_graph_2::MetaGraph)
    meta_graph_1.graph == meta_graph_2.graph
end

function Base.copy(meta_graph::MetaGraph)
    deepcopy(meta_graph)
end

function Base.show(
    io::IO,
    meta_graph::MetaGraph{<:Any, Label, <:Any, VertexData, EdgeData},
) where {Label, VertexData, EdgeData}
    print(
        io,
        "Meta graph based on a $(meta_graph.graph) with vertex labels of type $Label, vertex metadata of type $VertexData, edge metadata of type $EdgeData, graph metadata given by $(repr(meta_graph.graph_data)), and default weight $(meta_graph.default_weight)",
    )
    nothing
end
