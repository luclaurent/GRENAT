%% function for calculating RAAE (Relative Average Absolute Error)
%%L. LAURENT   --  22/03/2010   --  luc.laurent@lecnam.net

% Jin 2000 "Comparative Studies Of Metamodeling Techniques under Multiple Modeling Criteria"

%%Zex: "exact" values of the function obtained by simulation
%%Zap: approximated values given by the surrogate model

function raae=calcRAAE(Zex,Zap)

STD=std(Zap(:));
vec=abs(Zex-Zap);
ECA=sum(vec(:));

raae=ECA/(size(Zex,1)*size(Zex,2)*STD);

end