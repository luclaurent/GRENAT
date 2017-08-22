        %display the surrogate model
        function show(obj,varargin)
            %depending of the kind of data
            if obj.sizeNonSample(3)==2
                obj.confDisp.conf('d3',true,'contour',true);
                %if argument
                if nargin>1;obj.confDisp.conf(varargin{:});end
                show2D(obj);
            elseif obj.sizeNonSample(3)==1
                obj.confDisp.conf('d3',false,'d2',false);
                %if argument
                if nargin>1;obj.confDisp.conf(varargin{:});end
                show1D(obj);
            end
        end
        