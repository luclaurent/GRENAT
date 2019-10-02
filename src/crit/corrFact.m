%% function for calculating R2 (correlation errors
%L. LAURENT   --  22/03/2010   --  luc.laurent@lecnam.net
% Correction 20/03/2012 
% -- Computation of the Pearson's correlation coefficient and adjusted correlation
% -- the squared correlation coefficient (and adjusted)
% -- the Concordance Correlation Coefficient (Rccc)
%
% Rccc: Lawrence I-Kuei Lin, "A Concordance Correlation Coefficient to
% Evaluate Reproducibility", Biometrics, Vol. 45, No. 1 (Mar., 1989), pp. 255-268
%
%Zex: "exact" values of the function obtained by simulation
%Zap: approximated values given by the surrogate model

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

function [r,radj,r2,r2adj,rccc]=corrFact(Zex,Zap)

Zex=Zex(:);Zap=Zap(:);
nv=length(Zex);
% computation of the empirical means
meanZex=mean(Zex);
meanZap=mean(Zap);

% computation of the empirical covariance
covZexZap=1/nv*sum((Zex-meanZex).*(Zap-meanZap));

% computation of the empirical variances
VZex=1/nv*sum((Zex-meanZex).^2);
VZap=1/nv*sum((Zap-meanZap).^2);

% Pearson's correlation coefficient
r=covZexZap/sqrt(VZex*VZap);
%squared correlation coefficient
r2=r^2;
%adjusted correlation coefficinet
radj=sqrt(1-(nv-1)/(nv-2)*(1-r2));
%adjusted squared correlation coefficinet
r2adj=radj^2;

%Concordance Correlation Coefficient
rccc=2*covZexZap/(VZex+VZex+(meanZex-meanZap)^2);
end
