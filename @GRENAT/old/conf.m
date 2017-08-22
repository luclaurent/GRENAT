%define properties
function conf(obj,varargin)
%list properties
listProp=properties(obj);
okConf=false;
%if a input variable is specified
if nargin>2
    %if the number of input argument is even
    if  mod(nargin-1,2)==0
        %along the argument
        for itV=1:2:nargin-1
            %extract keyword and associated value
            keyW=varargin{itV};
            keyV=varargin{itV+1};
            %if the first argument is a string
            if isa(varargin{1},'char')
                %check if the keyword is acceptable
                if ismember(keyW,listProp)
                    okConf=true;
                    obj.(keyW)=keyV;
                else
                    fprintf('>> Wrong keyword ''%s''\n',keyW);
                end
            end
        end
    end
    if ~okConf
        Gfprintf('\nWrong syntax used for conf method\n');
        Gfprintf('use: conf(''key1'',val1,''key2'',val2...)\n');
        Gfprintf('\nList of the available keywords:\n');
        dispTableTwoColumnsStruct(listProp,obj.infoProp);
    end
else
    fprintf('Current configuration\n');
    disp(obj);
end
end