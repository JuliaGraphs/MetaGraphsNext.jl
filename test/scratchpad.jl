using MetaGraphsNext, Graphs

cities = MetaGraph(Graph(); label_type=Int, vertex_data_type=String, edge_data_type=Float64)

add_vertex!(cities, "Paris")
cities[2] = "Berlin"
cities[1, 2] = 1000.0;

capitals = MetaGraph(
    Graph(); label_type=Symbol, vertex_data_type=String, edge_data_type=Float64
)

@labels add_vertex!(capitals, :France, "Paris")
@labels capitals[:Germany] = "Berlin"
@labels capitals[:France, :Germany] = 1000.0;
