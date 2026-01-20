using Documenter
using Pass

makedocs(
    sitename="Pass.jl",
    modules = [Pass],
    checkdocs = :public,
)
