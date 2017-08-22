        function show1D(obj)
            figure;
            %depend if the reference is available or not
            if checkRef(obj)
                obj.nbSubplot=231;
                if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
                obj.confDisp.conf('samplePts',true,'sampleGrad',false);
                showRespRef(obj);
                obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
                %remove display of sample points
                obj.confDisp.conf('samplePts',true,'sampleGrad',true);
                showGradRef(obj);
                obj.nbSubplot=obj.nbSubplot+1;
            else
                obj.nbSubplot=221;
            end
            obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
            obj.confDisp.conf('samplePts',true,'sampleGrad',false);
            showResp(obj);
            obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
            %remove display of sample points
            obj.confDisp.conf('samplePts',true,'sampleGrad',true);
            showGrad(obj);
            obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
            showCI(obj,[]);
        end