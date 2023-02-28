@testset verbose = true "Short-form add_vertex!/add_edge!" begin
    # short-form
    mg = MetaGraph(Graph(); Label=Symbol, VertexData=Nothing, EdgeData=Nothing)
    @test add_vertex!(mg, :A)
    @test add_vertex!(mg, :B)
    @test add_edge!(mg, :A, :B)

    # long-form
    mg′ = MetaGraph(Graph(); Label=Symbol, VertexData=Nothing, EdgeData=Nothing)
    @test add_vertex!(mg′, :A, nothing)
    @test add_vertex!(mg′, :B, nothing)
    @test add_edge!(mg′, :A, :B, nothing)

    # compare
    @test mg == mg′
end
