%% check input data for finding missing information
%% L. LAURENT -- 12/06/2012 -- luc.laurent@lecnam.net

function [ret]=CheckInputData(sampling,resp,grad)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(' >> Check missing data \n');

%number of variables
np=size(sampling,2);
%number of sample points
ns=size(sampling,1);
emptyGrad=isempty(grad);

%look for missing data in responses
missResp=isnan(resp);
nbMissResp=sum(missResp);
ixMissResp=find(missResp==1);
ixAvailResp=find(missResp==0);
if nbMissResp==ns;missRespAl=true;else missRespAl=false;end

%look for missing data in gradients
if ~emptyGrad
    %classical matrix of gradients
    missGrad=isnan(grad);
    nbMissGrad=sum(missGrad(:));
    [r,c]=find(missGrad==1);
    ixMissGrad=[r c];
    [r,c]=find(missGrad==0);
    ixAvailGrad=[r c];
    [ix]=find(missGrad==1);
    ixMissGradLine=ix;
    [ix]=find(missGrad==0);
    ixAvailGradLine=ix;
    %gradients from surrogate model
    missGradT=isnan(grad');
    [r,c]=find(missGradT==1);
    ixMissGradT=[r c];
    [r,c]=find(missGradT==0);
    ixAvailGradT=[r c];
    [ix]=find(missGradT==1);
    ixMissGradtLine=ix;
    [ix]=find(missGradT==0);
    ixAvailGradTLine=ix;
    if nbMissGrad==ns*np;missGradAll=true;else missGradAll=false;end
else
    nbMissGrad=0;
    missGrad=false;
end


%display information
if nbMissResp==0&&nbMissGrad==0
    fprintf('>>> No missing data\n');
end

if nbMissResp~=0
    fprintf('>>> Missing response(s) at point(s):\n')
    for ii=1:nbMissResp
        num_pts=ixMissResp(ii);
        fprintf(' n%s %i (%4.2f',char(176),num_pts,sampling(num_pts,1));
        if np>1;fprintf(',%4.2f',sampling(num_pts,2:end));end
        fprintf(')\n');
    end
end
if ~emptyGrad
    if nbMissGrad~=0
        fprintf('>>> Missing gradient(s) at point(s):\n')
        keyboard
        for ii=1:nbMissGrad
            num_pts=ixMissGrad(ii,1);
            component=ixMissGrad(ii,2);
            fprintf(' n%s %i (%4.2f',char(176),num_pts,sampling(num_pts,1));
            if np>1;fprintf(',%4.2f',sampling(num_pts,2:end));end
            fprintf(')');
            fprintf('  component: %i\n',component)
        end
        fprintf('----------------\n')
    end
end

%extract informations
if any(missResp)
    ret.resp.on=any(missResp);
    ret.resp.mask=missResp;
    ret.resp.nb=nbMissResp;
    ret.resp.ixMiss=ixMissResp;
    ret.resp.ixAvail=ixAvailResp;
    ret.resp.all=missRespAl;
else
    ret.resp.on=false;
    ret.resp.nb=0;
    ret.resp.all=false;
end

if any(missGrad(:))
    ret.grad.on=any(missGrad(:));
    ret.grad.mask=missGrad;
    ret.grad.nb=nbMissGrad;
    ret.grad.ixMiss=ixMissGrad;
    ret.grad.ixMissLine=ixMissGradLine;
    ret.grad.ixAvailLine=ixAvailGradLine;
    ret.grad.ixAvail=ixAvailGrad;
    ret.grad.ixtMiss=ixMissGradT;
    ret.grad.ixtMissLine=ixMissGradtLine;
    ret.grad.ixtAvailLine=ixAvailGradTLine;
    ret.grad.ixtAvail=ixAvailGradT;
    ret.grad.all=missGradAll;
else
    ret.grad.on=false;
    ret.grad.nb=0;
    ret.grad.all=false;
end