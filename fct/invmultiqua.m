%%fonction à base radiale: multiquadaratique inverse

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010 modif le 12/04/2010

function G=invmultiqua(xx,para,type)

%evaluation de la fonction
te=xx'*xx/para^2;
ev=1/sqrt(1+te);

%traitement des cas d'appel (fonction ou sa dérivée)
switch type
    %évaluation de la fonction

    case 'f'
        G=ev;
        
    %évaluation de la dérivée ou du gradient de la fonction (suivant la
    %dimension de xx
    case 'd'
        dd=zeros(size(xx,1),1);
        taille=size(xx,1);
        for ii=1:size(xx,1)
            mm=zeros(taille,1);
            mm(ii,1)=1;
            dd(ii,1)=-xx'*mm*ev^3 /para^2;
        end
         G=dd;
    otherwise
        error('Type de paramètres non pris en compte (f ou d) cf. gauss.m');
        
        
end

end