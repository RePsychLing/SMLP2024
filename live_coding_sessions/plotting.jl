using CairoMakie
# https://docs.makie.org/stable/tutorials/layout-tutorial
scatter(1:8, 1:8)

f = Figure()
ax = Axis(f[1,1])

scatter!(ax, 1:100, 1:100)

ablines!, hlines, vlines, scatterlines, lines

f

using AlgebraOfGraphics
# https://aog.makie.org/stable/
using SMLP2024: dataset
using DataFrames

sleepstudy = dataset(:sleepstudy)

plt = data(sleepstudy) * 
    mapping(:days, :reaction) *
    visual(Scatter)

draw(plt)

plt = data(sleepstudy) * 
    mapping(:days => "Days of sleep deprivation", 
            :reaction => "Reaction time (ms)") *
    visual(Scatter)

plt = data(sleepstudy) * 
    mapping(:days => "Days of sleep deprivation", 
            :reaction => "Reaction time (ms)";
            layout=:subj) *
    visual(Scatter)    

plt = data(sleepstudy) * 
    mapping(:days => "Days of sleep deprivation", 
            :reaction => "Reaction time (ms)";
            layout=:subj) *
    (visual(Scatter) + linear())    

using MixedModelsMakie
# https://palday.github.io/MixedModelsMakie.jl/stable/api/
fm1 = fit(MixedModel, 
          @formula(reaction ~ 1 + days + (1 + days|subj)),
          sleepstudy)

shrinkageplot(fm1; ellipse=true)
caterpillar(fm1; orderby=2)
qqcaterpillar(fm1)
qqnorm(fm1)
coefplot(fm1)
# ridgeplot(fm1) # for bootstrap
