%% fonction assurant la construction du metamodele (pas son evaluation)
%% L. LAURENT -- 04/12/2011 -- laurent@lmt.ens-cachan.fr

function [ret]=const_meta(tirages,eval,grad_in,meta,num_fct)

fprintf('#########################################\n');
fprintf('  >>> CONSTRUCTION METAMODELE <<<\n');
[tMesu,tInit]=mesu_time;
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%prise en compte gradients ou pas
if isfield(meta,'grad')
    if isempty(grad_in)||meta.grad==false;pec_grad='Non';grad_in=[];else pec_grad='Oui';end
else
    if isempty(grad_in);pec_grad='Non';grad_in=[];else pec_grad='Oui';end
end
fprintf('\n++ Gradients disponibles: %s\n',pec_grad);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
% Generation du metamodele
textd='++ Type: ';
textf='';
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%nombre de variables
nb_var=size(tirages,2);
%nombre de points
nb_val=size(tirages,1);
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%mise en forme type de metamodele
if ~iscell(meta.type)
    metype={meta.type};
else
    metype=meta.type;
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%conditionnement pour InKRG (prise en compte donnees sous forme struct)
if nargin==5&&isstruct(grad_in)
    grad.eval=grad_in.eval{num_fct};
    grad.tirages=grad_in.tirages{num_fct};
else
    grad=grad_in;
end
%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%Examen des donnees entrantes (traitement des données manquantes
[bilan_manq]=examen_in_data(tirages,eval,grad_in);

%%%%%%%%=================================%%%%%%%%
%%%%%%%%=================================%%%%%%%%
%%%%%%% Generation de divers metamodeles
%initialisation stockage
ret=cell(length(meta.type),1);
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
            swf=meta_swf(tirages,eval,grad_in,meta);
            out_meta=swf;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'RBF'
            %% construction du metamodele 'RBF' (Radial Basis Functions)
            fprintf('\n%s\n',[textd 'Radial Basis Functions (RBF)' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            rbf=meta_rbf(tirages,eval,[],meta,bilan_manq);
            out_meta=rbf;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'GRBF'
            %% construction du metamodele 'GRBF' (Hermite-Birkhoff Radial Basis Functions)
            fprintf('\n%s\n',[textd 'Gradient-based Radial Basis Functions (GRBF)' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            rbf=meta_rbf(tirages,eval,grad_in,meta,bilan_manq);
            out_meta=rbf;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'InKRG'
            %% Construction du metamodele de Krigeage Indirect
            fprintf('\n%s\n',[textd 'Krigeage indirect' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',nb_var,nb_val)
            inkrg=meta_inkrg(tirages,eval,grad,meta,bilan_manq); %% cas particulier prise en compte des réponses pour gradients au lieu des gradients evalues)
            out_meta=inkrg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'InRBF'
            %% Construction du metamodele de Krigeage Indirect
            fprintf('\n%s\n',[textd 'Krigeage indirect' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',nb_var,nb_val)
            inrbf=meta_inrbf(tirages,eval,grad,meta); %% cas particulier prise en compte des réponses pour gradients au lieu des gradients evalues)
            out_meta=inrbf;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'CKRG'
            %% Construction du metamodele de CoKrigeage
            fprintf('\n%s\n',[textd 'CoKrigeage' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            ckrg=meta_krg_ckrg(tirages,eval,grad_in,meta,bilan_manq);
            out_meta=ckrg;
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
        case 'KRG'
            %% Construction du metamodele de Krigeage
            fprintf('\n%s\n',[textd 'Krigeage' textf]);
            %affichage informations
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',nb_var,nb_val)
            krg=meta_krg_ckrg(tirages,eval,[],meta,bilan_manq);
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
            %% interpolation par fonction de base lineaire
            fprintf('\n%s\n',[textd  'Interpolation par fonction polynomiale de Lagrange' textf]);
            fprintf('Nombre de variables: %d \n Nombre de points: %d\n',nb_var,nb_val)
            %%%%%%%%=================================%%%%%%%%
            %%%%%%%%=================================%%%%%%%%
    end
    
    
    %stockage des informations utiles
    out_meta.bilan_manq=bilan_manq;
    out_meta.type=type{1};
    out_meta.nb_var=nb_var;
    out_meta.nb_val=nb_val;
    out_meta.tirages=tirages;
    out_meta.eval=eval;
    out_meta.grad=grad_in;
    out_meta.enrich=meta.enrich;
    if numel(metype)==1
        ret=out_meta;
    else
        ret{num_meta}=out_meta;
    end
    num_meta=num_meta+1;
end

mesu_time(tMesu,tInit);
fprintf('#########################################\n');