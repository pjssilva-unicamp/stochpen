using SDDP
using SpecialFunctions
using Plots, Gurobi

#include("./create_model.jl")
#include("./create_model_probabilistic.jl")
include("./create_model.jl")
include("./create_model_probabilistic.jl")
include("./create_model_probabilistic_joint.jl")
#include("./create_model_probabilistic_sample.jl")
include("./inflows.jl")
include("./demandas.jl")

SE = CSV.read("matrices_dados/SE.csv", DataFrame);
#S = CSV.read("S.csv", DataFrame)
#NE = CSV.read("NE.csv", DataFrame)
#N = CSV.read("N.csv", DataFrame)
samples, colum = size(SE);

low_bound = Float64[]
low_bound_1 = Float64[]
low_bound_2 = Float64[]
low_bound_3 = Float64[]

iter=100
replic=500
replic_2=500

# PARAMETROS MODELO PROB 1
alpha = 10
beta  = 15;
prob  = 0.8;

# # PARAMETROS MODELO PROB 2
#  alpha_2 = 10;
#  beta_2  = 15;
#  prob_2  = 0.9;

# # PARAMETROS MODELO PROB 3
# alpha_3 = 10;
# beta_3  = 5;
# prob_3  = 0.7;


function main_principal()
####################### CREAÇÃO DOS MODELOS PARA O TREINAMENTO ###################
##################################################################################
deterministic_model     =  create_model(true, 0, 0, samples)

#deterministic_model_cres   =  create_model_probabilistic(true,  alpha, 0, prob, samples)

probabilistic_model_1   =  create_model_probabilistic(true,  alpha, beta, prob, samples)
sample_model_1          =  create_model_probabilistic(false, alpha, beta, prob, samples)

probabilistic_model_2   =  create_model_probabilistic_joint(true,  alpha, beta, prob, samples)
sample_model_2          =  create_model_probabilistic_joint(false, alpha, beta, prob, samples)

#probabilistic_model_3   =  create_model_probabilistic(true,  alpha, beta, prob, samples)
#sample_model_3          =  create_model_probabilistic(false, alpha, beta, prob, samples)



######################## TREINAMENTO #########################

SDDP.train(
     deterministic_model,
     #stopping_rules = [SDDP.BoundStalling(5, 1e-2)], #[SDDP.SimulationStoppingRule()], #[SDDP.BoundStalling(2, 10000)],  FirstStageStoppingRule()
     #stopping_rules = [SDDP.TimeLimit(18000.0)],
     #sampling_scheme = SDDP.InSampleMonteCarlo(max_depth = 120, terminate_on_cycle = false, terminate_on_dummy_leaf = false),
     cut_type = SDDP.SINGLE_CUT,
     iteration_limit = iter,
 );

 SDDP.write_log_to_csv(deterministic_model, "trained_model.cvs")
 SDDP.write_cuts_to_file(deterministic_model, "cortes/deter_cuts.json")



#  SDDP.train(
#      deterministic_model_cres,
#      #stopping_rules = [SDDP.BoundStalling(5, 1e-2)], #[SDDP.SimulationStoppingRule()], #[SDDP.BoundStalling(2, 10000)],  FirstStageStoppingRule()
#      stopping_rules = [SDDP.TimeLimit(18000.0)],
#      #sampling_scheme = SDDP.InSampleMonteCarlo(max_depth = 120, terminate_on_cycle = false, terminate_on_dummy_leaf = false),
#      cut_type = SDDP.SINGLE_CUT,
#      iteration_limit = iter,
#  );

#  SDDP.write_log_to_csv(deterministic_model_cres, "trained_model_cres.cvs")
#  SDDP.write_cuts_to_file(deterministic_model_cres, "cortes/deter_cres_cuts.json")


