%% function for calculating MSE
%%L. LAURENT   --  22/03/2010   --  luc.laurent@lecnam.net

%%Zex: "exact" values of the function obtained by simulation
%%Zap: approximated values given by the surrogate model

function emse=calcMSE(Zex,Zap)

diff=(Zex-Zap).^2;
MSE=sum(diff(:));
emse=1/numel(Zex)*MSE;
end