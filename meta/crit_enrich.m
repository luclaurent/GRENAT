%% Calcul critere EI/WEI/LCB
%% L. LAURENt -- 04/05/2012 -- laurent@lmt.ens-cachan.fr

function [EI,WEI,LCB,exploit,explor]=crit_enrich(eval_min,Z,variance,enrich)

%reponse mini
diff_ei=(eval_min-Z);
if variance~=0
    u=diff_ei/variance;
end
%pour calcul Expected Improvement (Schonlau 1997/Jones 1999/Bompard
%2011/Sobester 2005...)
%exploration (densite probabilite)
if variance~=0
    explor=variance*1/sqrt(2*pi)*exp(-0.5*u^2);
else
    explor=0;
end

%exploitation (fonction repartition loi normale centree reduite)
if variance~=0
    exploit=diff_ei*0.5*(1+erf(u/sqrt(2)));
else
    exploit=0;
end
%critere Weigthed Expected Improvement (Sobester 2005)
WEI=enrich.para_wei*exploit+(1-enrich.para_wei)*explor;
%critere Expected Improvement (Schonlau 1997)
EI=exploit+explor;
%critere Lower Confidence Bound (Cox et John 1997)
LCB=Z-enrich.para_lcb*variance;