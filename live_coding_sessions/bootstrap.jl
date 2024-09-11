form = @formula(rt_trunc ~ 1 + spkr * prec * load +
                          (1 + spkr * prec * load | subj) +
                          (1 + spkr * prec * load | item))
yolo = fit(MixedModel, form, kb07; contrasts, progress)
