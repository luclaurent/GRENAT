function Z=dsvrpred(Xp,XXX,sigma,mu,alpha_pm,lambda_pm,funKernel,dfunKernel)
ns=length(XXX);
for i=1:length(Xp)
    for j=1:ns
            psi(j,1)=funKernel(Xp(i)-XXX(j),sigma);
            dpsi(j,1)=-dfunKernel(Xp(i)-XXX(j),sigma);
    end
    pred(i)=mu+alpha_pm'*psi+lambda_pm'*dpsi;
end

Z=pred;