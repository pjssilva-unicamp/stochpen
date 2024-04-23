function covariance(x,y)
    n = length(x)
    μ_x = sum(x) / n
    μ_y = sum(y) / n
    sum((x .- μ_x).*(y.-μ_y)) / (n) 
end