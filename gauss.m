%%fonction à base radiale: Gaussienne

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010

function G=gauss(xx,para)

te=xx'*xx/para^2;
G=exp(-te);
end