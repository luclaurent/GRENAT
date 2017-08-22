      %evaluate the metamodel
        function [Z,GZ,variance]=eval(obj,nonsamplePts,Verb)
            if nargin<3;Verb=true;end
            %check if the metamodel has been already trained
            if obj.runTrain;train(obj);end
            %store non sample points
            if nargin>1;obj.nonsamplePts=nonsamplePts;end
            %evaluation of the metamodels
            if obj.runEval
                %normalization of the input data
                obj.nonsamplePtsN=normInputData(obj,'SamplePts',obj.nonsamplePtsOrder);
                %evaluation of the metamodel
                [K]=EvalMeta(obj.nonsamplePtsN,obj.dataTrain,obj.confMeta,Verb);
                %store data from the evaluation
                obj.nonsampleRespN=K.Z;
                obj.nonsampleGradN=K.GZ;
                obj.nonsampleVarOrder=K.var;
                %renormalization of the data
                obj.nonsampleRespOrder=reNormInputData(obj,'Resp',obj.nonsampleRespN);
                obj.nonsampleGradOrder=reNormInputData(obj,'Grad',obj.nonsampleGradN);
                %update flags
                obj.runEval=false;
                obj.runErr=true;
            end
            %extract unnormalized data
            Z=obj.nonsampleResp;
            GZ=obj.nonsampleGrad;
            variance=obj.nonsampleVar;
        end