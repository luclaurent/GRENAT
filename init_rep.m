%initialisation des differents repertoires
% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr


function init_rep(doss)

if nargin==0
    doss='.';
end
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
addpath([doss '/lightspeed']); %%debug possible
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
addpath([doss '/libs/sqplab-0.4.5-distrib/src']);
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%