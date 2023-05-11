# # Type stability

using Graphs
using MetaGraphs: MetaGraphs
using MetaGraphsNext
using Test  #src

# ## Constructor and access

# In the previous examples, we used a `MetaGraph` constructor which receives type parameters as keyword arguments. This was done for ease of exposition, but it may impede type inference, and hence reduce performance.

colors = MetaGraph(
    Graph();  # underlying graph structure
    label_type=Symbol,  # color name
    vertex_data_type=NTuple{3,Int},  # RGB code
    edge_data_type=Symbol,  # result of the addition between two colors
    graph_data="additive colors",  # tag for the whole graph
)

@test_throws ErrorException (@inferred MetaGraph(  #src
    Graph();  #src
    label_type=Symbol,  #src
    vertex_data_type=NTuple{3,Int},  #src
    edge_data_type=Symbol,  #src
    graph_data="additive colors",  #src
))  #src

# While casual users probably won't care, if your goal is performance, you might need to proceed differently.

# Option 1: wrap the constructor in a helper function to trigger constant propagation.

function colors_constructor()
    return MetaGraph(
        Graph();
        label_type=Symbol,
        vertex_data_type=NTuple{3,Int},
        edge_data_type=Symbol,
        graph_data="additive colors",
    )
end

colors_constructor()

@test @inferred colors_constructor() == colors  #src

# Option 2: switch to another constructor that uses positional arguments (be careful with the order!)

MetaGraph(Graph(), Symbol, NTuple{3,Int}, Symbol, "additive colors")

@test (@inferred MetaGraph(  #src
    Graph(),  #src
    Symbol,  #src
    NTuple{3,Int},  #src
    Symbol,  #src
    "additive colors",  #src
) == colors)  #src

# Option 3: use the constructor for a non-empty graph instead.

vertices_description = [:red => (255, 0, 0), :green => (0, 255, 0), :blue => (0, 0, 255)]
edges_description = [
    (:red, :green) => :yellow, (:red, :blue) => :magenta, (:green, :blue) => :cyan
]
MetaGraph(cycle_graph(3), vertices_description, edges_description, "additive colors")

@test (@inferred zero(  #src
    MetaGraph(  #src
        cycle_graph(3),  #src
        vertices_description,  #src
        edges_description,  #src
        "additive colors",  #src
    ),  #src
) == colors)  #src

# Once Julia can infer the full type of the `MetaGraph`, accessing vertex and edge metadata also becomes type-stable.

# ## Comparison with MetaGraphs.jl

# In the older package [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) that we used as inspiration, data types are not specified in the graph structure. Their choice allows more flexibility and an arbitrary number of attributes which the user does not need to anticipate at construction.

colors_unstable = MetaGraphs.MetaGraph(cycle_graph(3))

# Here is how one would add data and labels to `colors_unstable`.

MetaGraphs.set_indexing_prop!(colors_unstable, :label)

MetaGraphs.set_prop!(colors_unstable, :graph_tag, "additive colors")

MetaGraphs.set_props!(colors_unstable, 1, Dict(:label => :red, :rgb_code => (255, 0, 0)))
MetaGraphs.set_props!(colors_unstable, 2, Dict(:label => :green, :rgb_code => (0, 255, 0)))
MetaGraphs.set_props!(colors_unstable, 3, Dict(:label => :blue, :rgb_code => (0, 0, 255)))

MetaGraphs.set_prop!(colors_unstable, 1, 2, :addition_result, :yellow)
MetaGraphs.set_prop!(colors_unstable, 1, 3, :addition_result, :magenta)
MetaGraphs.set_prop!(colors_unstable, 2, 3, :addition_result, :cyan);

# One can retrieve the vertex index (which we called code) using any indexing property.

colors_unstable[:green, :label]

# Then we can access vertex properties...

MetaGraphs.get_prop(colors_unstable, 2, :rgb_code)

@test_throws ErrorException (@inferred MetaGraphs.get_prop(  #src
    colors_unstable,  #src
    2,  #src
    :rgb_code,  #src
))  #src

#-

MetaGraphs.props(colors_unstable, 2)

# ... and edge properties.

MetaGraphs.get_prop(colors_unstable, 2, 3, :addition_result)

@test_throws ErrorException (@inferred MetaGraphs.get_prop(  #src
    colors_unstable,  #src
    2,  #src
    3,  #src
    :addition_result,  #src
))  #src

#-

MetaGraphs.props(colors_unstable, 2, 3)

# The fact that the outputs of these calls to `props` are of type `Dict{Symbol, Any}` is at the root of the problem. It means that if we use their values in any subsequent algorithms, we introduce type instability in our code (due to `Any`). MetaGraphsNext.jl overcomes this obstacle thanks to a more precise storage method.
