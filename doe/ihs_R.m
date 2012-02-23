%% Generation de plan d'experience LHS a partir de R (avec pr�tirage de LHS enrichi)
% IHS: Improved Hypercube Sampling
% Ref: Beachkofski, B., Grandhi, R. (2002) Improved Distributed Hypercube Sampling American Institute of Aeronautics and Astronautics Paper 1274.
% L. LAURENT -- 14/01/2012 -- laurent@lmt.ens-cachan.fr


function [tir,new_tir]=ihs_R(Xmin,Xmax,nb_samples,old_tir,nb_enrich)

%% INPUT: 
%    - Xmin,Xmax: bornes min et max de l'espace de concpetion
%    - nb_samples: nombre d'�chantillons requis
%    - nb_enrich: nombre d'�chantillons requis pour enrichir
%% OUTPUT
%   - tir: echantillons
%   - new_tir: nouveaux echantillons en phase d'enrichissement
%%

%%declaration des options
% repertoire de stockage
rep='LHS_R';
%nombre de plans pr�tir�s
nb_pretir=300;
%nom du fichier script r
nom_script='ihsu_R.r';
%nom du fichier de donn�es R
nom_dataR='dataR.dat';

%phase de creation des plans
if nargin==3

% recuperation dimensions (nombre de variables et nombre d'�chantillon)
nbs=nb_samples;
nbv=numel(Xmin);

%%ecriture d'un script R
%Creation du repertoire de stockage (s'il n'existe pas)
if exist(rep,'dir')~=7
    cmd=['mkdir ' rep];
    unix(cmd);
end

%ecriture du script r
%proc�dure de cr�ation du tirage initial
text_init=['a<-improvedLHS(' num2str(nbs) ',' num2str(nbv) ',5)\n'];
%proc�dure d'enrichissement
text_enrich=['a<-augmentLHS(a,1)\n'];
%chargement librairie LHS
load_LHS='library(lhs)\n';
%proc�dure stockage tirage
stock_tir='write.table(a,file="dataR.dat",row.names=FALSE,col.names=FALSE)';

%cr�ation et ouverture du fichier de script
fid=fopen([rep '/' nom_script],'w','n','UTF-8');
%ecriture chargement librairie
fprintf(fid,load_LHS);
%ecriture tirage initial
fprintf(fid,text_init);
%�criture de l'enrichissement
for ii=1:nb_pretir
    fprintf(fid,text_enrich);
end
%�criture de la proc�dure de sauvegarde
fprintf(fid,stock_tir);
%fermeture du fichier
fclose(fid);
%%execution du script R (n�cessite d'avoir r install�)
%test de l'existence de 
[e,t]=unix('which R');
if e~=0
    error('R non install� (absent du PATH)');
else
    [e,t]=unix(['cd ' rep ' && R -f ' nom_script]);
    pause(1)
end
%lecture du fichier de donn�es R
A=load([rep '/' nom_dataR]);

%tirage obtenu
tir=A(1:nbs,:).*repmat(Xmax(:)'-Xmin(:)',nbs,1)+repmat(Xmin(:)',nbs,1);
new_tir=[];

%phase d'enrichissement
elseif nargin==5
    
%nombre d'�chantillons dans le tirage pr�c�dent
old_nbs=size(old_tir,1);

%chargement du fichier de donnees R
A=load([rep '/' nom_dataR]);

%nouveaux tirages
ind=old_nbs+1:old_nbs+nb_enrich;
new_tir=A(ind,:).*repmat(Xmax(:)'-Xmin(:)',nb_enrich,1)+repmat(Xmin(:)',nb_enrich,1);
%liste de tous les tirages
tir=[old_tir;new_tir];

    
end
