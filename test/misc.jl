@testset verbose = true "Short-form add_vertex!/add_edge!" begin
    # short-form
    mg = MetaGraph(
        Graph(); label_type=Symbol, vertex_data_type=Nothing, edge_data_type=Nothing
    )
    @test add_vertex!(mg, :A)
    @test add_vertex!(mg, :B)
    @test add_edge!(mg, :A, :B)

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
