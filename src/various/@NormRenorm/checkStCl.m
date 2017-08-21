%% function for checking and extracting the content of a class or a struct
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

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

%INPUT :
% - in: class or struct that contains statistics data
%OUTPUTS:
% - statVal: structure that contains the statistics data

function [statVal]=checkStCl(in)
%load the specific function
switch class(in)
    case 'class'
        fun='ismethod';
    case 'struct'
        fun='isfield';
end
% initialize variables
meanN=[];stdN=[];
meanR=[];stdR=[];
meanS=[];stdS=[];
%
if feval(fun,in,'mean')&&feval(fun,in,'std')
    meanN=in.mean;
    stdN=in.std;
end
%
if feval(fun,in,'meanC')&&feval(fun,in,'stdC')
    meanN=in.meanN;
    stdN=in.stdN;
end
%
if feval(fun,in,'meanS')&&feval(fun,in,'stdS')
    meanS=in.meanS;
    stdS=in.stdS;
end
%
if feval(fun,in,'meanR')&&feval(fun,in,'stdR')
    meanR=in.meanR;
    stdR=in.stdR;
end
%
if feval(fun,in,'resp')
    if feval(fun,in.resp,'mean')&&feval(fun,in.resp,'std')
        meanR=in.resp.mean;
        stdR=in.resp.std;
    end
end
%
if feval(fun,in,'sampling')
    if feval(fun,in.sampling,'mean')&&feval(fun,in.sampling,'std')
        meanS=in.sampling.mean;
        stdS=in.sampling.std;
    end
end
statVal.meanN=meanN;
statVal.stdN=stdN;
statVal.meanS=meanS;
statVal.stdS=stdS;
statVal.meanR=meanR;
statVal.stdR=stdR;
end
