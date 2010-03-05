#Piston slap noise data



##### data ###########


ex<-read.table("Piston slap noise data.txt", h=T)
attach(ex)
n<-12 
p=6

x=as.matrix(ex[,1:6])
y=ex[,7]
for(i in 1:6)
x[,i]=1+2/(max(x[,i])-min(x[,i]))*(x[,i]-min(x[,i]))


x1l<-(x[,1]-2)*sqrt(3/2)
x1q<-(3*(x[,1]-2)^2-2)/sqrt(2)
x2l<-(x[,2]-2)*sqrt(3/2)
x2q<-(3*(x[,2]-2)^2-2)/sqrt(2)
x3l<-(x[,3]-2)*sqrt(3/2)
x3q<-(3*(x[,3]-2)^2-2)/sqrt(2)
x4l<-(x[,4]-2)*sqrt(3/2)
x4q<-(3*(x[,4]-2)^2-2)/sqrt(2)
x5l<-(x[,5]-2)*sqrt(3/2)
x5q<-(3*(x[,5]-2)^2-2)/sqrt(2)
x6l<-(x[,6]-2)*sqrt(3/2)
x6q<-(3*(x[,6]-2)^2-2)/sqrt(2)

##### U matrix #################
ex1=data.frame(cbind(x1l,x1q,x2l,x2q,x3l,x3q,x4l,x4q,x5l,x5q,x6l,x6q))
U<-model.matrix(lm(y~.^2,data=ex1))
U1<-data.frame(U)
U<-U[,-c(14,35,52,65,74,79)] 
U1<-data.frame(U)
num<-dim(U1)[2]    #### faster version



PH=diag(1,n,n)
psiD=function(theta)
{
  for(i in 1:(n-1))
  {
     for(j in (i+1):n)
     {
      PH[i,j]<-exp(-sum(theta*(x[i,]-x[j,])^2))
      PH[j,i]=PH[i,j]
     }
  }
  return(PH)
}


F<-matrix(nrow=n,rep(1,n))
H=F%*%solve(t(F)%*%F)%*%t(F)
F
y
mu=solve(t(F)%*%F)%*%t(F)%*%y
cv=numeric(n)
cvpe=function(theta)
{
 Q=solve(psiD(theta))
 e=y-F%*%mu
 for(i in 1:n)
 {
  a=e[i]/(1-H[i,i])
  cv[i]=Q[i,]%*%(e+a*H[,i])/Q[i,i]
 }
 return(sqrt(sum(cv^2)/n))
}

 

##### Find thetahat by MLE ###############
 
lik=function(theta)
{
  P=psiD(theta)
  Pinv=solve(P)
  mu<-solve(t(F)%*%Pinv%*%F)%*%t(F)%*%Pinv%*%y
  tau2<-(1/n)*t(y-F%*%mu)%*%Pinv%*%(y-F%*%mu)
  minfun<-n/2+n/2*log(2*pi)+n/2*log(tau2)+1/2*log(det(P))
  return(minfun)
}

INI<-rep(1,p)
op<-optim(INI,lik,lower=rep(.01,p),upper=rep(5,p))

thetahat=op$par
CVPE<-cvpe(thetahat)
 
####### Variable selection #########
######### R matrix ##############

R=function(theta)
{
rho=exp(-theta)
rl<-(3-3*rho^4)/(3+4*rho+2*rho^4)
rq<-(3-4*rho+rho^4)/(3+4*rho+2*rho^4)
RM=diag(c(model.matrix(lm(1~(rl[1]+rq[1]+rl[2]+rq[2]+rl[3]+rq[3]+rl[4]+rq[4]+rl[5]+rq[5]+rl[6]+rq[6])^2))))
RM<-RM[-c(14,35,52,65,74,79),-c(14,35,52,65,74,79)] 
return(RM)
}
##################
betahat=function(theta) 
{ 
  mu=solve(t(F)%*%F)%*%t(F)%*%y
  betahat<-R(theta)%*%t(U)%*%solve(psiD(theta))%*%(y-F%*%mu)      
  return(betahat)
}

one<-matrix(ncol=1,rep(1,n))

b=abs(betahat(thetahat))
names(b)<-names(U1)
u<-qnorm(((num-1)+1:(num-1))/(2*(num-1)+1))
plot(u,sort((b[2:num])),xlab="half-normal quantiles", ylab=expression(t[i]),main="basyian forward selection",type="n")
text(u,sort((b[2:num])),names(sort((b[2:num]))))

####### estimate theta again ######## 

F<-matrix(ncol=4,c(one,x1l,x1l*x6l,x1q*x6l))
H=F%*%solve(t(F)%*%F)%*%t(F)
mu=solve(t(F)%*%F)%*%t(F)%*%y
INI<-rep(1,p)
op<-optim(INI,lik,lower=rep(.01,p),upper=rep(5,p))
thetahat=op$par 

######  estimate parameters in BK model ##
P=psiD(thetahat)
Pinv=solve(P)
mu<-solve(t(F)%*%Pinv%*%F)%*%t(F)%*%Pinv%*%y  