%% compute number of required internal parameters
        function nbP=computeNbPara(obj)
            switch obj.fctKern
                case {'sexp','matern32','matern52'}
                    nbP=unique([1,obj.nP]);
                case {'matern'}
                    nbP=[1,obj.nP]+1;
            end
        end