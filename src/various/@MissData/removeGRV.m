
        %% remove missing data in vector/matrix (responses+gradients)
        function VV=removeGRV(obj,V,type)
            %size of the input vector
            sV=size(V);
            %deal with no force parameter
            if nargin<3;type='';end
            %deal with different options (in type)
            force=false;
            sizS=obj.nS;
            opt='';
            switch type
                case {'f','F','force','Force','FORCE'}
                    force=true;
                    opt='f';
                case {'n','N','new','New','NEW'}
                    sizS=obj.NnS;
                    opt='n';
            end
            if (sV(1)==sizS*(obj.nP+1))||force
                Va=obj.removeRV(V(1:sizS,:),opt);
                Vb=obj.removeGV(V(sizS+1:end,:),opt);
                VV=[Va;Vb];
            else
                VV=V;
                Gfprintf(' ++ Wrong size of the input vector\n ++ |%i, expected: %i|\n',sV(1),sizS*(obj.nP+1));
            end
        end