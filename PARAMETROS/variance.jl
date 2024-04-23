function variance(x)
    n = length(x)
    μ = sum(x) / n
    sum((x .- μ) .^ 2) / (n) 
end