SDDP.train(
  probabilistic_model_1,
  forward_pass = SDDP.AlternativeForwardPass(sample_model_1), #SDDP.DefaultForwardPass(),
  post_iteration_callback = SDDP.AlternativePostIterationCallback(sample_model_1),
  #stopping_rules = [SDDP.TimeLimit(18000.0)],
  #stopping_rules = [SDDP.BoundStalling(5, 1e-2)],
  cut_type = SDDP.SINGLE_CUT,
  iteration_limit = iter,
 )

 SDDP.write_log_to_csv(probabilistic_model_1, "trained_model_1.cvs")
 SDDP.write_cuts_to_file(probabilistic_model_1, "cortes/proba_cuts.json")



 
   SDDP.train(
    probabilistic_model_2,
    forward_pass = SDDP.AlternativeForwardPass(sample_model_2), #SDDP.DefaultForwardPass(),
    post_iteration_callback = SDDP.AlternativePostIterationCallback(sample_model_2),
    #stopping_rules = [SDDP.TimeLimit(18000.0)],
    #duality_handler = SDDP.LagrangianDuality(),
    #duality_handler = SDDP.ContinuousConicDuality(),
    duality_handler = SDDP.StrengthenedConicDuality(),
    cut_type = SDDP.SINGLE_CUT,
    iteration_limit = iter,
   )

   SDDP.write_log_to_csv(probabilistic_model_2, "trained_model_2.cvs")
   SDDP.write_cuts_to_file(probabilistic_model_2, "cortes/joint_proba_cuts.json")


  #  SDDP.train(
  #   probabilistic_model_3,
  #   forward_pass = SDDP.AlternativeForwardPass(sample_model_3), #SDDP.DefaultForwardPass(),
  #   post_iteration_callback = SDDP.AlternativePostIterationCallback(sample_model_3),
  #   duality_handler = SDDP.ContinuousConicDuality(),
  #   #duality_handler = SDDP.StrengthenedConicDuality(),
  #   cut_type = SDDP.SINGLE_CUT,
  #   iteration_limit = iter,
  #  )
  #  SDDP.write_log_to_csv(probabilistic_model_3, "trained_model_3.cvs")
  #  SDDP.write_cuts_to_file(probabilistic_model_3, "cortes/proba_cuts_conti.json")

 

####################### CREATING MODELS FOR SIMULATION ######################
##################################################################################

simulat_model =  create_model_probabilistic(false, alpha, beta, prob, samples)
SDDP.read_cuts_from_file(simulat_model, "cortes/deter_cuts.json")

simulat_model_1 =  create_model_probabilistic(false, alpha, beta, prob, samples)
SDDP.read_cuts_from_file(simulat_model_1, "cortes/proba_cuts.json")

simulat_model_2 =  create_model_probabilistic(false, alpha, beta, prob, samples)
SDDP.read_cuts_from_file(simulat_model_2, "cortes/joint_proba_cuts.json")

#simulat_model_3 =  create_model_probabilistic(false, alpha, beta, prob, samples)
#SDDP.read_cuts_from_file(simulat_model_3, "cortes/proba_cuts_conti.json")


################################### SIMULATION #####################################
####################################################################################


simulat = SDDP.simulate(
simulat_model, 
replic_2,
custom_recorders = Dict{Symbol,Function}(
:shadow_price_1 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][1]),
:shadow_price_2 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][2]),
:shadow_price_3 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][3]),
:shadow_price_4 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][4]),
), [:inflow, :storedEnergy_per, :demanda_determ, :spill_per, :hydroGeneration_per, :thermal_per], 
);

# simulat_cres = SDDP.simulate(
#   deterministic_model_cres,
#   replic_2,
#   [:demanda_es_porcen],
# )

    
simulat_1 = SDDP.simulate(
simulat_model_1, 
replic_2,
custom_recorders = Dict{Symbol,Function}(
:shadow_price_1 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][1]),
:shadow_price_2 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][2]),
:shadow_price_3 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][3]),
:shadow_price_4 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][4]),
), [:inflow, :storedEnergy_per, :demanda_determ, :demanda_es_porcen, :demanda_cres, :spill_per, :hydroGeneration_per, :thermal_per], 
);           

 simulat_2 = SDDP.simulate(
 simulat_model_2, 
 replic_2,
 custom_recorders = Dict{Symbol,Function}(
 :shadow_price_1 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][1]),
 :shadow_price_2 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][2]),
 :shadow_price_3 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][3]),
 :shadow_price_4 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][4]),
 ), [:inflow, :storedEnergy_per, :demanda_determ, :demanda_es_porcen, :demanda_cres, :spill_per, :hydroGeneration_per, :thermal_per],
 ); 


