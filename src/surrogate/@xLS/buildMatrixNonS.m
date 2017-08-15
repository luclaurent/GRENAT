        %% regression matrix at the non-sample points
        function [ff,jf]=buildMatrixNonS(obj,U)
            calcGrad=false;
            if nargout>1
                calcGrad=true;
            end
            if calcGrad
                [ff,jf]=MultiMono(U,obj.polyOrder);
            else
                [ff]=MultiMono(U,obj.polyOrder);
            end
        end