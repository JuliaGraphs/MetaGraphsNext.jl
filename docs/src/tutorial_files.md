# Read / write

```jldoctest readwrite
julia> using Graphs

julia> using MetaGraphsNext
```

## DOTFormat

```jldoctest readwrite
julia> simple = MetaGraph(Graph());

julia> simple[:a] = nothing; simple[:b] = nothing; simple[:a, :b] = nothing;

julia> mktemp() do file, io
            savegraph(file, simple, DOTFormat())
            print(read(file, String))
        end
graph T {
    a
    b
    a -- b
}

julia> complicated = MetaGraph(DiGraph(),
            VertexMeta = Dict{Symbol, Int},
            EdgeMeta = Dict{Symbol, Int},
            gprops = (tagged = true,)
        );

julia> complicated[:a] = Dict(:code_1 => 1, :code_2 => 2);

julia> complicated[:b] = Dict(:code => 2);

julia> complicated[:a, :b] = Dict(:code => 12);

julia> mktemp() do file, io
            savegraph(file, complicated, DOTFormat())
            print(read(file, String))
        end
digraph G {
    tagged = true
    a [code_1 = 1, code_2 = 2]
    b [code = 2]
    a -> b [code = 12]
}
```

## MGFormat

```jldoctest readwrite
julia> example = MetaGraph(Graph());

julia> mktemp() do file, io
            savegraph(file, example)
            loadgraph(file, "something", MGFormat()) == example
        end
true
```