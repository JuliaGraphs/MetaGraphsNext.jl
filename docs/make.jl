using Documenter
using Graphs
using Literate
using MetaGraphsNext

DocMeta.setdocmeta!(MetaGraphsNext, :DocTestSetup, :(using MetaGraphsNext); recursive=true)

TUTORIAL_DIR_JL = joinpath(dirname(@__DIR__), "test", "tutorial")
TUTORIAL_DIR_MD = joinpath(@__DIR__, "src", "tutorial")

for file in readdir(TUTORIAL_DIR_MD)
    if endswith(file, ".md")
        rm(joinpath(TUTORIAL_DIR_MD, file))
    end
end

for file in readdir(TUTORIAL_DIR_JL)
    Literate.markdown(
        joinpath(TUTORIAL_DIR_JL, file),
        TUTORIAL_DIR_MD;
        documenter=true,
        flavor=Literate.DocumenterFlavor(),
    )
end

pages = [
    "Home" => "index.md",
    "Tutorial" => [
        joinpath("tutorial", file) for
        file in sort(readdir(TUTORIAL_DIR_MD)) if endswith(file, ".md")
    ],
    "API reference" => "api.md",
]

makedocs(;
    sitename="MetaGraphsNext.jl",
    modules=[MetaGraphsNext],
    pages=pages,
    format=Documenter.HTML(),
)

deploydocs(; repo="github.com/JuliaGraphs/MetaGraphsNext.jl")
