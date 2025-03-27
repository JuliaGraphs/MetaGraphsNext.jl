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
It is recommended not to set `Label` to an integer type, so as to avoid confusion between vertex labels (which do not change as the graph evolves) and vertex codes (which have type `Code<:Integer` and can change as the graph evolves).

# Fields
- `graph::Graph`: underlying, data-less graph with vertex codes of type `Code`
- `vertex_labels::Dict{Code,Label}`: dictionary mapping vertex codes to vertex labels
- `vertex_properties::Dict{Label,Tuple{Code,VertexData}}`: dictionary mapping vertex labels to vertex codes & metadata
- `edge_data::Dict{Tuple{Label,Label},EdgeData}`: dictionary mapping edge labels such as `(label_u, label_v)` to edge metadata
- `graph_data::GraphData`: metadata for the graph object as a whole
- `weight_function::WeightFunction`: function computing edge weight from edge metadata, its output must have the same type as `default_weight`
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

## Constructors

"""
    MetaGraph(
        graph,
        label_type,
        vertex_data_type=Nothing,
        edge_data_type=Nothing,
        graph_data=nothing,
        weight_function=edge_data -> 1.0,
        default_weight=1.0
    )

Construct an empty `MetaGraph` based on an empty `graph`, initializing storage with metadata types *given as positional arguments*.
"""
function MetaGraph(
    graph::AbstractGraph{Code},
    label_type::Type{Label},
    vertex_data_type::Type{VertexData}=Nothing,
    edge_data_type::Type{EdgeData}=Nothing,
    graph_data=nothing,
    weight_function=edge_data -> 1.0,
    default_weight=1.0,
) where {Code,Label,VertexData,EdgeData}
    if nv(graph) != 0
        throw(
            ArgumentError(
                "For this MetaGraph constructor, the underlying graph should be empty."
            ),
        )
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

"""
    MetaGraph(
        graph;
        label_type,
        vertex_data_type=Nothing,
        edge_data_type=Nothing,
        graph_data=nothing,
        weight_function=edge_data -> 1.0,
        default_weight=1.0
    )

Construct an empty `MetaGraph` based on an empty `graph`, initializing storage with metadata types *given as keyword arguments*.

!!! warning "Warning"
    This constructor uses keyword arguments for convenience, which means it is type-unstable.
"""
function MetaGraph(
    graph;
    label_type,
    vertex_data_type=Nothing,
    edge_data_type=Nothing,
    graph_data=nothing,
    weight_function=edge_data -> 1.0,
    default_weight=1.0,
)
    return MetaGraph(
        graph,
        label_type,
        vertex_data_type,
        edge_data_type,
        graph_data,
        weight_function,
        default_weight,
    )
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

Construct a non-empty `MetaGraph` based on a non-empty `graph` with specified vertex and edge data, *given as positional arguments*.

The data must be given as follows:
- `vertices_description` is a vector of pairs `label => data` (the code of a vertex will correspond to its rank in the list)
- `edges_description` is a vector of pairs `(label1, label2) => data`

Furthermore, these arguments must be coherent with the `graph` argument, i.e. describe the same set of vertices and edges.
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
    if length(vertices_description) != nv(graph)
        throw(
            ArgumentError(
                "For this MetaGraph constructor, the description of vertices should contain as many vertices as the underlying graph.",
            ),
        )
    end
    vertex_labels = Dict{Code,Label}()
    vertex_properties = Dict{Label,Tuple{Code,VertexData}}()
    for (code, (label, data)) in enumerate(vertices_description)
        vertex_labels[code] = label
        vertex_properties[label] = (code, data)
    end
    # Construct edge data
    if length(edges_description) != ne(graph)
        throw(
            ArgumentError(
                "For this MetaGraph constructor, the description of edges should contain as many edges as the underlying graph.",
            ),
        )
    end
    for ((label_1, label_2), _) in edges_description
        code_1 = vertex_properties[label_1][1]
        code_2 = vertex_properties[label_2][1]
        if !has_edge(graph, code_1, code_2)
            throw(
                ArgumentError(
                    "For this MetaGraph constructor, each edge in the edge description should exist in the underlying graph.",
                ),
            )
        end
    end
    edge_data = Dict{Tuple{Label,Label},EdgeData}()
    for ((label_1, label_2), data) in edges_description
        edge_data[arrange(graph, label_1, label_2)] = data
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

## Base extensions

function Base.show(
    io::IO, meta_graph::MetaGraph{<:Any,BaseGraph,Label,VertexData,EdgeData}
) where {BaseGraph,Label,VertexData,EdgeData}
    print(
        io,
        "Meta graph based on a $(BaseGraph) with vertex labels of type $Label, vertex metadata of type $VertexData, edge metadata of type $EdgeData, graph metadata given by $(repr(meta_graph.graph_data)), and default weight $(meta_graph.default_weight)",
    )
    return nothing
end

function Base.:(==)(meta_graph_1::MetaGraph, meta_graph_2::MetaGraph)
    return (
        (meta_graph_1.graph == meta_graph_2.graph) &&
        (meta_graph_1.vertex_labels == meta_graph_2.vertex_labels) &&
        (meta_graph_1.vertex_properties == meta_graph_2.vertex_properties) &&
        (meta_graph_1.edge_data == meta_graph_2.edge_data) &&
        (meta_graph_1.graph_data == meta_graph_2.graph_data) &&
        all(
            meta_graph_1.weight_function(ed) == meta_graph_2.weight_function(ed) for
            ed in meta_graph_1.edge_data
        ) &&
        (meta_graph_1.default_weight == meta_graph_2.default_weight)
    )
end

## Link between graph codes and metagraph labels

"""
    code_for(meta_graph::MetaGraph, label)

Find the vertex code (or index) associated with label `label`.

This can be useful to pass to methods inherited from `Graphs`. Note, however, that vertex codes can be reassigned after vertex deletion.
"""
function code_for(meta_graph::MetaGraph, label)
    return meta_graph.vertex_properties[label][1]
end

"""
    label_for(meta_graph::MetaGraph, code)

Find the label associated with code `code`.

This can be useful to interpret the results of methods inherited from `Graphs`. Note, however, that vertex codes can be reassigned after vertex deletion.
"""
function label_for(meta_graph::MetaGraph, code::Integer)
    return meta_graph.vertex_labels[code]
end

function transitiveclosure!(meta_graph::MetaGraph)
    throw(ArgumentError("transitiveclosure! not implemented for type MetaGraph"))
end
