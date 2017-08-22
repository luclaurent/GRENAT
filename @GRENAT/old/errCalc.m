       %compute and show the errors of the metamodel (using reference if it is
        %available)
        function errCalc(obj)
            obj.err=critErrDisp(obj.nonsampleResp,obj.respRef,obj.dataTrain.build);
            obj.runErr=false;
        end