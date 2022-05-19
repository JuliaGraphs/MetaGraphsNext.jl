# MetaGraphs.jl to MetaGraphsNext.jl

This section is mainly targeted towards people intending to migrate from
*MetaGraphs.jl* to *MetaGraphsNext.jl*. We present how one could implement the
examples shown in *MetaGraphs.jl*'s
[Example Usage](https://juliagraphs.org/MetaGraphs.jl/dev/#Example-Usage)
section using *MetaGraphsNext.jl*.

***

###### Import packages

```@example main
using Graphs
import MetaGraphs, MetaGraphsNext
```

```@meta
DocTestSetup = quote
  using Graphs
  import MetaGraphsNext
end
```

***

###### Create a metagraph based on a simplegraph, with optional default edge weight

Using *MetaGraphs.jl*:
```@example main
_mg = MetaGraphs.MetaGraph(path_graph(5), 3.0)
```

Using *MetaGraphsNext.jl*:
```jldoctest main
mg = MetaGraphsNext.MetaGraph(Graph(), default_weight = 3.0)

add_vertex!(mg, :a, nothing)
add_vertex!(mg, :b, nothing)
add_vertex!(mg, :c, nothing)
add_vertex!(mg, :d, nothing)
add_vertex!(mg, :e, nothing)

add_edge!(mg, :a, :b, nothing)
add_edge!(mg, :b, :c, nothing)
add_edge!(mg, :c, :d, nothing)
add_edge!(mg, :d, :e, nothing)
mg

# output

Meta graph based on a {5, 4} undirected simple Int64 graph with vertex labels of type Symbol, vertex metadata of type Nothing, edge metadata of type Nothing, graph metadata given by nothing, and default weight 3.0
```

***

###### Create a directed metagraph based on the simplegraph, with optional default edge weight

Using *MetaGraphs.jl*:
```@example main
_mdg = MetaGraphs.MetaDiGraph(path_graph(5), 3.0)
```

Using *MetaGraphsNext.jl*:
```jldoctest main
mg = MetaGraphsNext.MetaGraph(DiGraph(), default_weight = 3.0)

# A more concise way to construct a path graph with 5 vertices
foreach(x -> add_vertex!(mg, Symbol(x), nothing), 'a':'e')
foreach(x -> add_edge!(mg, Symbol(x[1]), Symbol(x[2]), nothing), zip('a':'e', 'b':'e'))
mg

# output

Meta graph based on a {5, 4} directed simple Int64 graph with vertex labels of type Symbol, vertex metadata of type Nothing, edge metadata of type Nothing, graph metadata given by nothing, and default weight 3.0
```

***

###### Set some properties for the graph itself

Using *MetaGraphs.jl*:
```@example main
MetaGraphs.set_prop!(_mg, :description, "This is a metagraph.")
```

Using *MetaGraphsNext.jl*:
```jldoctest main
# Important: graph data can only be set when constructing the object
mg = MetaGraphsNext.MetaGraph(DiGraph(), graph_data = "graph_of_colors")

foreach(x -> add_vertex!(mg, Symbol(x), nothing), 'a':'e')
foreach(x -> add_edge!(mg, Symbol(x[1]), Symbol(x[2]), nothing), zip('a':'e', 'b':'e'))

# output
```

***

###### Set properties on a vertex in bulk

Using *MetaGraphs.jl*:
```@example main
MetaGraphs.set_props!(_mg, 1, Dict(:name=>"Susan", :id => 123))
```

Using *MetaGraphsNext.jl*:
```jldoctest main
mg = MetaGraphsNext.MetaGraph(Graph(),
                              VertexData = NamedTuple{(:name, :id), Tuple{String, Union{Int64, Missing}}})

foreach(x -> add_vertex!(mg, Symbol(x), (name = "", id = missing)), 'a':'e')
foreach(x -> add_edge!(mg, Symbol(x[1]), Symbol(x[2]), nothing), zip('a':'e', 'b':'e'))

mg[MetaGraphsNext.label_for(mg, 1)] = (name = "Susan", id = 123)

# output

(name = "Susan", id = 123)
```

***

###### Set individual properties

Using *MetaGraphs.jl*:
```@example main
MetaGraphs.set_prop!(_mg, 2, :name, "John")
```

Using *MetaGraphsNext.jl*:
```jldoctest main
# Not possible since but this is a workaround
mg[Symbol(2)] = (name = "John", id = missing)

# output

(name = "John", id = missing)
```

***

###### Set a property on an edge

Using *MetaGraphs.jl*:
```@example main
MetaGraphs.set_prop!(_mg, Edge(1, 2), :action, "knows")
```

Using *MetaGraphsNext.jl*:
```jldoctest main
mg = MetaGraphsNext.MetaGraph(Graph(), 
                              VertexData = NamedTuple{(:name, :id), Tuple{String, Union{Int64, Missing}}},
                              EdgeData = String)

foreach(x -> add_vertex!(mg, Symbol(x), (name = "", id = missing)), 1:5)
foreach(x -> add_edge!(mg, Symbol(x[1]), Symbol(x[2]), ""), zip(1:5, 2:5))
mg[Symbol(1)] = (name = "Susan", id = 123)
mg[Symbol(2)] = (name = "John", id = missing)

mg[Symbol(1), Symbol(2)] = "knows"

# output

"knows"
```

***

###### Set another property on an edge by specifying source and destination

Using *MetaGraphs.jl*:
```@example main
using Dates: Date
MetaGraphs.set_prop!(_mg, 1, 2, :since, Date("20170501", "yyyymmdd"))
```

Using *MetaGraphsNext.jl*:
```@example main
# Not supported. The exact data type of the vertex data needs to be defined
# during the construction of the graph object.
```

***

###### Get all the properties for an element

Using *MetaGraphs.jl*:
```@example main
MetaGraphs.props(_mg, 1)
```

Using *MetaGraphsNext.jl*:
```jldoctest main
# All 'properties' are stored in one object
mg[Symbol(1)]

# output

NamedTuple{(:name, :id), Tuple{String, Union{Missing, Int64}}}(("Susan", 123))
```

***

###### Get a specific property by name

Using *MetaGraphs.jl*:
```@example main
MetaGraphs.get_prop(_mg, 2, :name)
```

Using *MetaGraphsNext.jl*:
```jldoctest main
# This is workaround that uses a named tuple
mg[Symbol(2)].name

# output

"John"
```

***

###### Delete a specific property

Using *MetaGraphs.jl*:
```@example main
MetaGraphs.rem_prop!(_mg, 1, :name)
```

Using *MetaGraphsNext.jl*:
```jldoctest main
# A workaround that creates a new named tuple object of the same type and sets
# the default values for the elements of the tuple that want to be "removed"
mg[Symbol(1)] = (name = "", id = mg[Symbol(1)].id)

# output

(name = "", id = 123)
```

***

###### Clear all properties for vertex 2

Using *MetaGraphs.jl*:
```@example main
MetaGraphs.clear_props!(_mg, 2)
```

Using *MetaGraphsNext.jl*:
```jldoctest main
# In this case, we create a new named tuple object of the same type and set all
# of its elements to their default values
mg[Symbol(2)] = (name = "", id = missing)

# output

(name = "", id = missing)
```

***

###### All Graphs.jl analytics work

Using *MetaGraphs.jl*:
```@example main
betweenness_centrality(_mg)
```

Using *MetaGraphsNext.jl*:
```jldoctest main
betweenness_centrality(mg)

# output

5-element Vector{Float64}:
 0.0
 0.5
 0.6666666666666666
 0.5
 0.0
```

***

###### Using weights

Using *MetaGraphs.jl*:
```@example main
_mg = MetaGraphs.MetaGraph(complete_graph(3))
enumerate_paths(dijkstra_shortest_paths(_mg, 1), 3) |> println
MetaGraphs.set_prop!(_mg, 1, 2, :weight, 0.2)
MetaGraphs.set_prop!(_mg, 2, 3, :weight, 0.6)
enumerate_paths(dijkstra_shortest_paths(_mg, 1), 3) |> println
```

Using *MetaGraphsNext.jl*:
```jldoctest main
combinations = [['a','b'], ['a','c'], ['a','d'], ['a','e'], ['b','c'],
                ['b','d'], ['b','e'], ['c','d'], ['c', 'e'], ['d','e']]
mg = MetaGraphsNext.MetaGraph(Graph(), EdgeData = Float64, weight_function = identity, default_weight = 1.0)
foreach(x -> add_vertex!(mg, Symbol(x), nothing), 'a':'e')
foreach(x -> add_edge!(mg, Symbol(x[1]), Symbol(x[2]), 1.0), combinations)
enumerate_paths(dijkstra_shortest_paths(mg, 1), 3) |> println
mg[:a, :b] = 0.2
mg[:b, :c] = 0.6
enumerate_paths(dijkstra_shortest_paths(mg, 1), 3) |> println

# output

[1, 3]
[1, 2, 3]
```

***

###### Use vertex values as indices

Using *MetaGraphs.jl*:
```@example main
_G = MetaGraphs.MetaGraph(100)
for i in 1:100
  MetaGraphs.set_prop!(_G, i, :name, "node$i")
end
MetaGraphs.set_indexing_prop!(_G, :name)
_G["node4", :name] # nodes can now be found by the value in the index
_G[4, :name] # You can also find the value of an index by the vertex number (note, this behavior will dominate if index values are also integers)
MetaGraphs.set_prop!(_G, 3, :name, "name3") # or set_indexing_prop!(_G, 3, :name, "name3")
```

Using *MetaGraphsNext.jl*:
```@example main
# Not supported
```
