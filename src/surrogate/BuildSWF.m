%% Preparing data for 'Shepard Weighting Functions' surrogate model
%% L. LAURENT -- 23/11/2011 -- luc.laurent@lecnam.net

function swf=BuildSWF(sampling,resp,grad,meta)

textd='++ Type: ';
textf='';
fprintf('\n%s\n',[textd 'Shepard Weighting Functions (SWF)' textf]);

%initialization of the time counter
[tMesu,tInit]=mesu_time;

%number of sample points
nbs=size(resp,1);
%number of design variables
nbv=size(sampling,2);

%check if gradients are available
avail_grad=~isempty(grad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create vectors of sample points, responses and gradients
swf.sampling=sampling;
swf.eval=resp;
swf.grad=grad;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save data
swf.nbs=nbs;
swf.nbv=nbv;
swf.para=meta.swf_para;	%radius of the hypershere of the weighting functions
if avail_grad
    tt=sampling';
    stock=zeros(nbs*(nbv+1),1);
    ind=1:(nbs*(nbv+1));
    
    rech=mod(ind,nbv+1);
    IX=find(rech==1);
    IXX=find(rech~=1);
    
    stock(IXX)=tt(:);
    swf.sample_colon=stock;    %conditioning of the sample points for dealing with gradients
    data=stock;
    data(IX)=resp;
    data(IXX)=grad;
    swf.F=data;             %conditioning of the responses dans gradients
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determination of the parameter using CV (LOO)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mesu_time(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')

end