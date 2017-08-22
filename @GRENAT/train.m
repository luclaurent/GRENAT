       %train the metamodel
        function train(obj)
            %normalization of the input data
            normInputData(obj,'initSamplePts');
            normInputData(obj,'initResp');
            obj.gradN=normInputData(obj,'Grad',obj.grad);
            %check if data are missing
            checkMissingData(obj);
            %store normalization data
            obj.confMeta.norm=obj.norm;
            %train surrogate model
            obj.dataTrain=BuildMeta(obj.samplingN,obj.respN,obj.gradN,obj.confMeta);
            %save estimate parameters
            if isfield(obj.dataTrain.build,'para');
                obj.confMeta.definePara(obj.dataTrain.build.para);
                obj.confMeta.updatePara;
            end
            %change state of flags
            obj.runTrain=false;
            obj.runErr=true;
            
            % keyboard
            % if metaData.norm.on&&~isempty(metaData.norm.resp.std)
            %     ret.build.sig2=ret.build.sig2*metaData.norm.resp.std^2;
            % end
        end