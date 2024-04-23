
using CSV, DataFrames

function inflows(i,samples)

     SE = CSV.read("matrices_dados/SE.csv", DataFrame)
     S = CSV.read("matrices_dados/S.csv", DataFrame)
     NE = CSV.read("matrices_dados/NE.csv", DataFrame)
     N = CSV.read("matrices_dados/N.csv", DataFrame)


     scenarios = [SE[:,1],  SE[:,2],  SE[:,3],  SE[:,4],  SE[:,5],  SE[:,6],  SE[:,7],  SE[:,8],  SE[:,9],  SE[:,10],  SE[:,11],  SE[:,12]],
                 [S[:,1],  S[:,2],  S[:,3],  S[:,4],  S[:,5],  S[:,6],  S[:,7],  S[:,8],  S[:,9],  S[:,10],  S[:,11],  S[:,12]],
                 [NE[:,1],  NE[:,2],  NE[:,3],  NE[:,4],  NE[:,5],  NE[:,6],  NE[:,7],  NE[:,8],  NE[:,9],  NE[:,10],  NE[:,11],  NE[:,12]],
                 [N[:,1],  N[:,2],  N[:,3],  N[:,4],  N[:,5],  N[:,6],  N[:,7],  N[:,8],  N[:,9],  N[:,10],  N[:,11],  N[:,12]]

   
                

    ESCEN = Vector{Vector{Float64}}();

    for t in 1:120
        month = t % 12 == 0 ? 12 : t % 12

    escen = Float64[];

    for j in 1:samples
        push!(escen, scenarios[i][month][j])
     end
     push!(ESCEN, escen);

    end

     return ESCEN

end