%% procedure de calcul automatique du param�tre RBF
% L. LAURENT -- 23/02/2012 -- laurent@lmt.ens-cachan.fr

function para=calc_para_rbf(tirages,data)

% choix de la strategie
if isfield(data.para,'type')
    type=data.para.type; %Hardy/Franke ou manu
else
    type='Manu';
end
% Aniso ou non
aniso=data.para.aniso;

%Nb de variables et de points
nb_var=size(tirages,2);
nb_val=size(tirages,1);

%suivant la strategie choisie
switch type
    case 'Hardy' %c=0.815d avec d=1/N*sum di ou di la distance entre un point i et son plus proche voisin
        if aniso
            %calcul des distances les plus proches
            dmin=zeros(nb_val,nb_var);
            for ii=1:nb_val
                v=repmat(tirages(ii,:),nb_val-1,1)-tirages([(1:ii-1) (ii+1:end)],:) ;
                d=sqrt(sum(v.^2,2));
                [~,IX]=min(d);
                dmin(ii,:)=abs(v(IX,:));
            end
        else
            %calcul des distances les plus proches
            dmin=zeros(1,nb_val);
            for ii=1:nb_val
                v=repmat(tirages(ii,:),nb_val-1,1)-tirages([(1:ii-1) (ii+1:end)],:) ;
                d=sqrt(sum(v.^2,2));
                dmin(ii)=min(d);
            end
        end
        
        para=0.815*1/nb_val*sum(dmin);
    case 'Franke'
        if aniso
            %calcul des distances les plus proches
            D=zeros(nb_var,1);
            for ii=1:nb_var
                D(ii)=abs(max(tirages(ii,:))-min(tirages(ii,:)));
            end
        else
            %calcul des distances les plus proches
            D=zeros(1,nb_val);
            for ii=1:nb_val
                v=repmat(tirages(:,ii),nb_var,nb_val)-tirages;
                d=sqrt(sum(v.^2,2));
                D(ii)=max(d);
            end
        end
        para=1.25*1/nb_val*D;
        
    otherwise
        para=data.para.l_val;
end
