using DataFrames
using Distributions
using Effects
using MixedModels
using MultipleTesting
using Tables

using Effects: _responsename, _dof
using StatsAPI: RegressionModel

kb07 = MixedModels.dataset(:kb07)
mixed_form = @formula(rt_trunc ~ 1 + spkr * prec * load + (1|item) + (1|subj))
mixed_model = fit(MixedModel, mixed_form, kb07; progress=false)

design = Dict(:spkr => ["old", "new"],
              :prec => ["break", "maintain"],
              :load => ["yes", "no"])

levels_of_interest = [
    (; spkr="old", prec="maintain", load="no")
    (; spkr="old", prec="break", load="yes")
]
means = effects!(DataFrame(levels_of_interest), mixed_model)

means[!, :t] .= means.rt_trunc ./ means.err
means[!, :dof] .= Inf
means[!, :p] = 2 * cdf.(TDist.(means.dof), -abs.(means.t))
means[!, :p_adj] = adjust(means.p, Holm())

emmeans(model::RegressionModel; levels=Dict{Symbol, Any}(), kwargs...) = _emmeans(model, levels; kwargs...)
function _emmeans(model::RegressionModel, levels::Dict{Symbol}; 
                  dof=nothing, eff_col=nothing, err_col=:err,
                  padjust=identity,
                  kwargs...)
    eff_col = string(something(eff_col, _responsename(model)))
    err_col = string(err_col)                  
    result = Effects.emmeans(model; levels, dof, eff_col, err_col, kwargs...)
    transform!(result, [eff_col, err_col] => ByRow(/) => "t")

    if !isnothing(dof)
        p = 2 * cdf.(TDist.(result.dof), -abs.(result.t))
        result[!,  "Pr(>|t|)"] = padjust(p)
    end
    return result
end
_emmeans(model::RegressionModel, levels; kwargs...) = _emmeans(model, Tables.columntable(levels); kwargs...)
function _emmeans(model::RegressionModel, levels::Tables.ColumnTable; eff_col=nothing, err_col=:err,
                 invlink=identity, dof=nothing, padjust=identity)
    typical = mean
    grid = DataFrame(levels)
    eff_col = string(something(eff_col, _responsename(model)))
    err_col = string(err_col)

    result = effects!(grid, model; eff_col, err_col, typical, invlink)
    transform!(result, [eff_col, err_col] => ByRow(/) => "t")

    if !isnothing(dof)
        result[!, :dof] .= _dof(dof, model)
        p = 2 * cdf.(TDist.(result.dof), -abs.(result.t))
        result[!,  "Pr(>|t|)"] = padjust(p)
    end

    return result
end

emmeans(mixed_model; levels=levels_of_interest, dof=Inf)
   