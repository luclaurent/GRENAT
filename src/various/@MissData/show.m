%% show information
        function show(obj)
            if obj.verbose
                if obj.nbMissResp==0&&obj.nbMissGrad==0
                    Gfprintf('>>> No missing data\n');
                end
                %
                if obj.nbMissResp~=0
                    Gfprintf('>>> %i Missing response(s) at point(s):\n',obj.nbMissResp);
                    %
                    for ii=1:obj.nbMissResp
                        numPts=obj.ixMissResp(ii);
                        Gfprintf(' n%s %i (%4.2f',char(176),numPts,obj.sampling(numPts,1));
                        if obj.nP>1;fprintf(',%4.2f',obj.sampling(numPts,2:end));end
                        fprintf(')\n');
                    end
                end
                %
                if ~obj.emptyGrad
                    if obj.nbMissGrad~=0
                        Gfprintf('>>> %i Missing gradient(s) at point(s):\n',obj.nbMissGrad);
                        %sort responses
                        [~,iS]=sort(obj.ixMissGrad(:,1));
                        %
                        for ii=1:obj.nbMissGrad
                            numPts=obj.ixMissGrad(iS(ii),1);
                            component=obj.ixMissGrad(ii,2);
                            Gfprintf(' n%s %i (%4.2f',char(176),numPts,obj.sampling(numPts,1));
                            if obj.nP>1;fprintf(',%4.2f',obj.sampling(numPts,2:end));end
                            fprintf(')');
                            fprintf('  component: %i\n',component);
                        end
                        Gfprintf('----------------\n')
                    end
                end
            end
        end