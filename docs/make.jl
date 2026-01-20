using Documenter
using Pass

makedocs(
    sitename="Pass.jl",
    modules = [Pass],
    checkdocs = :public,
)

deploydocs(
    repo = "github.com/KyleSJohnston/Pass.jl.git",
)
