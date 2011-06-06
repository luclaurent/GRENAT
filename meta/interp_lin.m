%% Interpolation par fonction de base lineaire
%% L. LAURENT -- 30/05/2011 -- laurent@lmt.ens-cachan.fr

function [Z,GZ]=interp_lin(x,tirages,eval)

%% distinction des cas 1D et 2D
dim=size(tirages,2);

if dim==1
    if nargout==1
        %determination des fonctions de base
        h=fct_base_inter_lin(x,tirages);
        %evaluation de la reponse
        Z=eval'*h;
    elseif nargout==2
        %determination des fonctions de base
        [h,dh]=fct_base_interp_lin(x,tirages);
        %evaluation de la reponse
        Z=eval'*h;
        GZ=eval'*dh;
    end 
    
elseif dim==2
    tir1=tirages(:,1);
    tir2=tirages(:,2);
    if nargout==1
        %determination des fonctions de base
        h1=fct_base_inter_lin(x(1),tir1);
        h2=fct_base_inter_lin(x(2),tir2);
        %evaluation de la reponse
        h=h1'*h2;
        Z=eval(:)'*h(:);
    elseif nargout==2
        %determination des fonctions de base
        [h1,dd1]=fct_base_inter_lin(x(1),tir1);
        [h2,dd2]=fct_base_inter_lin(x(2),tir2);
        %evaluation de la reponse
        h=h1'*h2;
        dh1=dd1'*h2;
        dh2=dd2'*h1;
        Z=eval'*h;
        GZ(1)=eval(:)*dh1(:);
        GZ(2)=eval(:)*dh2(:);
    end 
    
else
    error('mauvaise dimension des données pour l''interpolation linéaire (cf. interp_lin.m)');
end