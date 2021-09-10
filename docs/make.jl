using Documenter: deploydocs, HTML, makedocs
using MetaGraphsNext

makedocs(
    sitename = "MetaGraphsNext.jl",
    modules = [MetaGraphsNext],
    doctest = true,
    format = HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://juliagraphs.org/MetaGraphsNext.jl/dev/",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Tutorial" => [
            "Basics" => "tutorial_basics.md",
            "LightGraphs.jl interface" => "tutorial_lightgraphs.md",
            "Reading / writing" => "tutorial_files.md",
        ],
        "API reference" => "api.md",
    ]
)

deploydocs(repo = "github.com/JuliaGraphs/MetaGraphsNext.jl.git")
