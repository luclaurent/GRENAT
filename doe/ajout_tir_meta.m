%% Fonction assurant la création d'un nouveau point d'echantillonnage basé sur un metamodele 
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr


function pts=ajout_tir_meta(tirages,eval,grad,meta,approx,enrich)

global doe
    
%en fonction du type de nouveau point reclamé
switch enrich.type
    %Expected Improvement (Krigeage)
    case 'EI_KRG'
        
    %Variance (Krigeage)
    case 'VAR_KRG'
        if strcmp(approx.type,'KRG')||strcmp(approx.type,'CKRG')
            new_approx=approx;
        else
            metab=meta;
            metab.type='KRG';
            [new_approx]=const_meta(tirages,eval,grad,metab);
        end        
        
       % on cherche le maximum de la variance de prédiction du
       % Krigeage/Cokrigeage
end
    
end