%% Procédure assurant l'affichage des tirages en nD
%% L. LUARENT -- 10/02/2012 -- laurent@lmt.ens-cachan.fr


function aff_doe(tirages,doe)

%recupŽration bornes espace de conception
esp=doe.bornes;

%nombre de variables
nbv=size(esp,1);

if doe.aff
    para=0.1;
    if nbv==1
        figure
        yy=0.*tirages;
        plot(tirages,yy,'o','MarkerEdgeColor','b','MarkerFaceColor','b')
        xmin=esp(:,1);
        xmax=esp(:,2);
        dep=xmax-xmin;
        axis([(xmin-para*dep) (xmax+para*dep) -1 1])
    elseif nbv==2
        figure
        xmin=esp(1,1);
        xmax=esp(1,2);
        ymin=esp(2,1);
        ymax=esp(2,2);
        depx=xmax-xmin;
        depy=ymax-ymin;
        plot(tirages(:,1),tirages(:,2),'o','MarkerEdgeColor','b','MarkerFaceColor','b')
        axis([(xmin-para*depx) (xmax+para*depx) (ymin-para*depy) (ymax+para*depy)])
        line([xmin;xmin;xmax;xmax;xmax;xmax;xmax;xmin],[ymin;ymax;ymax;ymax;ymax;ymin;ymin;ymin])
    else
        figure
        it=0;
        Xmin=esp(:,1);
        Xmax=esp(:,2);
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