%% Method of GRENAT class
% L. LAURENT -- 26/06/2016 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Define properties
% INPUTS:
% - varargin: use for specifying the properties of GRENAT 
% (syntax 'prop1',value1,'prop2',valueé,...)
% OUTPUTS:
% - none

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