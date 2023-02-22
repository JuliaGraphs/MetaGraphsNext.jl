"""
    MetaGraph{
        Code<:Integer,
        Graph<:AbstractGraph{Code},
        Label,
        VertexData,
        EdgeData,
        GraphData,
        WeightFunction,
        Weight
    } <: AbstractGraph{Code}

A graph type with custom vertex labels containing vertex-, edge- and graph-level metadata.

Vertex labels have type `Label`, while vertex (resp. edge, resp. graph) metadata has type `VertexData` (resp. `EdgeData`, resp. `GraphData`).
It is recommended not to set `Label` to an integer type, so as to avoid confusion between vertex labels and vertex codes (which have type `Code<:Integer`).

# Fields
- `graph::Graph`: underlying, data-less graph with vertex indices of type `Code`
- `vertex_labels::Dict{Code,Label}`: dictionary mapping vertex codes to vertex labels
- `vertex_properties::Dict{Label,Tuple{Code,VertexData}}`: dictionary mapping vertex labels to vertex codes & data
- `edge_data::Dict{Tuple{Label,Label},EdgeData}`: dictionary mapping edge labels such as `(label_u, label_v)` to edge data
- `graph_data::GraphData`: global data for the graph object
- `weight_function::WeightFunction`: function computing edge weight from edge data, its output must have the same type as `default_weight`
- `default_weight::Weight`: default weight used when an edge doesn't exist
"""
struct MetaGraph{
    Code<:Integer,
    Graph<:AbstractGraph{Code},
    Label,
    VertexData,
    EdgeData,
    GraphData,
    WeightFunction,
    Weight,
} <: AbstractGraph{Code}
    graph::Graph
    vertex_labels::Dict{Code,Label}
    vertex_properties::Dict{Label,Tuple{Code,VertexData}}
    edge_data::Dict{Tuple{Label,Label},EdgeData}
    graph_data::GraphData
    weight_function::WeightFunction
    default_weight::Weight
end

"""
    MetaGraph(
        graph,
        vertices_description,
        edges_description,
        graph_data=nothing,
        weight_function=edge_data -> 1.0,
        default_weight=1.0,
    )

Construct a non-empty `MetaGraph` based on lists of vertices and edges with their labels and data.

These lists must be constructed as follows:
- `vertices_description` is a vector of pairs `label => data` (the code of a vertex will correspond to its rank in the list)
- `edges_description` is a vector of pairs `(label1, label2) => data`

Furthermore, they must be coherent with the `graph` argument, i.e. describe the same set of vertices and edges.
"""
function MetaGraph(
    graph::AbstractGraph{Code},
    vertices_description::Vector{Pair{Label,VertexData}},
    edges_description::Vector{Pair{Tuple{Label,Label},EdgeData}},
    graph_data=nothing,
    weight_function=edge_data -> 1.0,
    default_weight=1.0,
) where {Code,Label,VertexData,EdgeData}
    # Construct vertex data
    @assert length(vertices_description) == nv(graph)
    vertex_labels = Dict{Code,Label}()
    vertex_properties = Dict{Label,Tuple{Code,VertexData}}()
    for (code, (label, data)) in enumerate(vertices_description)
        vertex_labels[code] = label
        vertex_properties[label] = (code, data)
    end
    # Construct edge data
    @assert length(edges_description) == ne(graph)
    for ((label_1, label_2), _) in edges_description
        code_1 = vertex_properties[label_1][1]
        code_2 = vertex_properties[label_2][1]
        @assert has_edge(graph, code_1, code_2)
    end
    edge_data = Dict{Tuple{Label,Label},EdgeData}()
    for ((label_1, label_2), data) in edges_description
        edge_data[label_1, label_2] = data
    end
    return MetaGraph(
        graph,
        vertex_labels,
        vertex_properties,
        edge_data,
        graph_data,
        weight_function,
        default_weight,
    )
end

"""
    MetaGraph(
        graph;
        Label=Symbol,
        VertexData=Nothing,
        EdgeData=Nothing,
        graph_data=nothing,
        weight_function=edge_data -> 1.0,
        default_weight=1.0
    )

Construct an empty `MetaGraph` with the given metadata types and weights.

!!! danger "Warning"
    This constructor is not type-stable, it is only there for convenience.
"""
function MetaGraph(
    graph::AbstractGraph{Code};
    Label=Symbol,
    VertexData=Nothing,
    EdgeData=Nothing,
    graph_data=nothing,
    weight_function=edge_data -> 1.0,
    default_weight=1.0,
) where {Code}
    @assert nv(graph) == 0
    if Label <: Integer
        @warn "Constructing a MetaGraph with integer labels is not advised."
    end
    vertex_labels = Dict{Code,Label}()
    vertex_properties = Dict{Label,Tuple{Code,VertexData}}()
    edge_data = Dict{Tuple{Label,Label},EdgeData}()
    return MetaGraph(
        graph,
        vertex_labels,
        vertex_properties,
        edge_data,
        graph_data,
        weight_function,
        default_weight,
    )
end

function Base.show(
    io::IO, meta_graph::MetaGraph{<:Any,<:Any,Label,VertexData,EdgeData}
) where {Label,VertexData,EdgeData}
    print(
        io,
        "Meta graph based on a $(meta_graph.graph) with vertex labels of type $Label, vertex metadata of type $VertexData, edge metadata of type $EdgeData, graph metadata given by $(repr(meta_graph.graph_data)), and default weight $(meta_graph.default_weight)",
    )
    return nothing
end
