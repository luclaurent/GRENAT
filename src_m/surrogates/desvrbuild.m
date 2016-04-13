
function [alpha_pm,lambda_pm,sv_i,mu,e]=desvrbuild(XXX,YYY,dYYY,sigma,nu,nuk,C,Ck,xi,taui,funKernel,dfunKernel,ddfunKernel)

ns=length(XXX);

PsiM=zeros(ns,ns);
for j=1:ns
    for i=1:ns
        PsiM(i,j)=funKernel(XXX(i)-XXX(j),sigma);
    end
end
PsiDoM=zeros(ns,ns);
for j=1:ns
    for i=1:ns
        PsiDoM(i,j)=-dfunKernel(XXX(i)-XXX(j),sigma);
    end
end
PsiDDoM=zeros(ns,ns);
for j=1:ns
    for i=1:ns
        PsiDDoM(i,j)=-ddfunKernel(XXX(i)-XXX(j),sigma);
    end
end

Psi=[PsiM -PsiM;-PsiM PsiM];
PsiDo=[PsiDoM -PsiDoM;-PsiDoM PsiDoM];
PsiDDo=[PsiDDoM -PsiDDoM;-PsiDDoM PsiDDoM];
PsiT=[Psi PsiDo;PsiDo' PsiDDo'];

c=[-YYY;YYY;-dYYY;dYYY];

lb=zeros(4*ns,1);
ub=[C/ns*ones(2*ns,1);Ck/ns*ones(2*ns,1)];

x0=zeros(2*ns,1);

Aeq=[ones(1,ns) -ones(1,ns) zeros(1,ns) zeros(1,ns)];
beq=0;

%pour nu-SVR
A=eye(4*ns);
b=[C*nu*ones(1,ns) C*nu*ones(1,ns) Ck*nuk*ones(1,ns) Ck*nuk*ones(1,ns)];


opts = optimoptions('quadprog','Diagnostics','off','Display','iter');
alphalambda=quadprog(PsiT,c,A,b,Aeq,beq,lb,ub,x0,opts);

alpha=alphalambda(1:2*ns);
lambda=alphalambda(2*ns+1:4*ns);

alpha_pm=alpha(1:ns)-alpha(ns+1:2*ns);
lambda_pm=lambda(1:ns)-lambda(ns+1:2*ns);

sv_i=find(abs(alpha_pm)>xi);
sv_di=find(abs(lambda_pm)>taui);

[sv_mid_ap,sv_mid_ap_i]=min(abs(abs(alpha(1:ns))-(C/(2*ns))));
[sv_mid_am,sv_mid_am_i]=min(abs(abs(alpha(ns+1:2*ns))-(C/(2*ns))));
[sv_midd_lp,sv_midd_lp_i]=min(abs(abs(lambda(1:ns))-(Ck/(2*ns))));
[sv_midd_lm,sv_midd_lm_i]=min(abs(abs(lambda(ns+1:2*ns))-(Ck/(2*ns))));


e=0.5*(YYY(sv_mid_ap_i)-YYY(sv_mid_am_i)...
    -alpha_pm(sv_i)'*Psi(sv_i,sv_mid_ap_i)...
    -lambda_pm(sv_i)'*PsiDo(sv_mid_ap_i,sv_i)'...
    +alpha_pm(sv_i)'*Psi(sv_i,sv_mid_am_i))...
    +lambda_pm(sv_i)'*PsiDo(sv_mid_am_i,sv_i)';

mu=YYY(sv_mid_ap_i)-e*sign(alpha_pm(sv_mid_ap_i))...
    -alpha_pm(sv_i)'*Psi(sv_i,sv_mid_ap_i)...
    -lambda_pm(sv_i)'*PsiDo(sv_mid_ap_i,sv_i)';



%keyboard












