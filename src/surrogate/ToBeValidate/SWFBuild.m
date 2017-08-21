%% Preparing data for 'Shepard Weighting Functions' surrogate model
%% L. LAURENT -- 23/11/2011 -- luc.laurent@lecnam.net

function swf=BuildSWF(samplingIn,respIn,gradIn,metaData)

textd='++ Type: ';
textf='';
fprintf('\n%s\n',[textd 'Shepard Weighting Functions (SWF)' textf]);

%initialization of the time counter
[tMesu,tInit]=mesu_time;

%number of sample points
ns=size(respIn,1);
%number of design variables
np=size(samplingIn,2);

%check if gradients are available
availGrad=~isempty(gradIn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create vectors of sample points, responses and gradients
swf.sampling=samplingIn;
swf.eval=respIn;
swf.grad=gradIn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save data
swf.ns=ns;
swf.np=np;
swf.para=metaData.swf_para;	%radius of the hypershere of the weighting functions
if availGrad
    tt=samplingIn';
    stock=zeros(ns*(np+1),1);
    ind=1:(ns*(np+1));
    
    rech=mod(ind,np+1);
    IX=find(rech==1);
    IXX=find(rech~=1);
    
    stock(IXX)=tt(:);
    swf.sample_colon=stock;    %conditioning of the sample points for dealing with gradients
    data=stock;
    data(IX)=respIn;
    data(IXX)=gradIn;
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
