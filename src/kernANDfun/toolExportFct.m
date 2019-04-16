%% exportation of the functions in 1D for plotting using pgfplots

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

fct_kern='sexp';
nbval=100;
xx=linspace(-2,2,nbval);
paramatern=0.8;
paranu=[1.1  1.5 5]; %matern
paraval=1./[0.4 0.6 0.9];%matern32 et matren52


nbparav=numel(paranu);
G=zeros(nbval,nbparav);
dG=zeros(nbval,nbparav);
ddG=zeros(nbval,nbparav);

for it=1:nbparav
    if strcmp(fct_kern,'matern')
        [G(:,it),dG(:,it),ddG(:,it)]=feval(fct_kern,xx',paramatern,paranu(it));
    else
       [G(:,it),dG(:,it),ddG(:,it)]=feval(fct_kern,xx',paraval(it));
    end
end

figure;
plot(xx,G(:,1),'r','LineWidth',2)
hold on
for it=2:nbparav
plot(xx,G(:,it),'b')
end
hold off

figure;
plot(xx,dG(:,1),'r','LineWidth',2)
hold on
for it=2:nbparav
plot(xx,dG(:,it),'b')
end
hold off

figure;
plot(xx,ddG(:,1),'r','LineWidth',2)
hold on
for it=2:nbparav
plot(xx,ddG(:,it),'b')
end
hold off

data=[xx' G dG ddG];
save([fct_kern '_data.dat'],'data','-ASCII');
