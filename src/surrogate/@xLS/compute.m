        %% compute regressors
        function compute(obj,flagRun)
            %if no flagRun specified
            if nargin==1;flagRun=true;end
            obj.nbMonomialTerms=size(obj.valFunPoly,2);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %determine regressors
            obj.XX=[obj.valFunPoly;obj.valFunPolyD];
            obj.YYtot=[obj.YY;obj.YYD];
            obj.fct=obj.XX'*obj.XX;
            obj.fcY=obj.XX'*obj.YYtot;
            %deal with insufficent number of equations
            if flagRun
                Gfprintf(' ++ Build regressors\n');
                if obj.nbMonomialTerms>numel(obj.YYtot)
                    Gfprintf(' > !! matrix ill-conditionned (%i mono., %i resp. and grad.)!! (use pinv)\n',...
                        obj.nbMonomialTerms,numel(obj.YYtot));
                    obj.beta=pinv(obj.fct)*obj.fcY;
                else
                    obj.beta=obj.fct\obj.fcY;
%                     
%                     tic
%                     obj.fct=obj.XX'*obj.XX;
%                     [obj.Q,obj.R]=qr(obj.fct);
%                     obj.beta=obj.R\(obj.Q'*obj.fcY);
%                     toc
%                     tic
%                     fct=obj.XX'*obj.XX;
%                     fcY=obj.XX'*obj.YYtot;
%                     zz=fct\fcY;
%                     toc
%                     tic
%                     [Q,R,e]=qr(obj.XX,'vector');
%                     %keyboard
%                     toc
%                     tic
%                      [Q,R,P]=qr(obj.XX);
%                      toc
%                     qy=Q'*obj.YYtot;
%                     x=R\qy;
%                     bb=P*x;                   
%                     toc
%                      all(bb(:)==obj.beta)
%                     keyboard
                end
            end
        end
