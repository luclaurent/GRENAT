fun=@(x)(NaN)
lb=1
ub=20
options = optimset(...
                'Display', 'iter',...        %affichage evolution
                'Algorithm','interior-point',... %choix du type d'algorithme
                ...           %fonction assurant l'arret de la procedure de minimisation et les traces des iterations de la minimisation
                'FunValCheck','off',...
                'UseParallel','always',...
                'PlotFcns','');
            try
fmincon(fun,10,[],[],[],[],lb,ub,[],options)
catch exception
                    %throw(exception);
                    text='undefined at initial point0';
                    [tt,ss,ee]=regexp(exception.message,[text],'match','start','end');
                    tt
                    ss
                    ee
                    isempty(tt)
                    exitflag=1;
                end