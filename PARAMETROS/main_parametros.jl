using XLSX, Plots, StatsPlots, LaTeXStrings, StatsBase, LinearAlgebra

include("./variance.jl")
include("./covariance.jl")
include("./corr.jl")

function main_parametros(amostras)

    historico = XLSX.readxlsx("Historico_ENAS_ate_2021.xlsx");
    
    long = amostras*12   # Longitud de la série sintética
     
    
    ######### Monthly averages of SE ###############
    historical = historico["Planilha1"];
    

    Mu_SE = Float64[];
    for t in 1:12
        push!(Mu_SE, sum(log.(historical[:][:,t]))/91);
    end
    ################################################
    
    ######### Monthly averages of S ##################
    Mu_S = Float64[];
    for t in 14:25
        push!(Mu_S, sum(log.(historical[:][:,t]))/91);
    end
    ##################################################
    
    ######### Monthly averages of NE ###############
    Mu_NE = Float64[];
    for t in 27:38
        push!(Mu_NE, sum(log.(historical[:][:,t]))/91);
    end
    #################################################
    
    ######### Monthly averages of N ###############
    Mu_N = Float64[];
    for t in 40:51
        push!(Mu_N, sum(log.(historical[:][:,t]))/91);
    end
    ################################################

    ########## Historical Mean SE #####################3

    Mean_SE = Float64[];
    for t in 1:12
        push!(Mean_SE, sum(historical[:][:,t])/91);
    end

    ########## Historical Mean S #####################3

    Mean_S = Float64[];
    for t in 14:25
        push!(Mean_S, sum(historical[:][:,t])/91);
    end

    ########## Historical Mean NE #####################3

    Mean_NE = Float64[];
    for t in 27:38
        push!(Mean_NE, sum(historical[:][:,t])/91);
    end

    ########## Historical Mean N #####################3

    Mean_N = Float64[];
    for t in 40:51
        push!(Mean_N, sum(historical[:][:,t])/91);
    end
   



    ######### GAMMA SE ##################
    Gamma_SE = Float64[];
    push!(Gamma_SE, ((historical[:][:,1].-exp(Mu_SE[1]))./exp(Mu_SE[1]))\((historical[:][:,12].-exp(Mu_SE[12]))./exp(Mu_SE[12])))
    for t in 2:12
        push!(Gamma_SE, ((historical[:][:,t].-exp(Mu_SE[t]))./exp(Mu_SE[t]))\((historical[:][:,t-1].-exp(Mu_SE[t-1]))./exp(Mu_SE[t-1])))
    end
    #####################################

    ######### GAMMA S ##################
    Gamma_S = Float64[];
    push!(Gamma_S, ((historical[:][:,14].-exp(Mu_S[1]))./exp(Mu_S[1]))\((historical[:][:,25].-exp(Mu_S[12]))./exp(Mu_S[12])))
    for t in 15:25
        push!(Gamma_S, ((historical[:][:,t].-exp(Mu_S[t-13]))./exp(Mu_S[t-13]))\((historical[:][:,t-1].-exp(Mu_S[t-14]))./exp(Mu_S[t-14])))
    end
    #####################################


    ######### GAMMA NE ##################
    Gamma_NE = Float64[];
    push!(Gamma_NE, ((historical[:][:,27].-exp(Mu_NE[1]))./exp(Mu_NE[1]))\((historical[:][:,38].-exp(Mu_NE[12]))./exp(Mu_NE[12])))
    for t in 28:38
        push!(Gamma_NE, ((historical[:][:,t].-exp(Mu_NE[t-26]))./exp(Mu_NE[t-26]))\((historical[:][:,t-1].-exp(Mu_NE[t-27]))./exp(Mu_NE[t-27])))
    end
    #####################################
 

    ######### GAMMA N ##################
    Gamma_N = Float64[];
    push!(Gamma_N, ((historical[:][:,40].-exp(Mu_N[1]))./exp(Mu_N[1]))\((historical[:][:,51].-exp(Mu_N[12]))./exp(Mu_N[12])))
    for t in 41:51
        push!(Gamma_N, ((historical[:][:,t].-exp(Mu_N[t-39]))./exp(Mu_N[t-39]))\((historical[:][:,t-1].-exp(Mu_N[t-40]))./exp(Mu_N[t-40])))
    end
    #####################################

    
     ##################### VARIANCE SE ############## 
    #    Var_SE = Float64[];
    #    for t in 1:12
    #        push!(Var_SE, variance(log.(historical[:][:,t])));
    #    end
    

    # # ##################### VARIANCE S ################
    #   Var_S = Float64[];
    #   for t in 14:25
    #       push!(Var_S, variance(log.(historical[:][:,t])));
    #   end

    # # ##################### VARIANCE NE ################
    #   Var_NE = Float64[];
    #   for t in 27:38
    #       push!(Var_NE, variance(log.(historical[:][:,t])));
    #   end

     # # ##################### VARIANCE N ################

    #    Var_N = Float64[];
    #    for t in 40:51
    #        push!(Var_N, variance(log.(historical[:][:,t])));
    #    end

    # hist_SE=[historical[:][:,1];historical[:][:,2];historical[:][:,3];historical[:][:,4];historical[:][:,5];historical[:][:,6];historical[:][:,7];historical[:][:,8];historical[:][:,9];historical[:][:,10];historical[:][:,11];historical[:][:,12]]
    # hist_S=[historical[:][:,14];historical[:][:,15];historical[:][:,16];historical[:][:,17];historical[:][:,18];historical[:][:,19];historical[:][:,20];historical[:][:,21];historical[:][:,22];historical[:][:,23];historical[:][:,24];historical[:][:,25]]
    # hist_NE=[historical[:][:,27];historical[:][:,28];historical[:][:,29];historical[:][:,30];historical[:][:,31];historical[:][:,32];historical[:][:,33];historical[:][:,34];historical[:][:,35];historical[:][:,36];historical[:][:,37];historical[:][:,38]]
    # hist_N=[historical[:][:,40];historical[:][:,41];historical[:][:,42];historical[:][:,43];historical[:][:,44];historical[:][:,45];historical[:][:,46];historical[:][:,47];historical[:][:,48];historical[:][:,49];historical[:][:,50];historical[:][:,51]]
    # Cor=[1 corr(hist_SE,hist_S) corr(hist_SE,hist_NE) corr(hist_SE,hist_N); corr(hist_S,hist_SE) 1 corr(hist_S,hist_NE) corr(hist_S,hist_N); corr(hist_NE,hist_SE) corr(hist_NE,hist_S) 1 corr(hist_NE,hist_N); corr(hist_N,hist_SE) corr(hist_N,hist_S) corr(hist_N,hist_NE) 1]
    # C=cholesky(Cor)
    # D=C.L
    ####### MODELAGEM DOS ERROS ############################################
    
    #e1= randn(long); e2=randn(long); e3= randn(long); e4=randn(long); #0.1; 0.4; 0.2; 0.15

    


    
    
     se = Vector{Float64}(undef,long)
     se[1]=exp(0.15*randn(1)[1])*(exp(Mu_SE[1])+Gamma_SE[1]*exp(Mu_SE[1]-Mu_SE[12])*(historical[:][:,12][91]-exp(Mu_SE[12]))) #(D*[e1[1]; e2[1]; e3[1]; e4[1]])[1]
     for t in 2:long
         month = t % 12 == 0 ? 12 : t % 12
         if month == 1
             month_12=12
         else
             month_12=month-1
         end
         se[t] = exp(0.15*randn(1)[1])*(exp(Mu_SE[month])+Gamma_SE[month]*exp(Mu_SE[month]-Mu_SE[month_12])*(se[t-1]-exp(Mu_SE[month_12])))
     end

    SE = Matrix{Float64}(undef,amostras,12)
    for i in 1:amostras
        SE[i,:] = se[12*(i-1)+1:12*i]
    end



     s = Vector{Float64}(undef,long)
     s[1] = exp(0.4*randn(1)[1])*(exp(Mu_S[1])+Gamma_S[1]*exp(Mu_S[1]-Mu_S[12])*(historical[:][:,25][91]-exp(Mu_S[12]))) #(D*[e1[1]; e2[1]; e3[1]; e4[1]])[2]
     for t in 2:long
         month = t % 12 == 0 ? 12 : t % 12
         if month == 1
             month_12=12
         else
             month_12=month-1
         end
         s[t] = exp(0.4*randn(1)[1])*(exp(Mu_S[month])+Gamma_S[month]*exp(Mu_S[month]-Mu_S[month_12])*(s[t-1]-exp(Mu_S[month_12])))
     end

    S = Matrix{Float64}(undef,amostras,12)
    for i in 1:amostras
        S[i,:] = s[12*(i-1)+1:12*i]
    end
    


     ne = Vector{Float64}(undef,long)
     ne[1] = exp(0.2*randn(1)[1])*(exp(Mu_NE[1])+Gamma_NE[1]*exp(Mu_NE[1]-Mu_NE[12])*(historical[:][:,38][91]-exp(Mu_NE[12]))) #(D*[e1[1]; e2[1]; e3[1]; e4[1]])[3]
     for t in 2:long
         month = t % 12 == 0 ? 12 : t % 12
         if month == 1
             month_12=12
         else
             month_12=month-1
         end
         ne[t] = exp(0.2*randn(1)[1])*(exp(Mu_NE[month])+Gamma_NE[month]*exp(Mu_NE[month]-Mu_NE[month_12])*(ne[t-1]-exp(Mu_NE[month_12])))
     end

    NE = Matrix{Float64}(undef,amostras,12)
    for i in 1:amostras
        NE[i,:] = ne[12*(i-1)+1:12*i]
    end

    

     n = Vector{Float64}(undef,long)
     n[1] = exp(0.13*randn(1)[1])*(exp(Mu_N[1])+Gamma_N[1]*exp(Mu_N[1]-Mu_N[12])*(historical[:][:,51][91]-exp(Mu_N[12]))) #(D*[e1[1]; e2[1]; e3[1]; e4[1]])[4]
     for t in 2:long
         month = t % 12 == 0 ? 12 : t % 12
         if month == 1
             month_12=12
         else
             month_12=month-1
         end
         n[t] = exp(0.13*randn(1)[1])*(exp(Mu_N[month])+Gamma_N[month]*exp(Mu_N[month]-Mu_N[month_12])*(n[t-1]-exp(Mu_N[month_12])))
     end

    N = Matrix{Float64}(undef,amostras,12)
    for i in 1:amostras
        N[i,:] = n[12*(i-1)+1:12*i]
    end



    ########## Synthetic Mean SE #####################3

    Mean_syn_SE = Float64[];
    for t in 1:12
        push!(Mean_syn_SE, sum(SE[:,t])/amostras);
    end

    ########## Synthetic Mean S #####################3

    Mean_syn_S = Float64[];
    for t in 1:12
        push!(Mean_syn_S, sum(S[:,t])/amostras);
    end

    ########## Synthetic Mean NE #####################3

    Mean_syn_NE = Float64[];
    for t in 1:12
        push!(Mean_syn_NE, sum(NE[:,t])/amostras);
    end

     ########## Synthetic Mean NE #####################3

     Mean_syn_N = Float64[];
     for t in 1:12
         push!(Mean_syn_N, sum(N[:,t])/amostras);
     end

    
  
    boxplot(SE[:,1], label = false, color = :skyblue)
    boxplot!(SE[:,2], label = false, color = :skyblue)
    boxplot!(SE[:,3], label = false, color = :skyblue)
    boxplot!(SE[:,4], label = false, color = :skyblue)
    boxplot!(SE[:,5], label = false, color = :skyblue)
    boxplot!(SE[:,6], label = false, color = :skyblue)
    boxplot!(SE[:,7], label = false, color = :skyblue)
    boxplot!(SE[:,8], label = false, color = :skyblue)
    boxplot!(SE[:,9], label = false, color = :skyblue)
    boxplot!(SE[:,10], label = false, color = :skyblue)
    boxplot!(SE[:,11], label = false, color = :skyblue)
    boxplot!(SE[:,12], label = false, color = :skyblue, title = "Synthetic inflow SE")
    #plot!(Mean_SE, seriestype=:scatter,  label = "Historical Mean", mc=:red)
    xlabel!("Month")
    ylabel!("MW-month")
    xlims!(0,13)
    ylims!(0,130000)
    savefig("figures/SE.pdf") 


    boxplot(S[:,1], label = false, color = :skyblue)
    boxplot!(S[:,2], label = false, color = :skyblue)
    boxplot!(S[:,3], label = false, color = :skyblue)
    boxplot!(S[:,4], label = false, color = :skyblue)
    boxplot!(S[:,5], label = false, color = :skyblue)
    boxplot!(S[:,6], label = false, color = :skyblue)
    boxplot!(S[:,7], label = false, color = :skyblue)
    boxplot!(S[:,8], label = false, color = :skyblue)
    boxplot!(S[:,9], label = false, color = :skyblue)
    boxplot!(S[:,10], label = false, color = :skyblue)
    boxplot!(S[:,11], label = false, color = :skyblue)
    boxplot!(S[:,12], label = false, color = :skyblue, title = "Synthetic inflow S")
    #plot!(Mean_S, seriestype=:scatter,  label = "Historical Mean", mc=:red)
    xlabel!("Month")
    ylabel!("MW-month")
    xlims!(0,13)
    ylims!(0,70000)
    savefig("figures/S.pdf") 

    boxplot(NE[:,1], label = false, color = :skyblue)
    boxplot!(NE[:,2], label = false, color = :skyblue)
    boxplot!(NE[:,3], label = false, color = :skyblue)
    boxplot!(NE[:,4], label = false, color = :skyblue)
    boxplot!(NE[:,5], label = false, color = :skyblue)
    boxplot!(NE[:,6], label = false, color = :skyblue)
    boxplot!(NE[:,7], label = false, color = :skyblue)
    boxplot!(NE[:,8], label = false, color = :skyblue)
    boxplot!(NE[:,9], label = false, color = :skyblue)
    boxplot!(NE[:,10], label = false, color = :skyblue)
    boxplot!(NE[:,11], label = false, color = :skyblue)
    boxplot!(NE[:,12], label = false, color = :skyblue, title = "Synthetic inflow NE")
    #plot!(Mean_NE, seriestype=:scatter,  label = "Historical Mean", mc=:red)
    xlabel!("Month")
    ylabel!("MW-month")
    xlims!(0,13)
    ylims!(0,50000)
    savefig("figures/NE.pdf") 

    boxplot(N[:,1], label = false, color = :skyblue)
    boxplot!(N[:,2], label = false, color = :skyblue)
    boxplot!(N[:,3], label = false, color = :skyblue)
    boxplot!(N[:,4], label = false, color = :skyblue)
    boxplot!(N[:,5], label = false, color = :skyblue)
    boxplot!(N[:,6], label = false, color = :skyblue)
    boxplot!(N[:,7], label = false, color = :skyblue)
    boxplot!(N[:,8], label = false, color = :skyblue)
    boxplot!(N[:,9], label = false, color = :skyblue)
    boxplot!(N[:,10], label = false, color = :skyblue)
    boxplot!(N[:,11], label = false, color = :skyblue)
    boxplot!(N[:,12], label = false, color = :skyblue, title = "Synthetic inflow N")
    #plot!(Mean_N, seriestype=:scatter,  label = "Historical Mean", mc=:red)
    xlabel!("Month")
    ylabel!("MW-month")
    xlims!(0,13)
    ylims!(0,50000)
    savefig("figures/N.pdf") 
    

    
     plot(Mean_SE, seriestype=:scatter, label = "Historical Mean")
     plot!(Mean_syn_SE, seriestype=:scatter, label = "Synthetic Mean", title = "Mean SE")
     xlabel!("Month")
     #ylabel!("MW-month")
     xlims!(0,13)
     savefig("figures/Mean_SE.pdf")

      plot(Mean_S, seriestype=:scatter, label = "Historical Mean")
      plot!(Mean_syn_S, seriestype=:scatter, label = "Synthetic Mean", title = "Mean S")
      xlabel!("Month")
      #ylabel!("MW-month")
      xlims!(0,13)
      savefig("figures/Mean_S.pdf")

     plot(Mean_NE, seriestype=:scatter, label = "Historical Mean")
     plot!(Mean_syn_NE, seriestype=:scatter, label = "Synthetic Mean", title = "Mean NE")
     xlabel!("Month")
     #ylabel!("MW-month")
     xlims!(0,13)
     savefig("figures/Mean_NE.pdf")

      plot(Mean_N, seriestype=:scatter, label = "Historical Mean")
      plot!(Mean_syn_N, seriestype=:scatter, label = "Synthetic Mean", title = "Mean N")
      xlabel!("Month")
      #ylabel!("MW-month")
      xlims!(0,13)
      savefig("figures/Mean_N.pdf")
    

    
    ########## COVARIANCIA MATRIX SE ###########################
    # Cov = Matrix{Float64}(undef,91,12);
    # Cov[:,1] = log.(historical[:][:,1]./(exp(Mu_SE[1]).+Gamma_SE[1]*exp(Mu_SE[1]-Mu_SE[12])*(historical[:][:,12].-exp(Mu_SE[12]))));
    # mean = sum(Cov[:,1])/91;

    # Cov_SE = 0;
    # for i in 1:91
    #     Cov_SE = Cov_SE+(Cov[:,1][i]-mean)*(Cov[:,1][i]-mean)
    # end


    ############################################################


