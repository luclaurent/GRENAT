       %initialize data (remove saved data)
        function initData(obj,type)
            if nargin==1
                obj.sampling=[];
                obj.resp=[];
                obj.grad=[];
            elseif nargin==2
                switch type
                    case 'Sampling'
                        obj.samplingN=obj.sampling;
                    case 'Resp'
                        obj.respN=obj.resp;
                    case 'Grad'
                        obj.gradN=obj.grad;
                end
            end
        end