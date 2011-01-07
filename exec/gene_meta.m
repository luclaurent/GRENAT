%% Generation et évaluation du metamodèle
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr


function [Z,ret]=gene_meta(tirages,eval,grad,points,meta)

% Generation du metamodele
textd='===== METAMODELE de ';
textf=' =====';

dim_conc=size(tirages,2);
dim_ev=size(points);

var=zeros(dim_ev([1,2]));
Z.Z=zeros(dim_ev([1,2]));
    
%construction métamodèle
switch meta.type
    case 'CKRG'
        %% Construction du metamodèle de CoKrigeage
        fprintf('\n%s\n',[textd 'CoKrigeage' textf]);
        ckrg=meta_ckrg(tirages,eval,grad,meta);
        ret=ckrg;
    case 'KRG'
        %% Construction du metamodèle de Krigeage
        fprintf('\n%s\n',[textd 'Krigeage' textf]);
        krg=meta_krg(tirages,eval,meta);
        ret=krg;
    case 'DACE'
        %% Construction du metamodèle de Krigeage (DACE)
        fprintf('\n%s\n',[textd 'Krigeage (Toolbox DACE)' textf]);
        [dace.model,dace.perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.theta);
        ret=dace;
end

% en dimension 1, les points ou l'on souhaite evaluer le metamodele se
% presentent sous forme d'une matrice
if dim_conc==1
    Z.GZ=zeros(dim_ev);
    switch meta.type
        case 'CKRG'
            %% Evaluation du metamodèle de CoKrigeage
            for jj=1:length(points)
                [Z.Z(jj),G,var(jj)]=eval_ckrg(points(jj),tirages,ckrg);
                Z.GZ(jj)=G;
            end
        case 'KRG'
            %% Evaluation du metamodèle de Krigeage
            for jj=1:length(points)
                [Z.Z(jj),G,var(jj)]=eval_krg(points(jj),tirages,krg);
                Z.GZ(jj)=G;
            end
        case 'DACE'
            %% Evaluation du metamodèle de Krigeage (DACE)
            for jj=1:length(points)
                [Z.Z(jj),G,var(jj)]=predictor(points(jj),dace.model);
                Z.GZ(jj)=G;
            end
    end
    
    % en dimension 2, les points ou l'on souhaite evaluer le metamodele se
    % presentent sous forme d'un vecteur de matrices
elseif dim_conc==2
    Z.GR1=zeros(dim_ev([1,2]));
    Z.GR2=zeros(dim_ev([1,2]));
    switch meta.type
        case 'CKRG'
            %% Evaluation du metamodèle de CoKrigeage
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G,var(jj,kk)]=eval_ckrg(points(jj,kk,:),tirages,ckrg);
                    Z.GR1(jj,kk)=G(1);
                    Z.GR2(jj,kk)=G(2);
                end
            end
        case 'KRG'
            %% Evaluation du metamodèle de Krigeage
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G,var(jj,kk)]=eval_krg(points(jj,kk,:),tirages,krg);
                    Z.GR1(jj,kk)=G(1);
                    Z.GR2(jj,kk)=G(2);
                end
            end
        case 'DACE'
            %% Evaluation du metamodèle de Krigeage (DACE)
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G,var(jj,kk)]=predictor(points(jj,kk,:),dace.model);
                    Z.GR1(jj,kk)=G(1);
                    Z.GR2(jj,kk)=G(2);
                end
            end
    end
else
    error('dimension non encore prise en charge');
end

%Variance de prediction
Z.var=var;
