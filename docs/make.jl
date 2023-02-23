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

function markdown_title(path)
    title = "?"
    open(path, "r") do file
        for line in eachline(file)
            if startswith(line, '#')
                title = strip(line, [' ', '#'])
                break
            end
        end
    end
    return String(title)
end

pages = [
    "Home" => "index.md",
    "Tutorial" => [
        markdown_title(joinpath(TUTORIAL_DIR_MD, file)) => joinpath("tutorial", file)
        for file in sort(readdir(TUTORIAL_DIR_MD)) if endswith(file, ".md")
    ],
    "API reference" => "api.md",
]

makedocs(;
    sitename="MetaGraphsNext.jl",
    modules=[MetaGraphsNext],
    doctest=true,
    pages=pages,
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://juliagraphs.org/MetaGraphsNext.jl/dev/",
        assets=String[],
        edit_link=:commit,
    ),
    checkdocs=:all,
    linkcheck=true,
)

deploydocs(; repo="github.com/JuliaGraphs/MetaGraphsNext.jl.git")
