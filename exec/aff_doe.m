%% Procédure assurant l'affichage des tirages en nD
%% L. LUARENT -- 10/02/2012 -- laurent@lmt.ens-cachan.fr


function aff_doe(tirages,doe)

%recupeŽration bornes espace de conception
if isfield(doe,'Xmin')&&isfield(doe,'Xmax')
    Xmin=doe.Xmin;
    Xmax=doe.Xmax;
elseif isfield(doe,'bornes')
    Xmin=doe.bornes(:,1);
    Xmax=doe.bornes(:,2);
end

%nombre de variables
nbv=numel(Xmin);

if doe.aff
    para=0.1;
    if nbv==1
        figure
        yy=0.*tirages;
        plot(tirages,yy,'o','MarkerEdgeColor','b','MarkerFaceColor','b')
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
        plot(tirages(:,1),tirages(:,2),'o','MarkerEdgeColor','b','MarkerFaceColor','b')
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
                    plot(tirages(:,ii),tirages(:,jj),'o','MarkerEdgeColor','b','MarkerFaceColor','b')
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