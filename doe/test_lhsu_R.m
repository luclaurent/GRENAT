%% Fichier etude enrichissement LHS
% L. LAURENT -- 14/01/2012 -- laurent@lmt.ens-cachan.fr
close all
%dimension
dim=2;
%bornes
b_sup=10;
b_inf=-10;
%nb echantillons
nbs_min=50;
nbs_max=150;


Xmin=repmat(b_inf,1,dim);
Xmax=repmat(b_sup,1,dim);
%initilisation plan
[t,nt]=ihs_R(Xmin,Xmax,nbs_min);
%generation enrichissement
[tt,ntt]=ihs_R(Xmin,Xmax,nbs_min,t,nbs_max);

if dim==1
figure;
hold on
for ii=1:nbs_min
plot(t(ii),2,'r*','MarkerSize',10,'MarkerEdgeColor','r','MarkerFaceColor','r')
end
iter=1;
for ii=(nbs_min+1):nbs_max
   plot(tt(ii),2,'bo','MarkerSize',10);
   F(iter)=getframe;
   iter=iter+1;
end
hold off
elseif dim==2
    figure;
hold on
for ii=1:nbs_min
plot(t(ii,1),t(ii,2),'ro','MarkerSize',10,'MarkerEdgeColor','r','MarkerFaceColor','r')
end
iter=1;
for ii=(nbs_min+1):nbs_max
   plot(tt(ii,1),tt(ii,2),'bo','MarkerSize',10);
   F(iter)=getframe;
   iter=iter+1;
end
elseif dim==3
    
end
movie(F)