%% Cauchy's function
%% L. LAURENT -- 15/03/2010 -- luc.laurent@lecnam.net
%%  modif on 12/04/2010 // 31/08/2015

function [k,dk,ddk]=cauchy(xx,para)

%number of output parameters
nbOut=nargout;
%check hyperparameters
nP=size(para,2);
if nP~=2
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%evaluation de la fonction
te=xx'*xx/para^2;
ev=1/(1+te);

%traitement des cas d'appel (fonction ou sa derivee)
switch type
    %evaluation de la fonction
    case 'f'
        G=ev;
        
    %evaluation de la derivee ou du gradient de la fonction (suivant la
    %dimension de xx
    case 'd'
        dd=zeros(size(xx,1),1);
        taille=size(xx,1);
        for ii=1:taille
            dd(ii,1)=-2*xx(ii,1)*ev^2 /para^2;
        end
         G=dd;
    otherwise
        error('Type de parametres non pris en compte (f ou d) cf. cauchy.m');
        
        
end

end