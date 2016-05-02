%% Function for computing 3 custom quality errors
%L. LAURENT   --  22/10/2010   --  luc.laurent@lecnam.net

%%Zex: "exact" values of the function obtained by simulation
%%Zap: approximated values given by the surrogate model

function [q1,q2,q3]=qualError(Zex,Zap)

%%Compute differences
ecart=(Zex-Zap).^2/max(max(Zex.^2));
%Compute criteria 1 (max of the differences)
q1=max(ecart(:));

%Compute criteria 2 (sum of the differences)
q2=sum(ecart(:));

%Compute criteria 3 (mean of the differences)
q3=q2/numel(Zex);

end