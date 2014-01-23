%initialisation des differents repertoires
% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr


function init_rep(doss)

if nargin==0
    doss=pwd;
end
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
addpath([doss '/doe/LHS']);
addpath([doss '/doe/IHS']);
addpath([doss '/meta/dace']);
addpath([doss '/doe']);
addpath([doss '/fct']);
addpath([doss '/fct/fct_test']);
addpath([doss '/fct/base_monomes']);
addpath([doss '/meta']);
addpath([doss '/crit']);
addpath([doss '/matlab2tikz/']);
addpath([doss '/exec']);
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
%librairies externes
addpath([doss '/libs/lightspeed']); %%debug possible
addpath([doss '/libs/sqplab-0.4.5-distrib/src']);
addpath([doss '/libs/PSOt'],[doss '/libs/PSOt/nnet'],...
    [doss '/libs/PSOt/hiddenutils'],[doss '/libs/PSOt/testfunctions']);