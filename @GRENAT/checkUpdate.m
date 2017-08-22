       %check if update could be done
        function s=checkUpdate(obj)
            s=false;
            obj.requireUpdate=false;
            %load folder of GRENAT
            f=fileparts(mfilename('fullpath'));
           if exist(fullfile('.git'),'dir')
               [e,~]=system(['cd ' f ' && git status -uno | grep up-to-date && exit 3']);
               if e==3
                   Gfprintf('GRENAT is up to date\n');
               else
                   Gfprintf('GRENAT could be update\n');
                   s=true;
                   obj.requireUpdate=true;
               end
           else
               Gfprintf('Not a git version: checking update not available\n');
           end
        end