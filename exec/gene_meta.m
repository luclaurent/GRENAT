%% Generation et évaluation du metamodèle
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr


function [Z,GZ,msep,ret]=gene_meta(tirages,eval,grad,points,meta)

% Generation du metamodele
textd='===== METAMODELE de ';
textf=' =====';

dim_conc=size(tirages,2);
dim_ev=size(points);

Z=zeros(dim_ev(1),dim_ev(2));
msep=zeros(dim_ev(1),dim_ev(2));
GZ=zeros(dim_ev(2),dim_conc);

    
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
    
    switch meta.type
        case 'CKRG'
            %% Evaluation du metamodèle de CoKrigeage
            for jj=1:length(points)
                [Z(jj),G,msep(jj)]=eval_ckrg(points(jj),tirages,ckrg);
                GZ(jj)=G;
            end
        case 'KRG'
            %% Evaluation du metamodèle de Krigeage
            for jj=1:length(points)
                [Z(jj),G,msep(jj)]=eval_krg(points(jj),tirages,krg);
                GZ(jj)=G;
            end
        case 'DACE'
            %% Evaluation du metamodèle de Krigeage (DACE)
            for jj=1:length(points)
                [Z(jj),G,msep(jj)]=predictor(points(jj),dace.model);
                GZ(jj)=G;
            end
    end
    
    % en dimension 2, les points ou l'on souhaite evaluer le metamodele se
    % presentent sous forme d'un vecteur de matrices
elseif dim_conc==2
    switch meta.type
        case 'CKRG'
            %% Evaluation du metamodèle de CoKrigeage
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z(jj,kk),G,msep(jj,kk)]=eval_ckrg(points(jj,kk,:),tirages,ckrg);
                    GZ(jj,kk,1)=G(1);
                    GZ(jj,kk,2)=G(2);
                end
            end
        case 'KRG'
            %% Evaluation du metamodèle de Krigeage
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z(jj,kk),G,msep(jj,kk)]=eval_krg(points(jj,kk,:),tirages,krg);
                    GZ(jj,kk,1)=G(1);
                    GZ(jj,kk,2)=G(2);
                end
            end
        case 'DACE'
            %% Evaluation du metamodèle de Krigeage (DACE)
            for jj=1:size(points,1)
                for kk=1:size(points,2)
                    [Z(jj,kk),G,msep(jj,kk)]=predictor(points(jj,kk,:),dace.model);
                    GZ(jj,kk,1)=G(1);
                    GZ(jj,kk,2)=G(2);
                end
            end
    end
else
    error('dimension non encore prise en charge');
end

             