#  simulat_3 = SDDP.simulate(
#  simulat_model_3, 
#  replic_2,
#  custom_recorders = Dict{Symbol,Function}(
#  :shadow_price_1 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][1]),
#  :shadow_price_2 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][2]),
#  :shadow_price_3 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][3]),
#  :shadow_price_4 => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][4]),
#  ), [:inflow, :storedEnergy_per, :demanda_determ, :demanda_es_porcen, :demanda_cres, :spill_per, :hydroGeneration_per, :thermal_per],
#  );       
            

  ################################### FIGURES ###################################################
  ###############################################################################################
  plot(SDDP.publication_plot(simulat, quantile = [0.05, 0.5, 0.95], title = "Cost Objetive") do data
    return sum(data[:stage_objective])/replic_2
  end,
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  #ylims = (30,65),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
  )
savefig("figures/costos/costo.pdf")

plot(SDDP.publication_plot(simulat_1, quantile = [0.05, 0.5, 0.95], title = "Cost Objetive") do data
  return data[:stage_objective]
end,
xlabel = "Month",
ylabel = "MW-month %",
xlims=(0,60),
#ylims = (30,65),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
)
savefig("figures/costos/costo_1.pdf")

plot(SDDP.publication_plot(simulat_2, quantile = [0.05, 0.5, 0.95], title = "Cost Objetive") do data
  return data[:stage_objective]
end,
xlabel = "Month",
ylabel = "MW-month %",
xlims=(0,60),
#ylims = (30,65),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
)
savefig("figures/costos/costo_2.pdf")



plot(SDDP.publication_plot(simulat_2, quantile = [0.05, 0.5, 0.95], title = "Demand SE") do data
    return data[:demanda_es_porcen][1]
  end,
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (30,65),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
  )
savefig("figures/demand/demanda_est_SE.pdf") 

plot(SDDP.publication_plot(simulat_2, quantile = [0.05, 0.5, 0.95], title = "Demand S") do data
  return data[:demanda_es_porcen][2]
end,
xlabel = "Month",
ylabel = "MW-month %",
xlims=(0,60),
ylims = (50,100),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
)
savefig("figures/demand/demanda_est_S.pdf") 

plot(SDDP.publication_plot(simulat_2, quantile = [0.05, 0.5, 0.95], title = "Demand NE") do data
  return data[:demanda_es_porcen][3]
end,
xlabel = "Month",
ylabel = "MW-month %",
xlims=(0,60),
ylims = (25,55),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
)
savefig("figures/demand/demanda_est_NE.pdf") 

plot(SDDP.publication_plot(simulat_2, quantile = [0.05, 0.5, 0.95], title = "Demand N") do data
  return data[:demanda_es_porcen][4]
end,
xlabel = "Month",
ylabel = "MW-month %",
xlims=(0,60),
ylims = (20,40),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
)
savefig("figures/demand/demanda_est_N.pdf") 



# plot(SDDP.publication_plot(simulat_cres, quantile = [0.05, 0.5, 0.95], title = "Demand SE") do data
#   return data[:demanda_es_porcen][1]
# end,
# xlabel = "Month",
# ylabel = "MW-month %",
# xlims=(0,60),
# ylims = (30,65),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
# )
# savefig("figures/demand/demanda_cres_SE.pdf") 

# plot(SDDP.publication_plot(simulat_cres, quantile = [0.05, 0.5, 0.95], title = "Demand S") do data
# return data[:demanda_es_porcen][2]
# end,
# xlabel = "Month",
# ylabel = "MW-month %",
# xlims=(0,60),
# ylims = (50,100),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
# )
# savefig("figures/demand/demanda_cres_S.pdf") 

