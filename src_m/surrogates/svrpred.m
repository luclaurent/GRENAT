function Z=svrpred(Xp,XXX,sigma,mu,alpha_pm,funKernel)
ns=length(XXX);
for i=1:length(Xp)
    for j=1:ns
            psi(j,1)=funKernel(Xp(i),XXX(j),sigma);
    end
    pred(i)=mu+alpha_pm'*psi;
end

Z=pred;