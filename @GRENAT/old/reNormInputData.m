        %ReNormalization of the input data
        function dataOut=reNormInputData(obj,type,dataIn)
            if obj.confMeta.normOn
                %preparing data structures
                infoDataS=obj.norm.sampling;
                infoDataR=obj.norm.resp;
                %for various situations
                switch type
                    case 'SamplePts'
                        dataOut=NormRenorm(dataIn,'renorm',infoDataS);
                    case 'Resp'
                        dataOut=NormRenorm(dataIn,'renorm',infoDataR);
                    case 'Grad'
                        dataOut=NormRenormG(dataIn,'renorm',infoDataS,infoDataR);
                end
            else
                if nargin>2
                    dataOut=dataIn;
                end
            end
        end