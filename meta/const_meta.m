%% fonction assurant la construction du metamodele (pas son evaluation)
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr

function [ret]=const_meta(tirages,eval,grad,meta)

%prise en compte gradients ou pas
if isempty(grad)||meta.grad==false;pec_grad='Non';grad=[];else;pec_grad='Oui';end
fprintf('Gradients disponibles: %s\n\n',pec_grad);

% Generation du metamodele
textd='===== METAMODELE de ';
textf=' =====';

%nombre de variables
nb_var=size(tirages,2);
%nombre de points
nb_val=size(tirages,1);

%mise en forme type de metamodele
if ~iscell(meta.type)
    metype={meta.type};
else
    metype=meta.type;
end




%%%%%%% Generation de divers metamodeles
%initialisation stockage
ret=cell(length(meta.type),1);
Z=ret;
% generation des metamodeles
num_meta=1;
for type=metype
    %construction metamodele
    switch type{1}
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
        case 'SWF'
            %% construction du metamodele 'Shepard Weighting Functions'
            fprintf('\n%s\n',[textd 'Fonctions Shepard (SWF)' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            swf=meta_swf(tirages,eval,grad,meta);
            out_meta=swf;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'RBF'
            %% construction du metamodele 'RBF/HBRBF' (Radial Basis Functions and Hermite-Birkhoff Radial Basis Functions)
            
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'CKRG'
            %% Construction du metamodele de CoKrigeage
            fprintf('\n%s\n',[textd 'CoKrigeage' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            ckrg=meta_krg_ckrg(tirages,eval,grad,meta);
            out_meta=ckrg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'KRG'
            %% Construction du metamodele de Krigeage
            fprintf('\n%s\n',[textd 'Krigeage' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',nb_var,nb_val)
            krg=meta_krg_ckrg(tirages,eval,[],meta);
            out_meta=krg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'DACE'
            %% Construction du metamodele de Krigeage (DACE)
            fprintf('\n%s\n',[textd 'Krigeage (Toolbox DACE)' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            [dace.model,dace.perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.para);
            out_meta=dace;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'PRG'
            ite_prg=1;
            ret{num_meta}.prg=length(meta.deg);
            for degre=meta.deg
                %% Construction du metamodele de Regression polynomiale
                fprintf('\n%s\n',[textd  'Regression polynomiale' textf]);
                fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)                
                dd=['-- Degre du polynome \n',num2str(degre)];
                fprintf(dd);
                [prg.coef,prg.MSE]=meta_prg(tirages,eval,degre);
                out_meta.prg{ite_prg}=prg;
                ite_prg=ite_prg+1;
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILIN'
            %% Construction du metamodele d'interpolation lineaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction de base ' textf]);
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILAG'
            %% interpolation par fonction de base linéaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
    end
    
    
    %stockage des informations utiles
    out_meta.type=type{1};
    out_meta.nb_var=nb_var;
    out_meta.nb_val=nb_val;
    out_meta.tirages=tirages;
    out_meta.eval=eval;
    out_meta.grad=grad;
    if numel(metype)==1
        ret=out_meta;
    else
        ret{num_meta}=out_meta;
    end
    num_meta=num_meta+1;
end