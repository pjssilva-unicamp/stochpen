
using DelimitedFiles, CSV, Tables, DataFrames

include("./main_parametros.jl")

amostras = 100   # Número de amostras sintéticas por mês
function main_matrices()


##################### INFLOW MATRIX ##########################################
SE_matrix, S_matrix, NE_matrix, N_matrix = main_parametros(amostras)

SE = DataFrame(SE_matrix, :auto);
S = DataFrame(S_matrix, :auto);
NE = DataFrame(NE_matrix, :auto);
N = DataFrame(N_matrix, :auto);

CSV.write("matrices_dados/SE.csv", SE);
CSV.write("matrices_dados/S.csv", S);
CSV.write("matrices_dados/NE.csv", NE);
CSV.write("matrices_dados/N.csv", N);


#################### DEMAND MATRIX #######################################
SE_d = randn(amostras, 120);
S_d = randn(amostras, 120);
NE_d = randn(amostras, 120);
N_d = randn(amostras, 120);

SE_demand = DataFrame(SE_d, :auto);
S_demand = DataFrame(S_d, :auto);
NE_demand = DataFrame(NE_d, :auto);
N_demand = DataFrame(N_d, :auto);

CSV.write("matrices_dados/SE_demand.csv", SE_demand);
CSV.write("matrices_dados/S_demand.csv", S_demand);
CSV.write("matrices_dados/NE_demand.csv", NE_demand);
CSV.write("matrices_dados/N_demand.csv", N_demand);



#plot(NE[:,8])
#return SE, S, NE, N

end
main_matrices()