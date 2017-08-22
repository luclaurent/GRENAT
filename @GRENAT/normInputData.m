      %Normalization of the input data
        function dataOut=normInputData(obj,type,dataIn)
            if obj.confMeta.normOn
                %preparing data structures
                infoDataS=obj.norm.sampling;
                infoDataR=obj.norm.resp;
                %for various situations
                switch type
                    case 'initSamplePts'
                        [obj.samplingN,infoDataS]=NormRenorm(obj.sampling,'norm');
                        obj.normMeanS=infoDataS.mean;
                        obj.normStdS=infoDataS.std;
                        obj.normSamplePtsIn=true;
                    case 'initResp'
                        [obj.respN,infoDataR]=NormRenorm(obj.resp,'norm');
                        obj.normMeanR=infoDataR.mean;
                        obj.normStdR=infoDataR.std;
                        obj.normRespIn=true;
                    case 'SamplePts'
                        dataOut=NormRenorm(dataIn,'norm',infoDataS);
                    case 'Resp'
                        dataOut=NormRenorm(dataIn,'norm',infoDataR);
                    case 'Grad'
                        if ~isempty(dataIn)
                            dataOut=NormRenormG(dataIn,'norm',infoDataS,infoDataR);
                        else
                            dataOut=[];
                        end
                end
            else
                if nargin>2
                    dataOut=dataIn;
                end
            end
        end