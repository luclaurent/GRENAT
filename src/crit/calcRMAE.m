%% function for calculating RMAE (Relative Maximum Absolute Error)
%%L. LAURENT   --  22/03/2010   --  luc.laurent@lecnam.net

% Jin 2000 "Comparative Studies Of Metamodeling Techniques under Multiple Modeling Criteria"

%%Zex: "exact" values of the function obtained by simulation
%%Zap: approximated values given by the surrogate model

function rmae=calcRMAE(Zex,Zap)

STD=std(Zap(:));
vec=abs(Zex-Zap);

rmae=max(vec(:))/STD;

end