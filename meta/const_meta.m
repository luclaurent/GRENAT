%% fonction assurant la construction du metamodele (pas son evaluation)
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr

function [Z,ret]=const_meta(tirages,eval,grad,points,meta)

% Generation du metamodele
textd='===== METAMODELE de ';
textf=' =====';

%nombre de variables
nb_var=size(tirages,2);
%nombre de points
nb_val=size(tirages,1);
dim_ev=size(points);

%prise en compte gradients ou pas
if isempty(grad)||meta.grad==false;pec_grad='Non';grad=[];else;pec_grad='Oui';end

var=zeros(dim_ev([1 2]));
rep=zeros(dim_ev([1 2]));
GR=zeros(dim_ev(1),dim_ev(2),nb_var);

%%%%%%% Generation de divers metamodeles
%initialisation stockage
ret=cell(length(meta.type),1);
Z=ret;
% generation des metamodeles
num_meta=1;
for type=meta.type
    ret{num_meta}.type=type{1};

    %construction metamodele
    switch type{1}
        %%%%%%%%=================================%%%%%%%%
        %%%%%%%%=================================%%%%%%%%
        case 'SWF'
            %% construction du metamodele 'Shepard Weighting Functions'
            fprintf('\n%s\n',[textd 'Fonctions Shepard (SWF)' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            fprintf('Gradients: %s\n\n',pec_grad);
            swf=meta_swf(tirages,eval,grad,meta);
            ret{num_meta}=swf;
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
            fprintf('Gradients: %s\n\n',pec_grad);
            ckrg=meta_ckrg(tirages,eval,grad,meta);
            ret{num_meta}=ckrg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'KRG'
            %% Construction du metamodele de Krigeage
            fprintf('\n%s\n',[textd 'Krigeage' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',nb_var,nb_val)
            krg=meta_krg(tirages,eval,meta);
            ret{num_meta}=krg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'DACE'
            %% Construction du metamodele de Krigeage (DACE)
            fprintf('\n%s\n',[textd 'Krigeage (Toolbox DACE)' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            fprintf('Gradients: %s\n\n',pec_grad);
            [dace.model,dace.perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.para);
            ret{num_meta}=dace;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'PRG'
            ite_prg=1;
            ret{num_meta}.prg=length(meta.deg);
            for degre=meta.deg
                %% Construction du metamodele de Regression polynomiale
                fprintf('\n%s\n',[textd  'Regression polynomiale' textf]);
                fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
                fprintf('Gradients: %s\n\n',pec_grad);
                dd=['-- Degre du polynome \n',num2str(degre)];
                fprintf(dd);
                [prg.coef,prg.MSE]=meta_prg(tirages,eval,degre);
                ret{num_meta}.prg{ite_prg}=prg;
                ite_prg=ite_prg+1;
            end
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILIN'
            %% Construction du metamodele d'interpolation lineaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction de base ' textf]);
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            fprintf('Gradients: %s\n\n',pec_grad);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'ILAG'
            %% interpolation par fonction de base linéaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            fprintf('Gradients: %s\n\n',pec_grad);
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
    end
    num_meta=num_meta+1;
end