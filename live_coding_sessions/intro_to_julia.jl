using Statistics

v = [1, 2, 3]
for i in v
    println(i)
end

using DataFrames
df = DataFrame(;a=[1,2],b=["a","b"])
describe(df)

select(df, :a)
select(df, "a")

select(df, a)
a = "b"
# select(df, a)
transform(df, :a => ByRow(abs2) => :c)
transform(df, :a => ByRow(abs2) => :a)
transform(df, :a => ByRow(abs2); renamecols=false)

combine(groupby(df, :b), :a => mean; renamecols=false)

# column access
df.a

df[2, :]

df[:, :a]

# mutating variants
transform(df, :a => ByRow(abs2) => :c)
# this adds in the column to the original frame
transform!(df, :a => ByRow(abs2) => :c)

function square(x)
    return x^2
end

square(x) = x^2 # like lambda in python

function factor_name(x::AbstractString)
    return x
end

function factor_name(x)
    return string(x)
end
