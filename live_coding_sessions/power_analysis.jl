using DataFrames
using MixedModels
using MixedModelsSim
using Random
using Statistics
using SMLP2024: dataset

fm1 = fit(MixedModel, 
          @formula(reaction ~ 1 + days + (1 + days|subj)),
          dataset(:sleepstudy))

parametricbootstrap(MersenneTwister(42), 1000, fm1)       

slpsim = DataFrame(dataset(:sleepstudy); copycols=true)

slpsim[:, :reaction] .= 0.0

slpsimmod = LinearMixedModel(@formula(reaction ~ 1 + days + (1 + days|subj)), slpsim)

# coefnames(slpsimmod)
simulate!(MersenneTwister(42), slpsimmod; β=[500, 50], σ=250)
response(slpsimmod)
fit!(slpsimmod)

slpsimpow = parametricbootstrap(MersenneTwister(42), 1000, slpsimmod; β=[500, 50], σ=250)

combine(groupby(DataFrame(slpsimpow.coefpvalues), :coefname),
        :p => (p -> mean(<(0.05), p)) => :power)    

# now let's do random effects!
# these are expressed _relative_ to the residual standard deviation
# so we devide by 250, which is what we set as the residual standard deviation
# TODO: add a named argument "relative=true"     
subj_re = create_re(100/250, 20/250)
update!(slpsimmod; subj=subj_re)

simulate!(MersenneTwister(42), slpsimmod; β=[500, 50], σ=250, θ=slpsimmod.θ)
fit!(slpsimmod)

slpsimpow = parametricbootstrap(MersenneTwister(42), 1000, slpsimmod; β=[500, 50], σ=250)

combine(groupby(DataFrame(slpsimpow.coefpvalues), :coefname),
        :p => (p -> mean(<(0.05), p)) => :power)   


# big questions:
# where do we get these numbers from?

# holding the RE and residual and FE-intercept constant, what is the smallest 
# days-effect that I could detect with the given sample size? 

to_consider = [10, 20, 30, 50]
# initialize an empty array of dataframes
considerations = DataFrame[]
for eff_size in to_consider
    slpsimpow = parametricbootstrap(MersenneTwister(42), 1000, slpsimmod; 
                                     β=[500, eff_size], σ=250)
    power_at_size = combine(groupby(DataFrame(slpsimpow.coefpvalues), :coefname),
                             :p => (p -> mean(<(0.05), p)) => :power) 
    power_at_size[:, :eff_size] .= eff_size
    push!(considerations, power_at_size)
end

# put it all together in one dataframe
power = reduce(vcat, considerations)
 
# for a given sample size, now we know what size effects we can detect
# what happens if we have an effect size and what to know what sample size we need?

# for this study, there are no items
# and the number of observations per subject is given by the design
# so we only have one n to worry about
days = 0:9 
rng = MersenneTwister(42)
subj_re = create_re(100/250, 20/250)

considerations = DataFrame[]
for n_subj in [10, 20, 30, 40]
    subj_ids = "S" .* lpad.(string.(1:n_subj), 3, '0')

    subj_data = DataFrame[]
    for subj in subj_ids
        sdat = DataFrame(; subj, days)
        push!(subj_data, sdat)
    end
    simdat = reduce(vcat, subj_data)
    # initialize the response with normally distributed noise
    simdat[:, :reaction] .= randn(nrow(simdat))

    slpsimmod = LinearMixedModel(@formula(reaction ~ 1 + days + (1 + days|subj)), simdat)
   
    update!(slpsimmod; subj=subj_re)
    slpsimpow = parametricbootstrap(rng, 1000, slpsimmod; β=[500, 10], σ=250)
    power_at_size = combine(groupby(DataFrame(slpsimpow.coefpvalues), :coefname),
                             :p => (p -> mean(<(0.05), p)) => :power) 
    power_at_size[:, :n_subj] .= n_subj
    push!(considerations, power_at_size)
end

power = reduce(vcat, considerations)
