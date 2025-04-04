using BoxCox
using DataFrames
using CairoMakie
using MixedModels
using MixedModelsMakie
using SMLP2024: dataset

kb07 = dataset(:kb07)

mkb07 = fit(MixedModel, 
            @formula(rt_raw ~ 1 + spkr * prec * load 
                            + (1 + spkr + prec + load | item)
                            + (1 + spkr + prec + load | subj)),
            kb07)

plot_diagnostics(model) = plot_diagnostics!(Figure(), model)            
function plot_diagnostics!(f, model)
   ax = Axis(f[1,1]; aspect=1, title="QQPlot",
             xlabel="theoretical", ylabel="observed")
   qqnorm!(ax, model)
   ax = Axis(f[1, 2]; aspect=1, title="Residual PDF",
             xlabel="residual value", ylabel="density")
   density!(ax, residuals(model))

   alpha = 0.3
   ax = Axis(f[2, 1]; aspect=1, title="Fitted vs Observed",
             xlabel="fitted", ylabel="observed")
   scatter!(ax, fitted(model), response(model); alpha)
   ablines!(ax, 0, 1; linestyle=:dash, color=:black)

   ax = Axis(f[2,2]; aspect=1, title="Residuals vs Fitted", 
             xlabel="fitted", ylabel="residuals")
   scatter!(ax, fitted(model), residuals(model); alpha)
   hlines!(ax, 0; linestyle=:dash, color=:black)
   return f
end

plot_diagnostics!(Figure(;size=(700,700)), mkb07)
bckb07 = fit(BoxCoxTransformation, mkb07)

mkb07_bc = fit(MixedModel, 
                @formula(bckb07(rt_raw) ~ 1 + spkr * prec * load 
                                + (1 + spkr + prec + load | item)
                                + (1 + spkr + prec + load | subj)),
                kb07)
plot_diagnostics!(Figure(;size=(700,700)), mkb07_bc)

mkb07_bcalt = fit(MixedModel, 
                @formula(1 / sqrt(rt_raw) ~ 1 + spkr * prec * load 
                                + (1 + spkr + prec + load | item)
                                + (1 + spkr + prec + load | subj)),
                kb07)
plot_diagnostics!(Figure(;size=(700,700)), mkb07_bcalt)
