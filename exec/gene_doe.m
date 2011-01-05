%% Realisation des tirages
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function tirages=gene_doe(doe)

fprintf('===== DOE =====\n');
%on traite separement les etudes 1D ou 2D
if size(doe.bornes,2)==1
    xmin=doe.bornes(1);
    xmax=doe.bornes(2);
    switch doe.type
        case 'ffact'
            tirages=factorial_design(doe.nb_samples,xmin,xmax);
        case 'sfill'
            xxx=linspace(xmin,xmax,doe.nb_samples);
            tirages=xxx';
        case 'LHS'
            tirages=lhsu(xmin,xmax,doe.nb_samples);
        otherwise
            error('le type de tirage nest pas defini');
    end
    
elseif size(doe.bornes,2)==2
    xmin=doe.bornes(1,1);
    xmax=doe.bornes(1,2);
    ymin=doe.bornes(2,1);
    ymax=doe.bornes(2,2);
    %on prend en compte les tirages differents suivant les variables de
    %conceptions
    if length(doe.nb_samples)==2
        nb_s1=doe.nb_samples(1);
        nb_s2=doe.nb_samples(2);
    else
        nb_s1=doe.nb_samples;
        nb_s2=nb_s1;
    end
    
    switch doe.type
        case 'ffact'
            tirages=factorial_design(nb_s1,nb_s2,xmin,xmax,ymin,ymax);
        case 'sfill'
            xxx=linspace(xmin,xmax,nb_s1);
            yyy=linspace(ymin,ymax,nb_s2);
            tirages=zeros(size(xxx,2)^2,2);
            for ii=1:size(xxx,2)
                for jj=1:size(xxx,2)
                    tirages(size(xxx,2)*(ii-1)+jj,1)=xxx(ii);
                    tirages(size(xxx,2)*(ii-1)+jj,2)=yyy(jj);
                end
            end
        case 'LHS'
            Xmin=[xmin,ymin];
            Xmax=[xmax,ymax];
            tirages=lhsu(Xmin,Xmax,nb_s1*nb_s2);
        case 'rand'
            tirages=zeros(nb_s1*nb_s2);
            tirages(:,1)=xmin+(xmax-xmin)*rand(nb_s1*nb_s2,1);
            tirages(:,2)=ymin+(ymax-ymin)*rand(nb_s1*nb_s2,1);
        otherwise
            error('le type de tirage nest pas defini');
    end
else
    error('Dimension de problème non pris en charge\n');
end