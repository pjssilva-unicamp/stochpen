function demandas(i,alpha,beta,samples)


    demand = Array{Float64, 2}[
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

      SE_demand = CSV.read("matrices_dados/SE_demand.csv", DataFrame);
      S_demand = CSV.read("matrices_dados/S_demand.csv", DataFrame);
      NE_demand = CSV.read("matrices_dados/NE_demand.csv", DataFrame);
      N_demand = CSV.read("matrices_dados/N_demand.csv", DataFrame);

     escenarios=[
        [SE_demand[:,1], SE_demand[:,2], SE_demand[:,3], SE_demand[:,4], SE_demand[:,5], SE_demand[:,6], SE_demand[:,7], SE_demand[:,8], SE_demand[:,9], SE_demand[:,10], SE_demand[:,11], SE_demand[:,12], SE_demand[:,13], SE_demand[:,14], SE_demand[:,15], SE_demand[:,16], SE_demand[:,17], SE_demand[:,18], SE_demand[:,19], SE_demand[:,20], SE_demand[:,21], SE_demand[:,22], SE_demand[:,23], SE_demand[:,24], SE_demand[:,25], SE_demand[:,26], SE_demand[:,27], SE_demand[:,28], SE_demand[:,29], SE_demand[:,30], SE_demand[:,31], SE_demand[:,32], SE_demand[:,33], SE_demand[:,34], SE_demand[:,35], SE_demand[:,36], SE_demand[:,37], SE_demand[:,38], SE_demand[:,39], SE_demand[:,40], SE_demand[:,41], SE_demand[:,42], SE_demand[:,43], SE_demand[:,44], SE_demand[:,45], SE_demand[:,46], SE_demand[:,47], SE_demand[:,48], SE_demand[:,49], SE_demand[:,50], SE_demand[:,51], SE_demand[:,52], SE_demand[:,53], SE_demand[:,54], SE_demand[:,55], SE_demand[:,56], SE_demand[:,57], SE_demand[:,58], SE_demand[:,59], SE_demand[:,60], SE_demand[:,61], SE_demand[:,62], SE_demand[:,63], SE_demand[:,64], SE_demand[:,65], SE_demand[:,66], SE_demand[:,67], SE_demand[:,68], SE_demand[:,69], SE_demand[:,70], SE_demand[:,71], SE_demand[:,72], SE_demand[:,73], SE_demand[:,74], SE_demand[:,75], SE_demand[:,76], SE_demand[:,77], SE_demand[:,78], SE_demand[:,79], SE_demand[:,80], SE_demand[:,81], SE_demand[:,82], SE_demand[:,83], SE_demand[:,84], SE_demand[:,85], SE_demand[:,86], SE_demand[:,87], SE_demand[:,88], SE_demand[:,89], SE_demand[:,90], SE_demand[:,91], SE_demand[:,92], SE_demand[:,93], SE_demand[:,94], SE_demand[:,95], SE_demand[:,96], SE_demand[:,97], SE_demand[:,98], SE_demand[:,99], SE_demand[:,100], SE_demand[:,101], SE_demand[:,102], SE_demand[:,103], SE_demand[:,104], SE_demand[:,105], SE_demand[:,106], SE_demand[:,107], SE_demand[:,108], SE_demand[:,109], SE_demand[:,110], SE_demand[:,111], SE_demand[:,112], SE_demand[:,113], SE_demand[:,114], SE_demand[:,115], SE_demand[:,116], SE_demand[:,117], SE_demand[:,118], SE_demand[:,119], SE_demand[:,120]], 

      [S_demand[:,1], S_demand[:,2], S_demand[:,3], S_demand[:,4], S_demand[:,5], S_demand[:,6], S_demand[:,7], S_demand[:,8], S_demand[:,9], S_demand[:,10], S_demand[:,11], S_demand[:,12], S_demand[:,13], S_demand[:,14], S_demand[:,15], S_demand[:,16], S_demand[:,17], S_demand[:,18], S_demand[:,19], S_demand[:,20], S_demand[:,21], S_demand[:,22], S_demand[:,23], S_demand[:,24], S_demand[:,25], S_demand[:,26], S_demand[:,27], S_demand[:,28], S_demand[:,29], S_demand[:,30], S_demand[:,31], S_demand[:,32], S_demand[:,33], S_demand[:,34], S_demand[:,35], S_demand[:,36], S_demand[:,37], S_demand[:,38], S_demand[:,39], S_demand[:,40], S_demand[:,41], S_demand[:,42], S_demand[:,43], S_demand[:,44], S_demand[:,45], S_demand[:,46], S_demand[:,47], S_demand[:,48], S_demand[:,49], S_demand[:,50], S_demand[:,51], S_demand[:,52], S_demand[:,53], S_demand[:,54], S_demand[:,55], S_demand[:,56], S_demand[:,57], S_demand[:,58], S_demand[:,59], S_demand[:,60], S_demand[:,61], S_demand[:,62], S_demand[:,63], S_demand[:,64], S_demand[:,65], S_demand[:,66], S_demand[:,67], S_demand[:,68], S_demand[:,69], S_demand[:,70], S_demand[:,71], S_demand[:,72], S_demand[:,73], S_demand[:,74], S_demand[:,75], S_demand[:,76], S_demand[:,77], S_demand[:,78], S_demand[:,79], S_demand[:,80], S_demand[:,81], S_demand[:,82], S_demand[:,83], S_demand[:,84], S_demand[:,85], S_demand[:,86], S_demand[:,87], S_demand[:,88], S_demand[:,89], S_demand[:,90], S_demand[:,91], S_demand[:,92], S_demand[:,93], S_demand[:,94], S_demand[:,95], S_demand[:,96], S_demand[:,97], S_demand[:,98], S_demand[:,99], S_demand[:,100], S_demand[:,101], S_demand[:,102], S_demand[:,103], S_demand[:,104], S_demand[:,105], S_demand[:,106], S_demand[:,107], S_demand[:,108], S_demand[:,109], S_demand[:,110], S_demand[:,111], S_demand[:,112], S_demand[:,113], S_demand[:,114], S_demand[:,115], S_demand[:,116], S_demand[:,117], S_demand[:,118], S_demand[:,119], S_demand[:,120]],


      [NE_demand[:,1], NE_demand[:,2], NE_demand[:,3], NE_demand[:,4], NE_demand[:,5], NE_demand[:,6], NE_demand[:,7], NE_demand[:,8], NE_demand[:,9], NE_demand[:,10], NE_demand[:,11], NE_demand[:,12], NE_demand[:,13], NE_demand[:,14], NE_demand[:,15], NE_demand[:,16], NE_demand[:,17], NE_demand[:,18], NE_demand[:,19], NE_demand[:,20], NE_demand[:,21], NE_demand[:,22], NE_demand[:,23], NE_demand[:,24], NE_demand[:,25], NE_demand[:,26], NE_demand[:,27], NE_demand[:,28], NE_demand[:,29], NE_demand[:,30], NE_demand[:,31], NE_demand[:,32], NE_demand[:,33], NE_demand[:,34], NE_demand[:,35], NE_demand[:,36], NE_demand[:,37], NE_demand[:,38], NE_demand[:,39], NE_demand[:,40], NE_demand[:,41], NE_demand[:,42], NE_demand[:,43], NE_demand[:,44], NE_demand[:,45], NE_demand[:,46], NE_demand[:,47], NE_demand[:,48], NE_demand[:,49], NE_demand[:,50], NE_demand[:,51], NE_demand[:,52], NE_demand[:,53], NE_demand[:,54], NE_demand[:,55], NE_demand[:,56], NE_demand[:,57], NE_demand[:,58], NE_demand[:,59], NE_demand[:,60], NE_demand[:,61], NE_demand[:,62], NE_demand[:,63], NE_demand[:,64], NE_demand[:,65], NE_demand[:,66], NE_demand[:,67], NE_demand[:,68], NE_demand[:,69], NE_demand[:,70], NE_demand[:,71], NE_demand[:,72], NE_demand[:,73], NE_demand[:,74], NE_demand[:,75], NE_demand[:,76], NE_demand[:,77], NE_demand[:,78], NE_demand[:,79], NE_demand[:,80], NE_demand[:,81], NE_demand[:,82], NE_demand[:,83], NE_demand[:,84], NE_demand[:,85], NE_demand[:,86], NE_demand[:,87], NE_demand[:,88], NE_demand[:,89], NE_demand[:,90], NE_demand[:,91], NE_demand[:,92], NE_demand[:,93], NE_demand[:,94], NE_demand[:,95], NE_demand[:,96], NE_demand[:,97], NE_demand[:,98], NE_demand[:,99], NE_demand[:,100], NE_demand[:,101], NE_demand[:,102], NE_demand[:,103], NE_demand[:,104], NE_demand[:,105], NE_demand[:,106], NE_demand[:,107], NE_demand[:,108], NE_demand[:,109], NE_demand[:,110], NE_demand[:,111], NE_demand[:,112], NE_demand[:,113], NE_demand[:,114], NE_demand[:,115], NE_demand[:,116], NE_demand[:,117], NE_demand[:,118], NE_demand[:,119], NE_demand[:,120]],


      [N_demand[:,1], N_demand[:,2], N_demand[:,3], N_demand[:,4], N_demand[:,5], N_demand[:,6], N_demand[:,7], N_demand[:,8], N_demand[:,9], N_demand[:,10], N_demand[:,11], N_demand[:,12], N_demand[:,13], N_demand[:,14], N_demand[:,15], N_demand[:,16], N_demand[:,17], N_demand[:,18], N_demand[:,19], N_demand[:,20], N_demand[:,21], N_demand[:,22], N_demand[:,23], N_demand[:,24], N_demand[:,25], N_demand[:,26], N_demand[:,27], N_demand[:,28], N_demand[:,29], N_demand[:,30], N_demand[:,31], N_demand[:,32], N_demand[:,33], N_demand[:,34], N_demand[:,35], N_demand[:,36], N_demand[:,37], N_demand[:,38], N_demand[:,39], N_demand[:,40], N_demand[:,41], N_demand[:,42], N_demand[:,43], N_demand[:,44], N_demand[:,45], N_demand[:,46], N_demand[:,47], N_demand[:,48], N_demand[:,49], N_demand[:,50], N_demand[:,51], N_demand[:,52], N_demand[:,53], N_demand[:,54], N_demand[:,55], N_demand[:,56], N_demand[:,57], N_demand[:,58], N_demand[:,59], N_demand[:,60], N_demand[:,61], N_demand[:,62], N_demand[:,63], N_demand[:,64], N_demand[:,65], N_demand[:,66], N_demand[:,67], N_demand[:,68], N_demand[:,69], N_demand[:,70], N_demand[:,71], N_demand[:,72], N_demand[:,73], N_demand[:,74], N_demand[:,75], N_demand[:,76], N_demand[:,77], N_demand[:,78], N_demand[:,79], N_demand[:,80], N_demand[:,81], N_demand[:,82], N_demand[:,83], N_demand[:,84], N_demand[:,85], N_demand[:,86], N_demand[:,87], N_demand[:,88], N_demand[:,89], N_demand[:,90], N_demand[:,91], N_demand[:,92], N_demand[:,93], N_demand[:,94], N_demand[:,95], N_demand[:,96], N_demand[:,97], N_demand[:,98], N_demand[:,99], N_demand[:,100], N_demand[:,101], N_demand[:,102], N_demand[:,103], N_demand[:,104], N_demand[:,105], N_demand[:,106], N_demand[:,107], N_demand[:,108], N_demand[:,109], N_demand[:,110], N_demand[:,111], N_demand[:,112], N_demand[:,113], N_demand[:,114], N_demand[:,115], N_demand[:,116], N_demand[:,117], N_demand[:,118], N_demand[:,119], N_demand[:,120]] 
     ]
     
     DEMANDAS = Vector{Vector{Float64}}();
     for t in 1:120
     month = t % 12 == 0 ? 12 : t % 12

     #if i == 1
        mu = (alpha*demand[month][i]/12000)*t+demand[month][i];
        des = beta/100*mu*0.1*sqrt(t);
     #else
      #  mu = demand[month][i];
      #  des = 0;
    #end

     deman = Float64[];


    for j in 1:samples
        push!(deman, des*escenarios[i][t][j]+mu) #des*randn()+mu

     end
     push!(DEMANDAS, deman);

    end

     return DEMANDAS
end