#  hist_SE = historical[:][1,:][1:12]
#  for t in 2:91
#     hist_SE = [hist_SE; historical[:][t,:][1:12]]
#  end
#  se_pac = Vector{Float64}(undef, 91)
#  for t in 1:1092
#      push!(se_pac, log(hist_SE[t])) #push!(se_pac, log(historical[:][:,3][t]))
#  end
#  plot(pacf(se_pac, 1:75), line = :stem, linewidth = 3, title = "SE", label = false)
#  xlims!(0,75)
#  xlabel!("Lag")
#  ylabel!("Partial Autocorrelation") 








#  se_pac = Vector{Float64}(undef, 91)
#  for t in 1:1092
#      push!(se_pac, log(hist_SE[t])) #push!(se_pac, log(historical[:][:,3][t]))
#  end
# plot(pacf(se_pac, 1:75), line = :stem, linewidth = 3, title = "SE", label = false, method = :yulewalker)
# xlims!(0,75)
# xlabel!("Lag")
# ylabel!("Partial Autocorrelation") 

 ###### GRAFICOS DOS PARAMETROS MU #####################
    #  plot(Mu_SE, seriestype=:scatter, label = " \$\\mu_t\$", title = "SE")
    #  xlabel!("Month")
    #  ylabel!("\$\\mu_t\$")
    #  xlims!(0,13)
    #  savefig("figures/mu_SE.pdf") 

    #  plot(Mu_S, seriestype=:scatter, label = " \$\\mu_t\$", title = "S")
    #  xlabel!("Month")
    #  ylabel!("\$\\mu_t\$")
    #  xlims!(0,13)
    #  savefig("figures/mu_S.pdf") 

    #  plot(Mu_NE, seriestype=:scatter, label = " \$\\mu_t\$", title = "NE")
    #  xlabel!("Month")
    #  ylabel!("\$\\mu_t\$")
    #  xlims!(0,13)
    #  savefig("figures/mu_NE.pdf") 

    #  plot(Mu_N, seriestype=:scatter, label = " \$\\mu_t\$", title = "N")
    #  xlabel!("Month")
    #  ylabel!("\$\\mu_t\$")
    #  xlims!(0,13)
    #  savefig("figures/mu_N.pdf") 
    #######################################################



    ###### GRAFICOS DOS PARAMETROS GAMMA #####################
    #   plot(Gamma_SE, seriestype=:scatter, label = " \$\\gamma_t\$ ", title = "SE")
    #   xlabel!("Month")
    #   ylabel!("\$\\gamma_t\$")
    #   xlims!(0,13)
    #   savefig("figures/gamma_SE.pdf") 

    #   plot(Gamma_S, seriestype=:scatter, label = " \$\\gamma_t\$ ", title = "S")
    #   xlabel!("Month")
    #   ylabel!("\$\\gamma_t\$")
    #   xlims!(0,13)
    #   savefig("figures/gamma_S.pdf") 

    #   plot(Gamma_NE, seriestype=:scatter, label = " \$\\gamma_t\$ ", title = "NE")
    #   xlabel!("Month")
    #   ylabel!("\$\\gamma_t\$")
    #   xlims!(0,13)
    #   savefig("figures/gamma_NE.pdf") 

    #   plot(Gamma_N, seriestype=:scatter, label = " \$\\gamma_t\$ ", title = "N")
    #   xlabel!("Month")
    #   ylabel!("\$\\gamma_t\$")
    #   xlims!(0,13)
    #   savefig("figures/gamma_N.pdf") 
    ###########################################################

    # se = Vector{Float64}(undef,long)
    # se[1] = Gamma_SE[1]*(log(historical[:][:,12][91])-Mu_SE[12])+0.15*randn(1)[1]+Mu_SE[1]; #
    #  for t in 2:long
    #      month = t % 12 == 0 ? 12 : t % 12
    #      if month == 1
    #          month_12=12
    #      else
    #          month_12=month-1
    #      end
    #      se[t] = Gamma_SE[month]*(se[t-1]-Mu_SE[month_12])+0.15*randn(1)[1]+Mu_SE[month];
    #  end

    # SE = Matrix{Float64}(undef,amostras,12)
    # for i in 1:amostras
    #     SE[i,:] = exp.(se[12*(i-1)+1:12*i])
    # end

    # s = Vector{Float64}(undef,long)
    # s[1] = Gamma_S[1]*(log.(historical[:][:,25][91])-Mu_S[12])+0.4*randn(1)[1]+Mu_S[1];
    #  for t in 2:long
    #      month = t % 12 == 0 ? 12 : t % 12
    #      if month == 1
    #          month_12=12
    #      else
    #          month_12=month-1
    #      end
    #      s[t] = Gamma_S[month]*(s[t-1]-Mu_S[month_12])+Mu_S[month]+0.4*randn(1)[1];
    #  end

    # S = Matrix{Float64}(undef,amostras,12)
    # for i in 1:amostras
    #     S[i,:] = exp.(s[12*(i-1)+1:12*i])
    # end

    # ne = Vector{Float64}(undef,long)
    # ne[1] = Gamma_NE[1]*(log.(historical[:][:,38][91])-Mu_NE[12])+0.2*randn(1)[1]+Mu_NE[1];
    # for t in 2:long
    #     month = t % 12 == 0 ? 12 : t % 12
    #     if month == 1
    #         month_12=12
    #     else
    #         month_12=month-1
    #     end
    #     ne[t] = Gamma_NE[month]*(ne[t-1]-Mu_NE[month_12])+0.2*randn(1)[1]+Mu_NE[month];
    # end

    # NE = Matrix{Float64}(undef,amostras,12)
    # for i in 1:amostras
    #     NE[i,:] = exp.(ne[12*(i-1)+1:12*i])
    # end

    # n = Vector{Float64}(undef,long)
    # n[1] = Gamma_N[1]*(log.(historical[:][:,51][91])-Mu_N[12])+0.15*randn(1)[1]+Mu_N[1];
    # for t in 2:long
    #     month = t % 12 == 0 ? 12 : t % 12
    #     if month == 1
    #         month_12=12
    #     else
    #         month_12=month-1
    #     end
    #     n[t] = Gamma_N[month]*(n[t-1]-Mu_N[month_12])+0.15*randn(1)[1]+Mu_N[month];
    # end

    # N = Matrix{Float64}(undef,amostras,12)
    # for i in 1:amostras
    #     N[i,:] = exp.(n[12*(i-1)+1:12*i])
    # end

#histogram(log.(SE[:,6]))
#savefig("figures/histo_SE.pdf")
#println((covariance(hist_SE,hist_S))/(sqrt(variance(hist_SE)*variance(hist_S))))
#println((covariance(hist_S,hist_SE))/(sqrt(variance(hist_S)*variance(hist_SE))))

#[1 (covariance(hist_SE,hist_S))/(sqrt(variance(hist_SE)*variance(hist_S))) (covariance(hist_SE,hist_NE))/(sqrt(variance(hist_SE)*variance(hist_NE))) (covariance(hist_SE,hist_N))/(sqrt(variance(hist_SE)*variance(hist_N)))]


#println(Cor==Cor')

#println(PP[4])

return SE, S, NE, N
end

#main_parametros()    