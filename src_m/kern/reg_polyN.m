%fonction assurant l'evaluation d'une fonction polynomiale de degre N
%L.LAURENT -- 24/02/2012 -- luc.laurent@lecnam.net

function [ret,dret,ddret]=reg_polyN(val,deg)

%nombre de points
nbs=size(val,1);
%nombre de variables
nbv=size(val,2);

%nom fonction stockage
nom_fct='mono_';

%dérivée première, seconde demandée ou non
der=nargout-1;

%recuperation des coef et puissances des monomes
fonction=[nom_fct num2str(deg,'%02i') '_' num2str(nbv,'%03i')];
if der==0
[matX,nbMono]=...
    feval(fonction);
elseif der==1
    [matX,nbMono,...
    pow_monoD1,cMonoD1]=...
    feval(fonction);
elseif der==2
    [matX,nbMono,...
    pow_monoD1,cMonoD1,...
    pow_monoD2,cMonoD2]=...
    feval(fonction);
end

%matrice de regression
ret=matX;

%calcul des dérivées
if der>=1
    
end

if der==2
    
end





% 
% 
% 
% 
% 
% 
% 
% d=size(val);
% p=(d(2)+1)*(d(2)+2)*1/2;
% 
% t=val;
% tt=zeros(d(1),p-d(2)-1);
% 
% j=0;m=d(2);
% for  ii=1:d(2)
%     tt(:,j+(1:m))=repmat(val(:,ii),1,m).*val(:,ii:end);
%     j=j+m;
%     m=m-1;
% end
% 
% %evaluation de la fonction polynomiale
% ret=[ones(d(1),1) t tt];
% 
% 
% %evaluation de la derivee
% if nargout==2
%     if d(1)==1
%         dd=zeros(d(2),p-d(2)-1);
%         j=0;m=d(2);
%         for ii=1:d(2)
%             dd(ii,j+(1:m))=[2*val(ii) val(ii+1:end)];
%             for jj=1:d(2)-ii
%                 dd(ii+jj,j+jj+1)=val(ii);
%             end
%             j=j+m;
%             m=m-1;
%         end
%         dret=[zeros(d(2),1) eye(d(2)) dd];
%     else
%         dret=cell(d(1),1);
%         for ll=1:d(1)
%             dd=zeros(d(2),p-d(2)-1);
%             j=0;m=d(2);
%             for ii=1:d(2)
%                 dd(ii,j+(1:m))=[2*val(ll,ii) val(ll,ii+1:end)];
%                 for jj=1:d(2)-ii
%                     dd(ii+jj,j+jj+1)=val(ll,ii);
%                 end
%                 j=j+m;
%                 m=m-1;
%             end
%             
%             dret{ll}=[zeros(d(2),1) eye(d(2)) dd];
%         end
%         dret=vertcat(dret{:});
%     end
% end
% end
