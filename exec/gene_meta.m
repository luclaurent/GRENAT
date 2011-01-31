%% Generation et evaluation du metamodele
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr


function [Z,ret]=gene_meta(tirages,eval,grad,points,meta)

% Generation du metamodele
textd='===== METAMODELE de ';
textf=' =====';

dim_conc=size(tirages,2);
dim_pts=size(tirages,1);
dim_ev=size(points);

var=zeros(dim_ev([1,2]));
Z.Z=zeros(dim_ev([1,2]));


%construction metamodele
switch meta.type
    case 'CKRG'
        %% Construction du metamodele de CoKrigeage
        fprintf('\n%s\n',[textd 'CoKrigeage' textf]);
        %affichage informations
        fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',dim_conc,dim_pts)
        ckrg=meta_ckrg(tirages,eval,grad,meta);
        ret=ckrg;
    case 'KRG'
        %% Construction du metamodele de Krigeage
        fprintf('\n%s\n',[textd 'Krigeage' textf]);
        %affichage informations
        fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',dim_conc,dim_pts)
        krg=meta_krg(tirages,eval,meta);
        ret=krg;
    case 'DACE'
        %% Construction du metamodele de Krigeage (DACE)
        fprintf('\n%s\n',[textd 'Krigeage (Toolbox DACE)' textf]);
        %affichage informations
        fprintf('Nombre de variables: %d \n Nombre de points: %d\n\n',dim_conc,dim_pts)
        [dace.model,dace.perf]=dacefit(tirages,eval,meta.regr,meta.corr,meta.para);
        ret=dace;
end

% en dimension 1, les points ou l'on souhaite evaluer le metamodele se
% presentent sous forme d'une matrice
if dim_conc==1
    Z.GZ=zeros(dim_ev);
    switch meta.type
        case 'CKRG'
            %% Evaluation du metamodele de CoKrigeage
            for jj=1:length(points)
                [Z.Z(jj),G,var(jj)]=eval_ckrg(points(jj),tirages,ckrg);
                Z.GZ(jj)=G;
            end
        case 'KRG'
            %% Evaluation du metamodele de Krigeage
            for jj=1:length(points)
                [Z.Z(jj),G,var(jj)]=eval_krg(points(jj),tirages,krg);
                Z.GZ(jj)=G;
            end
        case 'DACE'
            %% Evaluation du metamodele de Krigeage (DACE)
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
            %% Evaluation du metamodele de CoKrigeage
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G,var(jj,kk)]=eval_ckrg(points(jj,kk,:),tirages,ckrg);
                    Z.GR1(jj,kk)=G(1);
                    Z.GR2(jj,kk)=G(2);
                end
            end
        case 'KRG'
            %% Evaluation du metamodele de Krigeage
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z.Z(jj,kk),G,var(jj,kk)]=eval_krg(points(jj,kk,:),tirages,krg);
                    Z.GR1(jj,kk)=G(1);
                    Z.GR2(jj,kk)=G(2);
                end
            end
        case 'DACE'
            %% Evaluation du metamodele de Krigeage (DACE)
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
