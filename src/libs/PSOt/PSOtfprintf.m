%% function for printing information on the command window (based on fprintf)
%% L. LAURENT -- 26/09/2018 -- luc.laurent@lecnam.net

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


function nbT = PSOtfprintf(varargin)

%adding text in front of the original text
txtAdd='PSOt';

%check if the first argument is a double (corresponding to a file id)
if isa(varargin{1},'double')
    %argOk=varargin{2:end};
    %use the classical fprintf function
    nbT=fprintf(varargin{:});
else
    argOk=varargin;   
    
    %convert all inputs to a string
    str = sprintf(argOk{:});
    
    %find new lines
    strSplit=regexp(str,'\n','split');
    
    % display text and adding new keyword
    nbT=0;
    for itS=1:numel(strSplit)
        if itS==numel(strSplit)&&isempty(strSplit{itS})
        else
            txtD=[ txtAdd ' | ' strSplit{itS}];
            nbytes=fprintf(txtD);
            nbT=nbT+nbytes;
        end
        if itS<numel(strSplit)
            nbytes=fprintf('\n');
            nbT=nbT+nbytes;
        end
    end
end
end
