%% check input data for finding missing information
%% L. LAURENT -- 12/06/2012 -- luc.laurent@lecnam.net

function [ret]=CheckInputData(sampling,resp,grad)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(' >> Check missing data \n');

%number of variables
nb_var=size(sampling,2);
%number of sample points
nb_val=size(sampling,1);
emptygrad=isempty(grad);

%look for missing data in responses
miss_resp=isnan(resp);
nb_miss_resp=sum(miss_resp);
ix_miss_resp=find(miss_resp==1);
ix_avail_resp=find(miss_resp==0);
if nb_miss_resp==nb_val;miss_resp_all=true;else miss_resp_all=false;end

%look for missing data in gradients
if ~emptygrad
    %classical matrix of gradients
    miss_grad=isnan(grad);
    nb_miss_grad=sum(miss_grad(:));
    [r,c]=find(miss_grad==1);
    ix_miss_grad=[r c];
    [r,c]=find(miss_grad==0);
    ix_avail_grad=[r c];
    [ix]=find(miss_grad==1);
    ix_miss_grad_line=ix;
    [ix]=find(miss_grad==0);
    ix_avail_grad_line=ix;
    %gradients from surrogate model
    miss_gradt=isnan(grad');
    [r,c]=find(miss_gradt==1);
    ix_miss_gradt=[r c];
    [r,c]=find(miss_gradt==0);
    ix_avail_gradt=[r c];
    [ix]=find(miss_gradt==1);
    ix_miss_gradt_line=ix;
    [ix]=find(miss_gradt==0);
    ix_avail_gradt_line=ix;
    if nb_miss_grad==nb_val*nb_var;miss_grad_all=true;else miss_grad_all=false;end
else
    nb_miss_grad=0;
    miss_grad=false;
end


%display information
if nb_miss_resp==0&&nb_miss_grad==0
    fprintf('>>> No missing data\n');
end

if nb_miss_resp~=0
    fprintf('>>> Missing response(s) at point(s):\n')
    for ii=1:nb_miss_resp
        num_pts=ix_miss_resp(ii);
        fprintf(' n%s %i (%4.2f',char(176),num_pts,sampling(num_pts,1));
        if nb_var>1;fprintf(',%4.2f',sampling(num_pts,2:end));end
        fprintf(')\n');
    end
end
if ~emptygrad
    if nb_miss_grad~=0
        fprintf('>>> Missing gradient(s) at point(s):\n')
        for ii=1:nb_miss_grad
            num_pts=ix_miss_grad(ii,1);
            component=ix_miss_grad(ii,2);
            fprintf(' n%s %i (%4.2f',char(176),num_pts,sampling(num_pts,1));
            if nb_var>1;fprintf(',%4.2f',sampling(num_pts,2:end));end
            fprintf(')');
            fprintf('  component: %i\n',component)
        end
        fprintf('----------------\n')
    end
end

%extract informations
if any(miss_resp)
    ret.resp.on=any(miss_resp);
    ret.resp.masque=miss_resp;
    ret.resp.nb=nb_miss_resp;
    ret.resp.ix_manq=ix_miss_resp;
    ret.resp.ix_dispo=ix_avail_resp;
    ret.resp.all=miss_resp_all;
else
    ret.resp.on=false;
    ret.resp.nb=0;
    ret.resp.all=false;
end

if any(miss_grad(:))
    ret.grad.on=any(miss_grad(:));
    ret.grad.mask=miss_grad;
    ret.grad.nb=nb_miss_grad;
    ret.grad.ix_manq=ix_miss_grad;
    ret.grad.ix_manq_line=ix_miss_grad_line;
    ret.grad.ix_avail_line=ix_avail_grad_line;
    ret.grad.ix_avail=ix_avail_grad;
    ret.grad.ixt_manq=ix_miss_gradt;
    ret.grad.ixt_manq_line=ix_miss_gradt_line;
    ret.grad.ixt_avail_line=ix_avail_gradt_line;
    ret.grad.ixt_avail=ix_avail_gradt;
    ret.grad.all=miss_grad_all;
else
    ret.grad.on=false;
    ret.grad.nb=0;
    ret.grad.all=false;
end