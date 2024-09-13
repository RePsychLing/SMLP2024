Figure(; size=(700,400))

"""
    simplelinreg(x, y)

Return a Tuple of the coefficients, `(a, b)`,  from a simple linear regression, `y = a + bx + ϵ`
"""
function simplelinreg(x, y)
    x, y = float(x), float(y)
    A = cholesky!(Symmetric([length(x) sum(x) sum(y); 0.0 sum(abs2, x) dot(x, y);
                             0.0 0.0 sum(abs2, y)])).factors
    return (ldiv!(UpperTriangular(view(A, 1:2, 1:2)), view(A, 1:2, 3))...,)
end


function xyplot!(f, df::AbstractDataFrame, x,  y, grouping; ncols=10)

    yrange = maximum(df[!, y]) - minimum(df[!, y])
    xrange = maximum(df[!, x]) - minimum(df[!, x])
    
    reg = combine(groupby(df, grouping), 
                  [x, y] => NamedTuple{(:intercept, :slope)} ∘ simplelinreg => AsTable)
    sort!(reg, :intercept)
  
    # order of grid positions to plot the facets in
    gridpos = Dict{String, NTuple{2,Int}}()
    for (i, grp) in enumerate(reg[!, grouping])
      gridpos[grp] = fldmod1(i, ncols)
    end
    gridpos
  
    axes = Axis[]
  
    # set up all the axes and plot the simple regression lines
    for row in eachrow(reg)
      pos = gridpos[row.subj]
      ax = Axis(f[pos...]; title=row.subj, 
                autolimitaspect=xrange / yrange)
      if pos[1] == 1
        hidexdecorations!(ax; grid=false, ticks=false)
      end
      if pos[2] != 1
        hideydecorations!(ax; grid=false, ticks=true)
      end
      push!(axes, ax)
      ablines!(ax, row.intercept, row.slope)
    end
  
    # scatter plot in each facet
    for (grpnt, gdf) in pairs(groupby(df, grouping))
      pos = gridpos[only(grpnt)]
      scatter!(f[pos...], gdf[!, x], gdf[!, y])
    end
    # Label(f[end+1, :], xlabel; 
    #       tellwidth=false, tellheight=true)
    # Label(f[:, 0], ylabel; 
    #       tellwidth=true, tellheight=false, rotation=pi/2)
    
    linkaxes!(axes...)
  
    # tweak the layout a little
    rowgap!(f.layout, 0)
    colgap!(f.layout, 3)
    # colsize!(f.layout, 0, 25)
    rowsize!(f.layout, 100)
    # rowsize!(f.layout, 3, 25)
    return f
  end

#   pp <- within($pastes, bb <- reorder(batch, strength))
# plot(
#   lattice::dotplot(sample ~ strength | bb, pp, pch = 21, strip = FALSE,
#     strip.left = TRUE, layout = c(1, 10),
#     scales = list(y = list(relation = "free")),
#     ylab = "Sample within batch", type = c("p", "a"),
#     xlab = "Paste strength", jitter.y = TRUE)
# )

function dotplot!(ax, x, y) 

end
