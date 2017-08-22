        %display the reference surface
        function showRespRef(obj)
            obj.confDisp.title=('Reference');
            displaySurrogate(obj.sampleRef,obj.respRef,obj.sampling,obj.resp,obj.grad,obj.confDisp);
        end