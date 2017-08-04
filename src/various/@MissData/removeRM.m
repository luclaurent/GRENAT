    function VV=removeRM(obj,V,type)
            %size of the input matrix
            sV=size(V);
            %deal with no force parameter
            if nargin<3;type='';end
            %deal with different options (in type)
            force=false;
            sizS=obj.nS;
            maskC=obj.ixMissResp;
            switch type
                case {'f','F','force','Force','FORCE'}
                    force=true;
                case {'n','N','new','New','NEW'}
                    sizS=obj.NnS;
                    maskC=obj.newResp.ixMissResp;
            end
            if (sV(1)==sizS&&sV(2)==sizS)||force
                VV=V;
                VV(maskC,:)=[];
                VV(:,maskC)=[];
            else
                VV=V;
                Gfprintf(' ++ Wrong size of the input square matrix\n ++ |(%i,%i), expected: (%i,%i)| (or use force)\n',sV(1),sV(2),sizS,sizS);
            end
        end