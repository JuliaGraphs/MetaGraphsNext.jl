using MetaGraphsNext, Graphs

cities = UnlabeledMetaGraph(Graph(); vertex_data_type=String, edge_data_type=Float64)

add_vertex!(cities, "Paris")
add_vertex!(cities, "Berlin")
cities[1, 2] = 1000.0;

capitals = LabeledMetaGraph(
    Graph(), Symbol; vertex_data_type=String, edge_data_type=Float64
)

add_vertex!(capitals, :France, "Paris")
add_vertex!(capitals, :Germany, "Berlin")
add_vertex!(capitals, :Italy, "Rome")
capitals[1, 2] = 1000.0;
@labels capitals[:France, :Italy] = 2000.0;
