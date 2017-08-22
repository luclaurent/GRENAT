        %display the response approximated by the metamodel
        function showResp(obj)
            obj.confDisp.title=('Approximated responses');
            displaySurrogate(obj.nonsamplePts,obj.nonsampleResp,obj.sampling,obj.resp,obj.grad,obj.confDisp);
        end