       %check if all data is available for displaying the reference
        %surface and gradients
        function [okAll,okSample,okResp,okGrad]=checkRef(obj)
            okSample=false;
            okResp=false;
            okGrad=false;
            nbSRef(1)=size(obj.sampleRef,1);
            nbSRef(2)=size(obj.sampleRef,2);
            nbSRef(3)=size(obj.sampleRef,3);
            nbRRef(1)=size(obj.respRef,1);
            nbRRef(2)=size(obj.respRef,2);
            nbRRef(3)=size(obj.respRef,3);
            nbGRef(1)=size(obj.gradRef,1);
            nbGRef(2)=size(obj.gradRef,2);
            nbGRef(3)=size(obj.gradRef,3);
            if sum(nbSRef(:))~=0
                okSample=true;
                if nbSRef(1)==nbRRef(1)
                    okResp=true;
                end
                if nbGRef(3)==1
                    if nbGRef(1)==nbSRef(1)&&nbGRef(2)==nbSRef(2)
                        okGrad=true;
                    end
                elseif nbGRef(3)==nbSRef(2)&&nbGRef(1)==nbSRef(1)
                    okGrad=true;
                elseif all(nbGRef==nbSRef)
                    okGrad=true;
                end
            end
            okAll=okSample&&okResp&&okGrad;
            %display error messages
            if ~okSample;Gfprintf('>> Wrong definition of the reference sample points\n');end
            if ~okResp;Gfprintf('>> Wrong definition of the reference responses\n');end
            if ~okGrad;Gfprintf('>> Wrong definition of the reference gradients\n');end
        end