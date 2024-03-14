function test_labels_codes(mg::MetaGraph)
    for code in vertices(mg)
        @test code_for(mg, label_for(mg, code)) == code
    end
    for label in labels(mg)
        @test label_for(mg, code_for(mg, label)) == label
    end
    for (label_1, label_2) in edge_labels(mg)
        @test has_edge(mg, code_for(mg, label_1), code_for(mg, label_2))
    end
    # below: arrange(edges) ⊆ keys of mg.edge_data. then = because same length
    for e in edge_labels(mg)
        @test_logs mg[e...]  # no log, no error
    end
    @test length(keys(mg.edge_data)) == ne(mg)
    for label_1 in labels(mg)
        for label_2 in outneighbor_labels(mg, label_1)
            @test has_edge(mg, code_for(mg, label_1), code_for(mg, label_2))
        end
        for label_0 in inneighbor_labels(mg, label_1)
            @test has_edge(mg, code_for(mg, label_0), code_for(mg, label_1))
        end
        @test collect(all_neighbor_labels(mg, label_1)) ==
            union(outneighbor_labels(mg, label_1), inneighbor_labels(mg, label_1))
    end
end

@testset verbose = true "Coherence of labels and codes" begin
    graph = Graph(Edge.([(1, 2), (1, 3), (2, 3)]))
    vertices_description = [
        :red => (255, 0, 0), :green => (0, 255, 0), :blue => (0, 0, 255)
    ]
    edges_description = [
        (:green, :red) => :yellow, (:blue, :red) => :magenta, (:blue, :green) => :cyan
    ]

    colors = MetaGraph(graph, vertices_description, edges_description, "additive colors")
    test_labels_codes(colors)

    # attempt to add an existing edge: non-standard order, different data
    @test !add_edge!(colors, :green, :blue, :teal)
    @test length(colors.edge_data) == ne(colors)
    @test colors[:blue, :green] == :teal

    # Delete vertex in a copy and test again

    colors_copy = copy(colors)
    rem_vertex!(colors_copy, 1)
    test_labels_codes(colors_copy)
    @test ne(colors_copy) == 1
    @test colors_copy[:blue, :green] == :teal
end

@testset verbose = true "Short-form add_vertex!/add_edge!" begin
    # short-form
    mg = MetaGraph(
        Graph(); label_type=Symbol, vertex_data_type=Nothing, edge_data_type=Nothing
    )
    @test add_vertex!(mg, :A)
    @test add_vertex!(mg, :B)
    @test add_edge!(mg, :A, :B)
    @test !add_edge!(mg, :A, :C)

    # long-form
    mg2 = MetaGraph(
        Graph(); label_type=Symbol, vertex_data_type=Nothing, edge_data_type=Nothing
    )
    @test add_vertex!(mg2, :A, nothing)
    @test add_vertex!(mg2, :B, nothing)
    @test add_edge!(mg2, :A, :B, nothing)

    # compare
    @test mg == mg2
end
