# # File storage

using Graphs
using MetaGraphsNext
using Test  #src

# ## MGFormat

# MetaGraphsNext.jl overloads `Graphs.savegraph` to write graphs in a custom format called `MGFormat`, which is based on JLD2.
# It is not very readable, but it does give the right result when we load it back.

example = MetaGraph(Graph(), Symbol);

example2 = mktemp() do file, io
    savegraph(file, example)
    loadgraph(file, "something", MGFormat())
end

example2 == example
@test example2 == example  #src

# ## DOTFormat

# MetaGraphsNext.jl also support the more standard DOT encoding, which is used as follows.

simple = MetaGraph(Graph(), Symbol);

simple[:a] = nothing;
simple[:b] = nothing;
simple[:a, :b] = nothing;

simple_str = mktemp() do file, io
    savegraph(file, simple, DOTFormat())
    read(file, String)
end

print(simple_str)  #md
@test simple_str == "graph T {\n    \"a\"\n    \"b\"\n    \"a\" -- \"b\"\n}\n"  #src

#-

complicated = MetaGraph(
    DiGraph();
    label_type=Symbol,
    vertex_data_type=Dict{Symbol,Int},
    edge_data_type=Dict{Symbol,Int},
    graph_data=(tagged=true,),
);

complicated[:a] = Dict(:code_1 => 1, :code_2 => 2);

complicated[:b] = Dict(:code => 2);

complicated[:a, :b] = Dict(:code => 12);

complicated_str = mktemp() do file, io
    savegraph(file, complicated, DOTFormat())
    read(file, String)
end

print(complicated_str)  #md
@test complicated_str ==  #src
    "digraph G {\n    tagged = true\n    \"a\" [code_1 = 1, code_2 = 2]\n    \"b\" [code = 2]\n    \"a\" -> \"b\" [code = 12]\n}\n"  #src

with_spaces = MetaGraph(
    DiGraph();
    label_type=String,
    vertex_data_type=Dict{Symbol,String},
    edge_data_type=Dict{Symbol,String},
)

with_spaces["a b"] = Dict(:label => "A B")

with_spaces["c d"] = Dict(:label => "C D")

with_spaces["a b", "c d"] = Dict(:label => "A B to C D")

with_spaces_str = mktemp() do file, io
    savegraph(file, with_spaces, DOTFormat())
    read(file, String)
end

print(with_spaces_str)
@test with_spaces_str == """
                         digraph G {
                             "a b" [label = "A B"]
                             "c d" [label = "C D"]
                             "a b" -> "c d" [label = "A B to C D"]
                         }
                         """
