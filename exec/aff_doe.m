%% Procédure assurant l'affichage des tirages en nD
%% L. LUARENT -- 10/02/2012 -- laurent@lmt.ens-cachan.fr


function aff_doe(tirages,doe,manq)

%recupeŽration bornes espace de conception
if isfield(doe,'Xmin')&&isfield(doe,'Xmax')
    Xmin=doe.Xmin;
    Xmax=doe.Xmax;
elseif isfield(doe,'bornes')
    Xmin=doe.bornes(:,1);
    Xmax=doe.bornes(:,2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%recherche et tri des manques d'information
liste_pts_ok=1:size(tirages,1);
liste_eval_manq=[];
liste_grad_manq=[];
liste_both_manq=[];
if nargin==3
    if manq.eval.on
        liste_eval_manq=unique(manq.eval.ix_manq(:));
        for ii=1:numel(liste_eval_manq)
            ix=find(liste_pts_ok==liste_eval_manq(ii));
            liste_pts_ok(ix)=[];
        end
    end
    if manq.grad.on
        liste_grad_manq=unique(manq.grad.ix_manq(:,1));
        for ii=1:numel(liste_grad_manq)
            ix=find(liste_pts_ok==liste_grad_manq(ii));
            liste_pts_ok(ix)=[];
        end
    end
    if manq.eval.on|| manq.grad.on
        liste_both_manq=intersect(liste_eval_manq,liste_grad_manq);
        for ii=1:numel(liste_both_manq)
            ix=find(liste_eval_manq==liste_both_manq(ii));
            liste_eval_manq(ix)=[];
            ix=find(liste_grad_manq==liste_both_manq(ii));
            liste_grad_manq(ix)=[];
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nombre de variables
nbv=numel(Xmin);

if doe.aff
    para=0.1;
    if nbv==1
        figure
        yy=0.*tirages;
        %affichage points ou toutes les infos sont connues
        plot(tirages(liste_pts_ok),yy(liste_pts_ok),...
            'o','MarkerEdgeColor','k',...
            'MarkerFaceColor','k',...
            'MarkerSize',15);
        hold on
        %affichage points il manque une/des reponse(s)
        plot(tirages(liste_eval_manq),yy(liste_eval_manq),...
            'rs','MarkerEdgeColor','r',...
            'MarkerFaceColor','r',...
            'MarkerSize',7);
        %affichage points il manque un/des gradient(s)
        plot(tirages(liste_grad_manq),yy(liste_grad_manq),...
            'v','MarkerEdgeColor','g',...
            'MarkerFaceColor','g',...
            'MarkerSize',15);
        %affichage points il manque un/des gradient(s) et un/des
        %reponse(s) au même point
        plot(tirages(liste_both_manq),yy(liste_both_manq),...
            'd','MarkerEdgeColor','r',...
            'MarkerFaceColor','r',...
            'MarkerSize',15);
        hold off
        xmin=Xmin;
        xmax=Xmax;
        dep=xmax-xmin;
        axis([(xmin-para*dep) (xmax+para*dep) -1 1])
    elseif nbv==2
        figure
        xmin=Xmin(1);
        xmax=Xmax(1);
        ymin=Xmin(2);
        ymax=Xmax(2);
        depx=xmax-xmin;
        depy=ymax-ymin;
        %affichage points ou toutes les infos sont connues
        plot(tirages(liste_pts_ok,1),tirages(liste_pts_ok,2),...
            'o','MarkerEdgeColor','k',...
            'MarkerFaceColor','k',...
            'MarkerSize',7);
        hold on
        %affichage points il manque une/des reponse(s)
        plot(tirages(liste_eval_manq,1),tirages(liste_eval_manq,2),...
            'rs','MarkerEdgeColor','r',...
            'MarkerFaceColor','r',...
            'MarkerSize',7);
        %affichage points il manque un/des gradient(s)
        plot(tirages(liste_grad_manq,1),tirages(liste_grad_manq,2),...
            'v','MarkerEdgeColor','g',...
            'MarkerFaceColor','g',...
            'MarkerSize',7);
        %affichage points il manque un/des gradient(s) et un/des
        %reponse(s) au même point
        plot(tirages(liste_both_manq,1),tirages(liste_both_manq,2),...
            'd','MarkerEdgeColor','r',...
            'MarkerFaceColor','r',...
            'MarkerSize',7);
        hold off
        axis([(xmin-para*depx) (xmax+para*depx) (ymin-para*depy) (ymax+para*depy)])
        line([xmin;xmin;xmax;xmax;xmax;xmax;xmax;xmin],[ymin;ymax;ymax;ymax;ymax;ymin;ymin;ymin])
    else
        figure
        it=0;
        Depx=Xmax-Xmin;
        for ii=1:nbv
            for jj=1:nbv
                it=it+1;
                if ii~=jj
                    subplot(nbv,nbv,it)
                    %affichage points ou toutes les infos sont connues
                    plot(tirages(liste_pts_ok,ii),tirages(liste_pts_ok,jj),...
                        'o','MarkerEdgeColor','k',...
                        'MarkerFaceColor','k',...
                        'MarkerSize',7);
                    hold on
                    %affichage points il manque une/des reponse(s)
                    plot(tirages(liste_eval_manq,ii),tirages(liste_eval_manq,jj),...
                        'rs','MarkerEdgeColor','r',...
                        'MarkerFaceColor','r',...
                        'MarkerSize',7);
                    %affichage points il manque un/des gradient(s)
                    plot(tirages(liste_grad_manq,ii),tirages(liste_grad_manq,jj),...
                        'v','MarkerEdgeColor','g',...
                        'MarkerFaceColor','g',...
                        'MarkerSize',7);
                    %affichage points il manque un/des gradient(s) et un/des
                    %reponse(s) au même point
                    plot(tirages(liste_both_manq,ii),tirages(liste_both_manq,jj),...
                        'd','MarkerEdgeColor','r',...
                        'MarkerFaceColor','r',...
                        'MarkerSize',7);
                    hold off
                    xmin=Xmin(ii);xmax=Xmax(ii);ymin=Xmin(jj);ymax=Xmax(jj);depx=Depx(ii);depy=Depx(jj);
                    axis([(xmin-para*depx) (xmax+para*depx) (ymin-para*depy) (ymax+para*depy)])
                    line([xmin;xmin;xmax;xmax;xmax;xmax;xmax;xmin],[ymin;ymax;ymax;ymax;ymax;ymin;ymin;ymin])
                else
                    subplot(nbv,nbv,it)
                    hist(tirages(:,ii))
                end
            end
        end
    end
end