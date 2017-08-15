       %% Building/training metamodel
        function train(obj,flagRun)
            if nargin==1;flagRun=false;end
            obj.showInfo('start');
            %Prepare data
            obj.setData;
            %Build regression matrix (for the trend model)            
            %depending on the availability of the gradients
            if ~obj.flagGLS
                obj.valFunPoly=MultiMono(obj.sampling,obj.polyOrder);
                if obj.checkMiss
                    %remove missing response(s)
                    obj.valFunPoly=obj.missData.removeRV(obj.valFunPoly);
                end
            else
                %gradient-based
                [MatX,MatDX]=MultiMono(obj.sampling,obj.polyOrder);
                %remove lines associated to the missing data
                if obj.checkMiss
                    obj.valFunPoly=obj.missData.removeRV(MatX);
                    obj.valFunPolyD=obj.missData.removeGV(MatDX);
                else
                    obj.valFunPoly=MatX;
                    obj.valFunPolyD=MatDX;
                end
            end
            %compute regressors
            obj.compute(flagRun);
            obj.showInfo('end');
        end