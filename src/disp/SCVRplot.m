%% Plot SCVR (for cross validation)
%L. LAURENT -- 16/02/2012 -- luc.laurent@lecnam.net
% cf. Jones 1998

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

function SCVRplot(Zap,scvr,opt)

%% chosen bounds of the SCVR
boundSCVR=3;

% initialization
scvr=scvr(:);Zap=Zap(:);
%bound of the graph
xMin=min(Zap);
xMax=max(Zap);
yMin=min([-boundSCVR-1;scvr]);
yMax=max([boundSCVR+1;scvr]);


% points inside and outside the bounds
ixOut=find(abs(scvr)>boundSCVR);
ixIn=find(abs(scvr)<boundSCVR);

%build vector for displaying bounds
Xp=[xMin;xMax;xMax;xMin;xMin];
Yp=[boundSCVR;boundSCVR;-boundSCVR;-boundSCVR;boundSCVR];

%if options
newFig=true;
defTitle='SCVR plot';
defX='Predicted responses';
defY='SCVR';
if nargin==3
    if isfield(opt,'newfig')
        newFig=opt.newfig;
    end
    if isfield(opt,'title')
        defTitle=opt.title;
    end
    if isfield(opt,'xlabel')
        defX=opt.xlabel;
    end
    if isfield(opt,'ylabel')
        defY=opt.ylabel;
    end
    
end

%graph
if newFig
    figure;
end
hold on
fill(Xp,Yp,[0 0.9 0.99])
plot([xMin xMax],[0 0],'r','LineWidth',1.5)

plot([xMin xMax],[boundSCVR boundSCVR],'b','LineWidth',1.5,'lineStyle','--')
plot([xMin xMax],[-boundSCVR -boundSCVR],'b','LineWidth',1.5,'lineStyle','--')
% inside the bounds
plot(Zap(ixIn),scvr(ixIn),'o','MarkerEdgeColor','k','MarkerFaceColor','k','Markersize',10)
% outside the bounds
plot(Zap(ixOut),scvr(ixOut),'o','MarkerEdgeColor','r','MarkerFaceColor','r','Markersize',10)
title(defTitle)
xlabel(defX)
ylabel(defY)
axis([xMin xMax yMin yMax])
hold off

end
