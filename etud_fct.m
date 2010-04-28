%%procédure d'étude des fonctions à support compact et de leur dérivée
%%L. LAURENT -- 12/04/2010 -- luc.laurent@ens-cachan.fr
clear all;close all;
addpath('fct/');

%%étude 2D
%paramètres
para=0.2;
pas=0.05;
borne_sup=1;
borne_inf=-1;
%fonction
fct='cauchy';

%espace d'étude
x=borne_inf:pas:borne_sup;

%évaluation de la fonction
eval=zeros(1,size(x,2));
evald=zeros(1,size(x,2));
for jj=1:size(x,2)
   eval(1,jj)=feval(fct,x(jj),para,'f');
   evald(1,jj)=feval(fct,x(jj),para,'d');
end

%tracé 
figure;
plot(x,eval)
hold on;
plot(x,evald,'r');
ylim([-2,2])
xlabel('x');
ylabel('f(x) et df/dx');
titre=['Evaluation de la fonction ' fct ' et de sa dérivée'];
title(titre);


%%étude 3D
%paramètres
para=0.2;
pas=0.05;
borne_sup=1;
borne_inf=-1;
%fonction
fct='cauchy';

%espace d'étude
x=borne_inf:pas:borne_sup;
y=x;
[X,Y]=meshgrid(x,y);

%évaluation de la fonction
eval=zeros(size(X));
evald1=eval;evald2=eval;
for jj=1:size(X,1)
    for ll=1:size(X,2)
       eval(jj,ll)=feval(fct,[X(jj,ll) Y(jj,ll)]',para,'f');
       gr=feval(fct,[X(jj,ll) Y(jj,ll)]',para,'d');
       gr=gr/norm(gr,2);
       evald1(jj,ll)=gr(1,:);
       evald2(jj,ll)=gr(2,:);
    end
end

%tracé 
figure;
surf(X,Y,eval)
%figure;
hold on;
quiver3(x,y,eval,evald1,evald2,-ones(size(X)),0.5);
%ylim([-2,2])
xlabel('x');
ylabel('f(x) et df/dx');
titre=['Evaluation de la fonction ' fct ' et de sa dérivée'];
title(titre);
figure
quiver3(x,y,eval,evald1,evald2,-ones(size(X)),0.5);
figure
[C,h] = contour(X,Y,eval,5);
set(h,'LineWidth',2)

hold on
quiver(x,y,evald1,evald2,0.5,'r')
text_handle = clabel(C,h);
set(text_handle,'BackgroundColor',[1 1 .6],...
    'Edgecolor',[.7 .7 .7])
