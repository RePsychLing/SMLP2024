# SMLP2024

SMLP2024: Advanced methods in frequentist statistics with Julia

The rendered website version of the course materials is available [here](https://repsychling.github.io/SMLP2024/).

This repository uses [Quarto](https://quarto.org) with the Julia code execution supplied by [QuartoNotebookRunner.jl](https://github.com/PumasAI/QuartoNotebookRunner.jl/), which requires Quarto 1.5+.

```sh
~/EmbraceUncertainty$ julia

julia> using Pkg

julia> Pkg.activate(".")
  Activating project at `~/SMLP2024`

julia> Pkg.instantiate()
< lots of output >

julia> exit()

~/EmbraceUncertainty$ quarto preview

< lots of output >
```
