using Pkg: develop, instantiate, PackageSpec
develop(PackageSpec(path = pwd()))

using MetaGraphs

instantiate()

using Documenter: deploydocs, makedocs

makedocs(sitename = "MetaGraphs.jl", modules = [MetaGraphs], doctest = false)
deploydocs(repo = "github.com/JuliaGraphs/MetaGraphs.jl.git", push_preview = true)
