using MetaGraphsNext
using Documenter: deploydocs, makedocs

makedocs(sitename = "MetaGraphsNext.jl", modules = [MetaGraphsNext], doctest = false)
deploydocs(repo = "github.com/JuliaGraphs/MetaGraphsNext.jl.git")
