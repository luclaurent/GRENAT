       %update the metamodel by adding sample points and associated
        %responses and gradients
        function update(obj,samplingIn,respIn,gradIn,paraFind,varargin)
            %add data
            if ~isempty(samplingIn)
                obj.sampling=samplingIn;
                obj.resp=respIn;
                obj.grad=gradIn;
                %initialize flags
                initRunTrain(obj,true);
                initRunEval(obj,true);
                %change status of the estimation of the parameters
                obj.confMeta.conf('estimOn',paraFind);
                %deal with additional options
                if nargin>5;
                    obj.confMeta.conf(varargin{:});
                end
                %train the metamodel
                obj.train();
            end
        end
        