# # Benchmark

# Here we compare the performance of MetaGraphsNext.jl with its predecessor MetaGraphs.jl.

using BenchmarkTools
using Graphs
using InteractiveUtils
using MetaGraphs: MetaGraphs
using MetaGraphsNext: MetaGraphsNext
using Test  #src

#=
The benchmarking task is two-fold:
1. Build a complete graph with random boolean metadata on the vertices (`active`) and float metadata on the edges (`distance`)
2. Compute the sum of distances for all edges whose endpoints are both active.
=#

# ## Graph construction

function build_incremental_metagraphsnext(n)
    g = Graph(0)
    mg = MetaGraphsNext.MetaGraph(
        g;
        label_type=Int,  # this will throw a warning
        vertex_data_type=Bool,
        edge_data_type=Float64,
    )
    for li in 1:n
        mg[li] = rand(Bool)
    end
    for li in 1:n, lj in 1:(li - 1)
        mg[li, lj] = rand(Float64)
    end
    return mg
end;

#-

function build_bulk_metagraphsnext(n)
    g = complete_graph(n)
    vertices_description = [li => rand(Bool) for li in 1:n]
    edges_description = [(li, lj) => rand(Float64) for li in 1:n for lj in 1:(li - 1)]
    mg = MetaGraphsNext.MetaGraph(g, vertices_description, edges_description;)
    return mg
end;

#-

function build_metagraphs(n)
    g = complete_graph(n)
    mg = MetaGraphs.MetaGraph(g)
    for i in 1:n
        MetaGraphs.set_prop!(mg, i, :active, rand(Bool))
    end
    for i in 1:n, j in 1:(i - 1)
        MetaGraphs.set_prop!(mg, i, j, :distance, rand(Float64))
    end
    return mg
end;

#-

@btime build_incremental_metagraphsnext(100);

#-

@btime build_bulk_metagraphsnext(100);

#-

@btime build_metagraphs(100);

# ## Graph exploitation

function sum_active_edges_metagraphsnext(mg)
    S = 0.0
    for (li, lj) in MetaGraphsNext.edge_labels(mg)
        active_i = mg[li]
        active_j = mg[lj]
        distance_ij = mg[li, lj]
        if active_i && active_j
            S += distance_ij
        end
    end
    return S
end

#-

function sum_active_edges_metagraphs(mg)
    S = 0.0
    for e in edges(mg)
        i, j = src(e), dst(e)
        active_i = MetaGraphs.get_prop(mg, i, :active)
        active_j = MetaGraphs.get_prop(mg, j, :active)
        distance_ij = MetaGraphs.get_prop(mg, i, j, :distance)
        if active_i && active_j
            S += distance_ij
        end
    end
    return S
end

#-

mg1 = build_incremental_metagraphsnext(100);
@btime sum_active_edges_metagraphsnext($mg1);

#-

mg2 = build_metagraphs(100);
@btime sum_active_edges_metagraphs($mg2);

# The difference in performance can be explained by type instability.

@code_warntype sum_active_edges_metagraphsnext(mg1);

#-

@code_warntype sum_active_edges_metagraphs(mg2);
