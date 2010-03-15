%%fonction à base radiale: Cauchy

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010

function G=cauchy(xx,para)

te=xx'*xx/para^2;
G=1/(1+te);
end