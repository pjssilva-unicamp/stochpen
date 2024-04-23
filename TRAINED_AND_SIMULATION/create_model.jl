


function create_model(model::Bool, alpha::Int, beta::Int, samples)
     return SDDP.LinearPolicyGraph(
         stages = 120,
         lower_bound = 0.0,
         sense = :Min,
         optimizer = Gurobi.Optimizer,
     ) do subproblem, t

     #alpha=10;
     #beta=1;
    

     thermal_ub = Array{Float64, 2}[
        [640 53 4474 0 1350 1338.3 38.5 204 0 136.12 140.44 0 0 50 0 1823 496.92 36 15.95 405.72 255 74.96 37.48 0 1560.7 0 0 15813 436.5 0 87.05 3136.78 1620 0 2870 1366 9478.70 432],
        [345 8 350 3.60 330 220 10.32 80 110 0 0 0 248.57],
        [16.79 61.32 594 28.02 53.12 98.5 143.04 94.08 31.95 365 429.63 1050 720 3431.33 0 55.99 6315.2 37.44 647 185.89 169.08 1041.60 1041.60 142.59 523 162.31 162.31 465 1047 200.74],
        [56.30 2769.60 360.14 166 68.30 75.44 73.40 73.40 93 337.60 518.80 365.32 337.60 178.21 159.08 159.16]
    ] 
  
     thermal_lb = Array{Float64,2}[
         [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],
         [0 0 0 0 0 0 0 0 0 0 0 0 0],
         [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],
         [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
     ]

    thermal_ub_reservoir  =[48370.11 1705.49 19313.53 5791.35] 
    #thermal_lb_reservoir = [0 0 0 0]  
    
    
    
    
    thermal_obj = Array{Float64, 2}[
         [31.17 3680.38 746.46 0 20.12 292.53 143.16 231.39 0 2701.57 2252.16 910.86 152.94 132.53 0 697.21 697.21 1005.25 988.63 813.25 813.16 1005.25 1005.25 0 0 310.41 0 388.40 969.55 470.34 813.07 0 514.66 561.34 320.66 155.86 908.2 413.04],
         [82.18 103.4 107.02 381.47 311.53 362.67 708.84 434.59 372.62 330.64 0 0 1066.54],
         [103.47 1261.31 2032.67 195.14 3022.58 957.74 3374.48 3374.48 3022.54 314.47 1852.16 1852.16 307.20 986.34 510.12 198.84 325.64 264.74 285.83 617.68 969.56 1099.04  1099.04 941 566.66 962.72 962.72 450.86 229.6 832.58],
         [151.69 83.29 307.21 83.29 0 0 0 0 0 145.59 101 186.77 145.59 273.69 969.53 969.53]
    ]
    N_THERMAL = [38, 13, 30, 16]
    
    @assert N_THERMAL == length.(thermal_obj) == length.(thermal_lb) ==
        length.(thermal_ub)
    hydro_ub = [52506.05, 13693.91, 9165.06, 17021.89]  #  com BELO MONTE hydro_ub = [52506.05, 13693.91, 9165.06, 17021.89]
    storedEnergy_initial = [59419.3000, 5874.9000, 12859.2000, 5271.5000] # 41593.51
    storedEnergy_ub = [200717.6, 19617.2, 51806.1, 12744.9] # certo
   
    exchange_ub =  Array{Float64, 2}[
        [0	        0	4700	 2500	   4000],
        [5625	    0	   0	    0	      0],
        [6300	    0	   0	    0	      0],
        [0  	    0	   0	    0     99999], 
        [99999	    0	5500    99999	      0]
    ]

    # exchange_ub =  Array{Float64, 2}[
    #     [0	    0	4700	 2500	   4000],
    #     [5625	    0	   0	    0	      0],
    #     [6300	0	   0	    0	   6000],
    #     [6000	0	   0	    0     99999], 
    #     [99999	0	5500    99999	      0]
    # ]


    deficit_obj = [1142.8, 2465.4, 5152.46, 5845.54] # certo
    deficit_ub = [0.05, 0.05, 0.1, 0.8];
    
    
    
     demand =  Array{Float64, 2}[
         [45515  11692  10811  6507],
         [46611  11933  10683  6564],
         [47134  12005  10727  6506],
         [46429  11478  10589  6556],
         [45622  11145  10389  6645],
         [45366  11146  10129  6669],
         [45477  11055  10157  6627],
         [46149  11051  10372  6772],
         [46336  10917  10675  6843],
         [46551  11015  10934  6815],
         [46035  11156  11004  6871],
         [45234  11297  10914  6701]
         ]    
         
    
        #samples = 82;

        scenarios =[
            inflows(1,samples), demandas(1,alpha,beta,samples),  
    
            inflows(2,samples), demandas(2,alpha,beta,samples),    
    
            inflows(3,samples), demandas(3,alpha,beta,samples),        
            
            inflows(4,samples), demandas(4,alpha,beta,samples)
            ]

        inflow_initial = [53442.7, 6029.9, 18154.9, 5514.4] # certo
        demanda_initial=[45515  11692  10811  6507]

        set_optimizer_attribute(subproblem, "OutputFlag", 0)
        month = t % 12 == 0 ? 12 : t % 12 

        @variable(subproblem,
            0.0 <= storedEnergy[i = 1:4] <= storedEnergy_ub[i],
            SDDP.State, initial_value = storedEnergy_initial[i])
        @variables(subproblem, begin
            0 <= spillEnergy[i = 1:4]
            0 <= hydroGeneration[i = 1:4] <= hydro_ub[i]
            0 <= thermal[i = 1:4, j = 1:N_THERMAL[i]] <= thermal_ub[i][j]
            0 <= exchange[i = 1:5, j = 1:5] <= exchange_ub[i][j]  
        
               
            #0 <= deficit[i = 1:4, j = 1:4] <=  demand[month][i] * deficit_ub[j] 
                
             inflow[i = 1:4] == inflow_initial[i]  
             demanda_es[i = 1:4] == demanda_initial[i]  
             0 <= storedEnergy_per[i=1:4];
             0 <= spill_per[i=1:4];
             0 <= thermal_per[i = 1:4];
             #0 <= thermal_2[i = 1:4];
             0 <= hydroGeneration_per[i=1:4]; 
             0 <= demanda_determ[i=1:4];
             0 <= demanda_cres[i=1:4];
             #0 <= demanda_es_porcen[i=1:4]; 
             #sum_exchange[i=1:4];
             #sum_deficit[i=1:4];
             #0 <= cono[i=1:4];
             0 <= deficit[i = 1:4, j = 1:4] <= demand[month][i]*deficit_ub[j]; #(alpha*(demand[month][i]/12000)*t+demand[month][i])* deficit_ub[j];
  
         end) 

         

         @stageobjective(subproblem, sum(deficit_obj[i] * sum(deficit[i, :]) for i in 1:4) +sum(thermal_obj[i][j] * thermal[i, j] for i in 1:4 for j in 1:N_THERMAL[i])) 


         @constraints(subproblem, begin
                #[i = 1:4, j = 1:4], deficit[i,j] <=  demanda_es[i]* deficit_ub[j]
                #demand_constraint[i = 1:4], sum(deficit[i, :]) + hydroGeneration[i] + sum(thermal[i, j] for j in 1:N_THERMAL[i]) +
                 #sum(exchange[:, i])-sum(exchange[i, :])  >= (demand[month][i]/1200)*t+demand[month][i]+5/100*((demand[month][i]/1200)*t+demand[month][i])*sqrt(2)#*erfinv(2*0.9-1)  ; 
                exchange_constraint, sum(exchange[:, 5]) == sum(exchange[5, :])
                state_constraint[i = 1:4], storedEnergy[i].out + spillEnergy[i] +
                hydroGeneration[i] - storedEnergy[i].in == inflow[i] 
                [i = 1:4], storedEnergy_per[i] == (storedEnergy[i].out)*100/storedEnergy_ub[i]  
                [i = 1:4], thermal_per[i] == sum(thermal[i, j] for j in 1:N_THERMAL[i])*100/thermal_ub_reservoir[i]
                [i = 1:4], hydroGeneration_per[i] == 100*hydroGeneration[i]/hydro_ub[i]
                #[i = 1:4], thermal_2[i] == sum(thermal[i, j] for j in 1:N_THERMAL[i])
                #[i = 1:4], sum_exchange[i] == sum(exchange[:, i])-sum(exchange[i, :]);
                #[i = 1:4], sum_deficit[i] == sum(deficit[i, :]);
                [i = 1:4], spill_per[i] == 100*spillEnergy[i]/storedEnergy_ub[i];
                [i = 1:4], demanda_determ[i] == 100*demand[month][i]/(hydro_ub[i]+thermal_ub_reservoir[i]);
                [i = 1:4], demanda_cres[i] == 100*(alpha*(demand[month][i]/12000)*t+demand[month][i])/(hydro_ub[i]+thermal_ub_reservoir[i]);
                #[i = 1:4], demanda_es_porcen[i] == (100*demanda_es[i])/(hydro_ub[i]+thermal_ub_reservoir[i]);
                 end)


            
                
                   if model 
                   @constraints(subproblem, begin
                     demand_constraint[i = 1:4], sum(deficit[i, :]) + hydroGeneration[i] + sum(thermal[i, j] for j in 1:N_THERMAL[i]) +
                  sum(exchange[:, i])-sum(exchange[i, :])  == demand[month][i];
                   end)
                   end

                 if t != 1  # t=1 is handled in the @variable constructor.
                    r = t-1  #% 12 == 0 ? 12 : (t - 1) % 12
                     SDDP.parameterize(subproblem, 1:length(scenarios[1][r]))   do ω  #
        
                    for i in 1:4
                            JuMP.fix(inflow[i], scenarios[2*i-1][r][ω]) #, JuMP.fix(demanda_es[i], scenarios[2*i][r][ω])                                    
                    end
                 end

                 

                end
    end
end




