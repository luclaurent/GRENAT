%% Normalization and renormlization of the Data
%% L. LAURENT -- 18/10/2011 -- luc.laurent@lecnam.net

function [out,infoData]=NormRenorm(in,type,infoData)

% number of sample points
nbs=size(in,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%traitement de tous le cas de figure
norm_data=false;norm_manq=false;
if nargin==3
    if isfield(infoData,'moy')
        if ~isempty(infoData.moy)
            norm_data=true;
        else
            calc_para_norm=false;
        end
    elseif isfield(infoData,'eval')
        norm_manq=infoData.eval.on;
        calc_para_norm=true;
    elseif isfield(infoData,'moy')&&isfield(infoData,'eval')
        if ~isempty(infoData.moy)
            norm_data=true;
        else
             calc_para_norm=false;
        end
    end
else
     calc_para_norm=true;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargout==2
    extr_infos=true;
else
    extr_infos=false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation//denormalisation
switch type
    case 'norm'
        %dans le cas de données manquantes, on retire les données à NaN
        if norm_manq
            inm=in(infoData.eval.ix_dispo);
        else
            inm=in;
        end
       
        if norm_data
            moyy=infoData.moy;
            stdd=infoData.std;
            out=(in-moyy(ones(nbs,1),:))./stdd(ones(nbs,1),:);
            calc_para_norm=false;
        end
        
        if calc_para_norm
            %calcul des moyennes et des ecarts type
            moy_i=mean(inm);
            std_i=std(inm);
            %test pour verification ecart type
            ind=find(std_i==0);
            if ~isempty(ind)
                std_i(ind)=1;
            end
            if norm_manq
                outm=(inm-moy_i(ones(infoData.eval.nb,1),:))./...
                    std_i(ones(infoData.eval.nb,1),:);
                out=NaN*zeros(size(in));
                out(infoData.eval.ix_dispo)=outm;
            else
                out=(inm-moy_i(ones(nbs,1),:))./std_i(ones(nbs,1),:);
            end
            
            if extr_infos
                infoData.moy=moy_i;
                infoData.std=std_i;
            end
        end
        if ~calc_para_norm&&~norm_data
            out=in;            
        end
        
        %denormalisation
    case 'denorm'
        if norm_data
            moyy=infoData.moy;
            stdd=infoData.std;
            out=stdd(ones(nbs,1),:).*in+moyy(ones(nbs,1),:);
        else
            out=in;
        end
        
        %denormalisation d'une difference de valeurs normalisees
    case 'denorm_diff'
        if norm_data
            stdd=infoData.std;
            out=stdd(ones(nbs,1),:).*in;
        else
            out=in;
        end
    otherwise
        error('Mauvais nombre de parametres d''entrée (cf. norm_denorm.m)')
end
