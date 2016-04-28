%% function for calculating RMSE
%%L. LAURENT   --  10/02/2012   --  luc.laurent@lecnam.net

%%Zex: "exact" values of the function obtained by simulation
%%Zap: approximated values given by the surrogate model

function rmse=calcRMSE(Zex,Zap)

diff=(Zex-Zap).^2;
MSE=sum(diff(:));
rmse=sqrt(1/(size(Zex,1)*size(Zex,2))*MSE);

end