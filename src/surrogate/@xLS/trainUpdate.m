        
        %% Building/training the updated metamodel
        function trainUpdate(obj,samplingIn,respIn,gradIn)
            %Prepare data
            obj.updateData(respIn,gradIn);
            %Build regression matrix (for the trend model)
            
            %depending on the availability of the gradients
            if ~obj.flagGLS
                newVal=MultiMono(samplingIn,obj.polyOrder);
                if obj.checkNewMiss
                    %remove missing response(s)
                    newVal=obj.missData.removeRV(newVal,'n');
                end
                obj.valFunPoly=[obj.valFunPoly;newVal];
            else
                %gradient-based
                [MatX,MatDX]=MultiMono(samplingIn,obj.polyOrder);
                %remove lines associated to the missing data
                if obj.checkNewMiss
                    MatX=obj.missData.removeRV(MatX,'n');
                    MatDX=obj.missData.removeGV(MatDX,'n');
                end
                obj.valFunPoly=[obj.valFunPoly;MatX];
                obj.valFunPolyD=[obj.valFunPolyD;MatDX];
            end
            %compute regressors
            obj.compute();
        end