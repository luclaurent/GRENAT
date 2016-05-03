%% function for automatic calculation of the empirical value of the hyperparameters
% L. LAURENT -- 23/02/2012 -- luc.laurent@lecnam.net

function para=RBFComputePara(samplingIn,dataRBF)

% choice of the strategy
if isfield(dataRBF.para,'type')
    type=dataRBF.para.type; %Hardy/Franke or manual
else
    type='Manu';
end
% Aniso or not
aniso=dataRBF.para.aniso;

%Nb of variables and points
np=size(samplingIn,2);
ns=size(samplingIn,1);

%depending on the chosen strategy
switch type
    case 'Hardy' %c=0.815d with d=1/N*sum di where di is the distance between the point i and the closest neighbor
        if aniso
            %compute smallest distances
            dmin=zeros(ns,np);
            for ii=1:ns
                v=repmat(samplingIn(ii,:),ns-1,1)-samplingIn([(1:ii-1) (ii+1:end)],:) ;
                d=sqrt(sum(v.^2,2));
                [~,IX]=min(d);
                dmin(ii,:)=abs(v(IX,:));
            end
        else
            %compute smallest distances
            dmin=zeros(1,ns);
            for ii=1:ns
                v=repmat(samplingIn(ii,:),ns-1,1)-samplingIn([(1:ii-1) (ii+1:end)],:) ;
                d=sqrt(sum(v.^2,2));
                dmin(ii)=min(d);
            end
        end
        
        para=0.815*1/ns*sum(dmin);
    case 'Franke'
        if aniso
            %compute smallest distances
            D=zeros(np,1);
            for ii=1:np
                D(ii)=abs(max(samplingIn(ii,:))-min(samplingIn(ii,:)));
            end
        else
            %compute smallest distances
            D=zeros(1,ns);
            for ii=1:ns
                v=repmat(samplingIn(:,ii),np,ns)-samplingIn;
                d=sqrt(sum(v.^2,2));
                D(ii)=max(d);
            end
        end
        para=1.25*1/ns*D;
        
    otherwise
        para=dataRBF.para.l.val;
end
