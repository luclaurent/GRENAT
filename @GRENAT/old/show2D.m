       function show2D(obj)
            figure;
            %depend if the reference is available or not
            if checkRef(obj)
                obj.nbSubplot=331;
                if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
                obj.confDisp.conf('samplePts',true);
                showRespRef(obj);
                obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
                %remove display of sample points
                obj.confDisp.conf('samplePts',false,'sampleGrad',false);
                showGradRef(obj,1);
                obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
                showGradRef(obj,2);
            else
                obj.nbSubplot=231;
            end
            obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
            obj.confDisp.conf('samplePts',true);
            showResp(obj);
            obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
            %remove display of sample points
            obj.confDisp.conf('samplePts',false,'sampleGrad',false,'gridGrad',false);
            showGrad(obj,1);
            obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
            showGrad(obj,2);
            obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
            showCI(obj,[]);
       end
       