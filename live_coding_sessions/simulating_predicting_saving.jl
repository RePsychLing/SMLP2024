using MixedModels
using SMLP2024: dataset 
using DataFrames
using MixedModelsSim
using Random

#####
##### Saving and loading
#####

fm1 = fit(MixedModel, 
          @formula(reaction ~ 1 + days + (1+days|subj)),
          dataset(:sleepstudy))

saveoptsum("mymodel.json", fm1)

fm_new_session = LinearMixedModel(@formula(reaction ~ 1 + days + (1+days|subj)),
                                  dataset(:sleepstudy))

restoreoptsum!(fm_new_session, "mymodel.json")

# the Serialization stdlib can also be used here, but it's not guaranteed
# to be compatible across Julia versions

# this can be used with the Effects package
# and for printing the model summary, but 
# does not store the model matrices and can't be used for 
# e.g. "fitted" or condVar
# https://juliamixedmodels.github.io/MixedModelsSerialization.jl/stable/api/
using MixedModelsSerialization
fm1_summary = MixedModelSummary(fm1)
save_summary("mymodelsummary.jld2", fm1_summary)

item_btwn = Dict(:freq => ["low", "high"])
subj_btwn = Dict(:age => ["young", "old"], :l1 => ["German", "English", "Dutch"])
df = DataFrame(simdat_crossed(MersenneTwister(12321), 6, 2; item_btwn, subj_btwn))
rename!(df, :dv => :rt)

boot = parametricbootstrap(MersenneTwister(10), 1000, fm1)
savereplicates("bootstrap.arrow", boot)
# does not modify the original model but still requires it 
# to get all the metadata
boot_restored = restorereplicates("bootstrap.arrow", fm1)

# things we don't necessarily recommend but are often requested
using MixedModelsExtras

# predict()

# linear mixed models
slp = DataFrame(dataset(:sleepstudy); copycols=true)
slp[1:10, :subj] .= "new guy"
predict(fm1, slp) # same as predict(fm1, slp; new_re_levels=:missing)
predict(fm1, slp; new_re_levels=:population)

# kb07 = dataset(:kb07)

# glmm
gm1 = fit(MixedModel, 
          @formula(use ~ 1 + age + abs2(age) + livch + urban + (1|dist)),
          dataset(:contra),
          Bernoulli())

# default
predict(gm1, dataset(:contra); type=:response)
predict(gm1, dataset(:contra); type=:linpred)

using Effects
contra = dataset(:contra)
design = Dict(:age => -13:0.1:13,
              :livch => unique(contra.livch),
              :urban => unique(contra.urban))

eff = effects(design, gm1; 
              invlink=AutoInvLink(), 
              eff_col="use",
              level=0.95)
using CairoMakie
using AlgebraOfGraphics
plt = data(eff) * 
    mapping(:age, :use; color=:livch, layout=:urban) * 
    (visual(Lines) + 
     mapping(; lower=:lower, upper=:upper) * visual(LinesFill)) 
draw(plt)

# Pipes
# weird syntax for built in
plt |> draw

using Statistics
using Chain
@chain eff begin
    groupby([:livch])
    combine(:use => mean => :use)
end

# equivalent to 
@chain eff begin
    groupby(_, [:livch])
    combine(_, :use => mean => :use)
end

@macroexpand @chain eff begin
    groupby([:livch])
    combine(:use => mean => :use)
end
