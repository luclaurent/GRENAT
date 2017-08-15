        %% Show information in the console
        function showInfo(obj,type)
            switch type
                case {'start','START','Start'}
                    textd='++ Type: ';
                    textf='';
                    Gfprintf('\n%s\n',[textd 'Least-Squares ((G)LS)' textf]);
                    Gfprintf('>> Deg : %i \n',obj.polyOrder);
                    %
                    %if dispTxtOnOff(obj.cvOn,'>> CV: ',[],true)
                    %    dispTxtOnOff(obj.cvFull,'>> Computation all CV criteria: ',[],true);
                    %    dispTxtOnOff(obj.cvDisp,'>> Show CV: ',[],true);
                    %end
                    %
                    Gfprintf('\n');
                case {'update'}
                    Gfprintf(' ++ Update xLS\n');
                case {'cv','CV'}
                case {'end','End','END'}
                    Gfprintf(' ++ END building xLS\n');
            end
        end