# plot(SDDP.publication_plot(simulat_cres, quantile = [0.05, 0.5, 0.95], title = "Demand NE") do data
# return data[:demanda_es_porcen][3]
# end,
# xlabel = "Month",
# ylabel = "MW-month %",
# xlims=(0,60),
# ylims = (25,55),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
# )
# savefig("figures/demand/demanda_cres_NE.pdf") 

# plot(SDDP.publication_plot(simulat_cres, quantile = [0.05, 0.5, 0.95], title = "Demand N") do data
# return data[:demanda_es_porcen][4]
# end,
# xlabel = "Month",
# ylabel = "MW-month %",
# xlims=(0,60),
# ylims = (20,40),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
# )
# savefig("figures/demand/demanda_cres_N.pdf") 
   







   plot(SDDP.publication_plot(simulat, quantile = [0.05, 0.5, 0.95], title = "Stored volume SE") do data
     return data[:storedEnergy_per][1]
   end,
   xlabel = "Month",
   ylabel = "MW-month %",
   xlims=(0,60),
   ylims = (0,100),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
   )

   savefig("figures/stored/stored_det_SE")  

   plot(SDDP.publication_plot(simulat, quantile = [0.05, 0.5, 0.95], title = "Stored volume S") do data
    return data[:storedEnergy_per][2]
  end,
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
  )

  savefig("figures/stored/stored_det_S")  

  plot(SDDP.publication_plot(simulat, quantile = [0.05, 0.5, 0.95], title = "Stored volume NE") do data
    return data[:storedEnergy_per][3]
  end,
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
  )

  savefig("figures/stored/stored_det_NE")  

  plot(SDDP.publication_plot(simulat, quantile = [0.05, 0.5, 0.95], title = "Stored volume N") do data
    return data[:storedEnergy_per][4]
  end,
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # #ylims = (0, 205000.0), #  20000.0
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300),
  )

  savefig("figures/stored/stored_det_N")  
 

   plot(SDDP.publication_plot(simulat_1, quantile = [0.05, 0.5, 0.95], title = "Stored volume SE") do data
     return data[:storedEnergy_per][1]
   end,
   xlabel = "Month",
   ylabel = "MW-month %",
   xlims=(0,60),
   ylims = (0,100),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
   )

   savefig("figures/stored/stored_prob_SE") 


   plot(SDDP.publication_plot(simulat_1, quantile = [0.05, 0.5, 0.95], title = "Stored volume S") do data
    return data[:storedEnergy_per][2]
  end,
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
  )

  savefig("figures/stored/stored_pro_S") 

  plot(SDDP.publication_plot(simulat_1, quantile = [0.05, 0.5, 0.95], title = "Stored volume NE") do data
    return data[:storedEnergy_per][3]
  end,
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
  )

  savefig("figures/stored/stored_pro_NE") 

  plot(SDDP.publication_plot(simulat_1, quantile = [0.05, 0.5, 0.95], title = "Stored volume N") do data
    return data[:storedEnergy_per][4]
  end,
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
  )

  savefig("figures/stored/stored_pro_N") 

  plot(SDDP.publication_plot(simulat_2, quantile = [0.05, 0.5, 0.95], title = "Stored volume SE") do data
    return data[:storedEnergy_per][1]
  end,
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
  )

  savefig("figures/stored/stored_pro_joint_SE") 


  plot(SDDP.publication_plot(simulat_2, quantile = [0.05, 0.5, 0.95], title = "Stored volume S") do data
   return data[:storedEnergy_per][2]
 end,
 xlabel = "Month",
 ylabel = "MW-month %",
 xlims=(0,60),
 ylims = (0,100),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
 )

 savefig("figures/stored/stored_pro_joint_S") 

 plot(SDDP.publication_plot(simulat_2, quantile = [0.05, 0.5, 0.95], title = "Stored volume NE") do data
   return data[:storedEnergy_per][3]
 end,
 xlabel = "Month",
 ylabel = "MW-month %",
 xlims=(0,60),
 ylims = (0,100),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
 )

 savefig("figures/stored/stored_pro_joint_NE") 

 plot(SDDP.publication_plot(simulat_2, quantile = [0.05, 0.5, 0.95], title = "Stored volume N") do data
   return data[:storedEnergy_per][4]
 end,
 xlabel = "Month",
 ylabel = "MW-month %",
 xlims=(0,60),
 ylims = (0,100),
# # # # #ylims = (0, 205000.0), #  20000.0
# # # # layout = (1, 2),
# # # # margin_bottom = 1,
# # # # size = (500, 300),
 )

 savefig("figures/stored/stored_pro_joint_N") 


