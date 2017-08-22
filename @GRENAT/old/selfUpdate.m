        %check if update could be done
        function s=selfUpdate(obj,flag)
            if nargin==1
                flag=obj.requireUpdate;
            end
            %load folder of GRENAT
            f=fileparts(mfilename('fullpath'));
            if flag
                if exist(fullfile('.git'),'dir')
                    [e,s]=system(['cd ' f ' && git pull origin']);
                    if e==0
                        Gfprintf('GRENAT has been update\n');
                        s=false;
                        obj.requireUpdate=false;
                    end
                else
                    Gfprintf('Not a git version: update not available\n');
                end
            end
        end