function iX=checkResp(obj,respIn)
            respCheck=obj.resp;
            if nargin>1
                respCheck=respIn;
            end
            %look for missing data in responses
            obj.maskResp=isnan(respCheck);
            obj.nbMissResp=sum(obj.maskResp);
            obj.ixMissResp=find(obj.maskResp==true);
            obj.ixAvailResp=find(obj.maskResp==false);
            %
            iX.maskResp=obj.maskResp;
            iX.nbMissResp=obj.nbMissResp;
            iX.ixMissResp=obj.ixMissResp;
            iX.ixAvailResp=obj.ixAvailResp;
            iX.nbMissResp=obj.nbMissResp;
            %
            if nargin==1
                obj.missRespAll=false;
                if obj.nbMissResp==obj.nS;obj.missRespAll=true;end
                iX.missRespAll=obj.missRespAll;
            end
            
        end