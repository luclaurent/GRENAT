%% exportation of the functions in 1D for plotting using pgfplots

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