%%fonction à base radiale: multiquadaratique

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010

function G=multiqua(xx,para)

te=xx'*xx/para^2;
G=sqrt(1+te);
end