#  plot(SDDP.publication_plot(simulat_3, quantile = [0.05, 0.5, 0.95], title = "Stored volume SE") do data
#   return data[:storedEnergy_per][1]
# end,
# xlabel = "Month",
# ylabel = "MW-month %",
# xlims=(0,60),
# ylims = (0,100),
# # # # # #ylims = (0, 205000.0), #  20000.0
# # # # # layout = (1, 2),
# # # # # margin_bottom = 1,
# # # # # size = (500, 300),
# )

# savefig("figures/stored/stored_pro_cont_SE") 



    plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Shadow price SE") do data
     return data[:shadow_price_1]
   end,
   xlabel = "Month",
   ylims = (0, 400),
   xlims = (0, 60),

   )

   savefig("figures/price/shaw_det_SE")

   plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Shadow price S") do data
    return data[:shadow_price_2]
  end,
  xlabel = "Month",
 # ylims = (0, 800),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_det_S")

  plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Shadow price NE") do data
    return data[:shadow_price_3]
  end,
  xlabel = "Month",
  ylims = (0, 400),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_det_NE")

  plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Shadow price N") do data
    return data[:shadow_price_4]
  end,
  xlabel = "Month",
  ylims = (0, 400),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_det_N")




  

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Shadow price SE") do data
    return data[:shadow_price_1]
  end,
  xlabel = "Month",
  ylims = (0, 400),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_pro_SE")


  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Shadow price S") do data
    return data[:shadow_price_2]
  end,
  xlabel = "Month",
 # ylims = (0, 800),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_pro_S")

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Shadow price NE") do data
    return data[:shadow_price_3]
  end,
  xlabel = "Month",
  ylims = (0, 400),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_pro_NE")

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Shadow price N") do data
    return data[:shadow_price_4]
  end,
  xlabel = "Month",
  ylims = (0, 400),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_pro_N")



  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Shadow price SE") do data
    return data[:shadow_price_1]
  end,
  xlabel = "Month",
  ylims = (0, 400),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_pro_joint_SE")


  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Shadow price S") do data
    return data[:shadow_price_2]
  end,
  xlabel = "Month",
 # ylims = (0, 400),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_pro_joint_S")

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Shadow price NE") do data
    return data[:shadow_price_3]
  end,
  xlabel = "Month",
  ylims = (0, 400),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_pro_joint_NE")

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Shadow price N") do data
    return data[:shadow_price_4]
  end,
  xlabel = "Month",
  ylims = (0, 400),
  xlims = (0, 60),

  )

  savefig("figures/price/shaw_pro_joint_N")




  

 



   plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation SE") do data
     return sum(data[:thermal_per][1])                                         
   end,                                                  
   xlabel = "Month",
   ylabel = "MW-month %",
   xlims=(0,60),
   ylims = (0,100),
   )
                      
   savefig("figures/thermal/thermal_det_SE")

   plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation S") do data
    return sum(data[:thermal_per][2])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
  )
                     
  savefig("figures/thermal/thermal_det_S")

  plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation NE") do data
    return sum(data[:thermal_per][3])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
  )
                     
  savefig("figures/thermal/thermal_det_NE")

  plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation N") do data
    return sum(data[:thermal_per][4])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
  )
                     
  savefig("figures/thermal/thermal_det_N")



  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation SE") do data
    return sum(data[:thermal_per][1])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/thermal/thermal_pro_SE")

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation S") do data
    return sum(data[:thermal_per][2])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/thermal/thermal_pro_S")

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation NE") do data
    return sum(data[:thermal_per][3])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/thermal/thermal_pro_NE")

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation N") do data
    return sum(data[:thermal_per][4])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/thermal/thermal_pro_N")



  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation SE") do data
    return sum(data[:thermal_per][1])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/thermal/thermal_pro_joint_SE")

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation S") do data
    return sum(data[:thermal_per][2])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/thermal/thermal_pro_joint_S")

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation NE") do data
    return sum(data[:thermal_per][3])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/thermal/thermal_pro_joint_NE")

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Thermal generation N") do data
    return sum(data[:thermal_per][4])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/thermal/thermal_pro_joint_N")





   plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation SE") do data
     return sum(data[:hydroGeneration_per][1])                                         
   end,                                                  
   xlabel = "Month",
   ylabel = "MW-month %",
   xlims=(0,60),
   ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
   )                   
   savefig("figures/hydro/hydro_det_SE")

   plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation S") do data
    return sum(data[:hydroGeneration_per][2])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_det_S")

  plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation NE") do data
    return sum(data[:hydroGeneration_per][3])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_det_NE")

  plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation N") do data
    return sum(data[:hydroGeneration_per][4])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_det_N")
   


  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation SE") do data
    return sum(data[:hydroGeneration_per][1])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_pro_SE") 

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation S") do data
    return sum(data[:hydroGeneration_per][2])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_pro_S") 

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation NE") do data
    return sum(data[:hydroGeneration_per][3])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_pro_NE") 

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation N") do data
    return sum(data[:hydroGeneration_per][4])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_pro_N") 

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation SE") do data
    return sum(data[:hydroGeneration_per][1])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_pro_joint_SE") 

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation S") do data
    return sum(data[:hydroGeneration_per][2])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_pro_joint_S") 

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation NE") do data
    return sum(data[:hydroGeneration_per][3])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_pro_joint_NE") 

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Hydro generation N") do data
    return sum(data[:hydroGeneration_per][4])                                         
  end,                                                  
  xlabel = "Month",
  ylabel = "MW-month %",
  xlims=(0,60),
  ylims = (0,100),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )                   
  savefig("figures/hydro/hydro_pro_joint_N") 


   plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Water spillage SE") do data
     return sum(data[:spill_per][1])                                         
   end,                                                  
   xlabel = "Month",
   #ylabel = "MW-month %",
   xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
   )
                      
   savefig("figures/spill/spill_det_SE")

   plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Water spillage S") do data
    return sum(data[:spill_per][2])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_det_S")

  plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Water spillage NE") do data
    return sum(data[:spill_per][3])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_det_NE")

  plot(SDDP.publication_plot(simulat,  quantile = [0.05, 0.5, 0.95], title = "Water spillage N") do data
    return sum(data[:spill_per][4])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_det_N")



  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Water spillage SE") do data
    return sum(data[:spill_per][1])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_pro_SE") 

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Water spillage S") do data
    return sum(data[:spill_per][2])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_pro_S") 

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Water spillage NE") do data
    return sum(data[:spill_per][3])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_pro_NE") 

  plot(SDDP.publication_plot(simulat_1,  quantile = [0.05, 0.5, 0.95], title = "Water spillage N") do data
    return sum(data[:spill_per][4])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_pro_N") 

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Water spillage SE") do data
    return sum(data[:spill_per][1])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_pro_joint_SE") 

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Water spillage S") do data
    return sum(data[:spill_per][2])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_pro_joint_S") 

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Water spillage NE") do data
    return sum(data[:spill_per][3])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_pro_joint_NE") 

  plot(SDDP.publication_plot(simulat_2,  quantile = [0.05, 0.5, 0.95], title = "Water spillage N") do data
    return sum(data[:spill_per][4])                                         
  end,                                                  
  xlabel = "Month",
  #ylabel = "MW-month %",
  xlims=(0,60),
#   #ylims = (0,10),
# # # layout = (1, 2),
# # # margin_bottom = 1,
# # # size = (500, 300)
  )
                     
  savefig("figures/spill/spill_pro_joint_N") 




####################### SIMULAÇÃO PARA O CALCULO DE LIMITE SUPERIOR E INFERIOR DAS POLITICAS ######################################
# sims = SDDP.simulate(
# deterministic_model, 
# replic,
# custom_recorders = Dict{Symbol,Function}(
# #:shadow_price => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][1]),
# ), [:inflow, :storedEnergy_per, :demanda_determ, :demanda_cres, :spill_per, :hydroGeneration_per, :thermal_per], 
# );


# sims_1 = SDDP.simulate(
# probabilistic_model_1, 
# replic,
# custom_recorders = Dict{Symbol,Function}(
# #:shadow_price => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][1]),
# ), [:inflow, :storedEnergy_per, :demanda_determ, :demanda_cres, :spill_per, :hydroGeneration_per, :thermal_per], 
# );

#  sims_2 = SDDP.simulate(
#  probabilistic_model_2, 
#  replic,
#  custom_recorders = Dict{Symbol,Function}(
# # :shadow_price => (subproblem) -> JuMP.dual(subproblem[:demand_constraint][1]),
#  ), [:inflow, :storedEnergy_per, :demanda_determ, :demanda_cres, :spill_per, :hydroGeneration_per, :thermal_per], 
#  );  





println("Lower bound: ", SDDP.calculate_bound(deterministic_model))
# objectives = map(sims) do simulation
# return sum(stage[:stage_objective] for stage in simulation)
# end
# μ, ci = SDDP.confidence_interval(objectives)
# println("Confidence interval: ", μ, " ± ", ci)


println("Lower bound: ", SDDP.calculate_bound(probabilistic_model_1))    
# objectives_1 = map(sims_1) do simulation
# return sum(stage[:stage_objective] for stage in simulation)
# end
# μ_1, ci_1 = SDDP.confidence_interval(objectives_1)
# println("Confidence interval: ", μ_1, " ± ", ci_1)


 println("Lower bound: ", SDDP.calculate_bound(probabilistic_model_2))    
#  objectives_2 = map(sims_2) do simulation
#  return sum(stage[:stage_objective] for stage in simulation)
#  end
#  μ_2, ci_2 = SDDP.confidence_interval(objectives_2)
#  println("Confidence interval: ", μ_2, " ± ", ci_2)

#println("Lower bound: ", SDDP.calculate_bound(probabilistic_model_3))


open("trained_model.cvs", "w") do io
  for log in deterministic_model.most_recent_training_results.log
      push!(low_bound,log.bound);
  end  
 end

 open("trained_model_1.cvs", "w") do io
  for log in probabilistic_model_1.most_recent_training_results.log
      push!(low_bound_1,log.bound);
  end  
 end

 open("trained_model_2.cvs", "w") do io
  for log in probabilistic_model_2.most_recent_training_results.log
      push!(low_bound_2,log.bound);
  end  
 end

#  open("trained_model_3.cvs", "w") do io
#   for log in probabilistic_model_3.most_recent_training_results.log
#       push!(low_bound_3,log.bound);
#   end  
#  end


 plot(low_bound,label="Deter Lower Bound", linewidth=2)
 savefig("figures/cotas_inf/cota") 

 plot(low_bound_1,label="Sample Prob Lower Bound", linewidth=2)
 savefig("figures/cotas_inf/cota_1") 

 plot(low_bound_2,label="Sample Joint Lower Bound", linewidth=2)
 savefig("figures/cotas_inf/cota_2") 

 #plot(low_bound_3,label="Prob Lower Bound", linewidth=2)
 #savefig("figures/cotas_inf/cota_3") 

 plot(low_bound,label="Deter Constraint", linewidth=2)
 
 plot!(low_bound_1,label="Cont Constraint", linewidth=2)

 plot!(low_bound_2,label="Samp J. Constraint", title = "Lower Bound", linewidth=2)

 #plot!(low_bound_3,label="Cont Prob", linewidth=2)
 savefig("figures/cotas_inf/cota_juntas") 


end

main_principal()

  