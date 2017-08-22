        %display the reference gradients surface
        function showGradRef(obj,nbG)
            %default value
            if nargin==1;nbG=1:size(obj.nonsampleGrad,3);end
            for itG=1:numel(nbG)
                obj.confDisp.title=(['Gradients Reference /x' num2str(nbG(itG))]);
                displaySurrogate(obj.sampleRef,obj.gradRef(:,:,nbG(itG)),obj.sampling,obj.resp,obj.grad,obj.confDisp);
            end
        end