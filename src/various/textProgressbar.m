%% Text progess bar
% L. LAURENT -- 05/10/2018 -- luc.laurent@lecnam.net

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

%status bar
function textProgressbar(it,itFull,nbitemIn,charItemIn,charBoundIn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%default values
charItemDefault='.';
charBoundDefault=['[',']'];
nbItemDefault=10;
textDone='Done';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load specific values
checkItem=false;
checkCharItem=false;
checkBound=false;
if nargin>2
    if ~isempty(nbitemIn)
        checkItem=true;
    end
end
%
if checkItem
    nbItel=nbitemIn;
else
    nbItem=nbItemDefault;
end
%
if nargin>3
    if ~isempty(charItemIn)
        checkCharItem=true;
    end
end
%
if checkCharItem
    charItem=charItemIn;
else
    charItem=charItemDefault;
end
%
if nargin>4
    if ~isempty(charBoundIn)
        if numel(charBoundIn)==2
            checkBound=true;
        end
    end
end
%
if checkBound
    charBound=charBoundIn;
else
    charBound=charBoundDefault;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%step ratio
stepRatio=it/itFull;
% compute number of item to show
nbItemShow=floor(nbItem*stepRatio);
%list of items
stringItem=repmat(charItem,1,nbItemShow);
stringItem=[stringItem repmat(' ',1,nbItem-nbItemShow)];
%text displayed
showText=sprintf('%s%s%s',charBound(1),stringItem,charBound(2));
%erase previous display
eraseText=repmat('\b',1,nbItem+numel(charBound(1))+numel(charBound(2)));
% erase text only if it is not the first display
if it>1
    fprintf(eraseText);
end
%show the progress bar
if it==1
    Gfprintf(showText);
else
    fprintf(showText);
end
%show Done et newline at the last call
if it==itFull
    fprintf(' %s\n',textDone);
end
end