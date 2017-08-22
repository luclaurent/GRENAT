       %ordering data (for manipulating nd-arrays)
        function dataOut=orderData(obj,dataIn,type)
            switch type
                case 'sampleIn'
                    %size of the input data
                    obj.sizeNonSample=[size(dataIn,1),size(dataIn,2),size(dataIn,3)];
                    %in the case of nd-array
                    if obj.sizeNonSample(3)>1
                        dataOut=reshape(dataIn,[ obj.sizeNonSample(1)*obj.sizeNonSample(2),obj.sizeNonSample(3),1]);
                    else
                        dataOut=dataIn;
                    end
                case 'sampleOut'
                    if obj.sizeNonSample(3)>1
                        dataOut=reshape(dataIn,[ obj.sizeNonSample(1),obj.sizeNonSample(2),obj.sizeNonSample(3)]);
                    else
                        dataOut=dataIn;
                    end
                case 'respOut'
                    if obj.sizeNonSample(3)>1
                        dataOut=reshape(dataIn,[ obj.sizeNonSample(1),obj.sizeNonSample(2)]);
                    else
                        dataOut=dataIn;
                    end
                case 'gradOut'
                    if obj.sizeNonSample(3)>1
                        dataOut=reshape(dataIn,[ obj.sizeNonSample(1),obj.sizeNonSample(2),obj.sizeNonSample(3)]);
                    else
                        dataOut=dataIn;
                    end
            end
        end