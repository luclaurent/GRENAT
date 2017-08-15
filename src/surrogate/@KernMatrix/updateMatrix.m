%function for updating the
function [KK,KKd,KKdd]=updateMatrix(obj,newS)
%store the new sample points
if nargin>1;if ~isempty(newS);obj.addSample(newS); end, end
%if nothing have been already built
if obj.requireRun
    obj.requireUpdate=false;
    obj.sampling=[obj.sampling;obj.newSample];
    obj.newSample=[];
    if nargout==1
        KK=obj.buildMatrix;
    else
        [KK,KKd,KKdd]=obj.buildMatrix;
    end
end
if obj.requireUpdate
    %calculation of the new distances and indices
    obj.computeNewIX();
    obj.computeNewDist();
    obj.requireIndices=true;
    %
    oldNs=obj.nS;
    newNs=obj.NnS;
    np=obj.nP;
    %
    dN=obj.distN;
    dNO=obj.distNO;
    distM=[dNO;dN];
    nbNO=size(dNO,1);
    nbN=size(dN,1);
    %
    fctK=obj.fctKern;
    pVl=obj.paraVal;
    %depending on the number of output arguments
    if nargout>1||obj.computeD
        obj.computeD=true;
        %if the first and second derivatives matrices have not been
        %calculated before, we calculate it yet
        if isempty(obj.KKd)
            obj.sampling=[obj.sampling;newS];
            obj.requireRun=true;
            [KK,KKd,KKdd]=obj.buildMatrix;
        else
            if obj.parallelOk
                %%REWRITE
                %                         %%%%%% PARALLEL %%%%%%
                %                         %various parts of the Kernel Matrix
                %                         KKON=zeros(oldNs,newNs);
                %                         KKN=zeros(newNs,newNs);
                %                         KKUa=cell(1,ns);
                %                         KKUi=cell(1,ns);
                %                         %%
                %                         %
                %                         parfor ii=1:ns
                %                             %Building by column & evaluation of the Kernel function
                %                             [ev,dev,ddev]=multiKernel(fctK,distM(:,ii),pVl);
                %                             %classical part
                %                             KK(:,ii)=ev;
                %                             %part of the first derivatives
                %                             KKa{ii}=dev;
                %                             %part of the second derivatives
                %                             KKi{ii}=reshape(ddev,np,ns*np);
                %                         end
                %                         %Reordering matrices
                %                         KKd=horzcat(KKa{:});
                %                         KKdd=vertcat(KKi{:});
            else
                %evaluation of the kernel function for all inter-points
                [ev,dev,ddev]=multiKernel(fctK,distM,pVl);
                %various parts of the kernel Matrix
                KKNO=zeros(oldNs,newNs);
                KKN=zeros(newNs,newNs);
                %classical part
                KKNO(obj.NiX.matrixNO)=ev(1:nbNO);
                KKN(obj.NiX.matrixN)=ev(nbNO+(1:nbN));
                %correction of the new sample point kernel matrix
                KKN=KKN+KKN'-eye(newNs);
                %assembly of the updated kernel matrix
                KK=[obj.KK KKNO;KKNO' KKN];
                obj.KK=KK;
                %
                %build the new cross kernel matrix (1st
                %derivatives)
                KKdN=zeros(newNs,newNs*np);
                %depending on the number of new sample points
                if newNs==1
                    %old-new part
                    KKdON=-dev(1:end-1,:);
                    %new part
                    KKdN=-dev(end,:);
                else
                    %old-new part
                    KKdON=-cell2mat(mat2cell(dev(1:newNs*oldNs,:),oldNs*ones(1,newNs),np)');
                    %new part by "triangular" matrix
                    devT=dev(newNs*oldNs+1:end,:)';
                    KKdN(obj.NiX.matrixAb)=devT(:);
                    KKdNT=reshape(permute(reshape(KKdN',[np,newNs,newNs]),[2,1,3]),[newNs newNs*np 1]);
                    %
                    KKdN=KKdN-KKdNT;
                end
                %new-old part
                KKdNO=-reshape(permute(reshape(KKdON',[np,newNs,oldNs]),[2,1,3]),[newNs,oldNs*np,1]);
                %build the full new cross kernel matrix (1st
                %derivatives)
                KKd=[obj.KKd KKdON;KKdNO KKdN];
                obj.KKd=KKd;
                %
                %build the new cross kernel matrix of second
                %derivatives
                %old-new part
                rD=reshape(ddev(:,:,1:oldNs*newNs),np,np,oldNs,newNs);
                cellD=mat2cell(rD,np,np,ones(1,oldNs),ones(1,newNs));
                KKddNO=cell2mat(reshape(cellD,oldNs,newNs));
                %new part by "triangular" matrix
                ddevT=ddev(:,:,oldNs*newNs+1:end);
                %depending on the number of new sample points
                if newNs==1
                    KKddN=ddevT;
                else
                    KKddN=zeros(newNs*np,newNs*np);
                    KKddN(obj.NiX.matrixI)=ddevT(:);
                    %extract diagonal (process for avoiding duplicate terms)
                    diago=0;   % //!!\\ corrections possible here
                    valDiag=spdiags(KKddN,diago);
                    KKddN=KKddN+KKddN'-spdiags(valDiag,diago,zeros(size(KKddN))); %correction of the duplicated terms on the diagonal
                end
                %build the full new cross kernel matrix (2nd
                %derivatives)
                KKdd=[obj.KKdd KKddNO;KKddNO' KKddN];
                obj.KKdd=KKdd;
            end
        end
    else
        if obj.parallelOk
            %REWRITE
            %                         %%%%%% PARALLEL %%%%%%
            %                         %classical kernel matrix by column
            %                         KK=zeros(ns,ns);
            %                         parfor ii=1:ns
            %                             % evaluate kernel function
            %                             [ev]=multiKernel(fctK,dC(:,ii),pVl);
            %                             % kernel matrix by column
            %                             KK(:,ii)=ev;
            %                         end
        else
            %classical kernel matrix (lower triangular matrix)
            %without diagonal
            KKNO=zeros(oldNs,newNs);
            KKN=zeros(newNs,newNs);
            % evaluate kernel function
            [ev]=multiKernel(fctK,distM,pVl);
            %classical part
            error('')
            KKNO(obj.NiX.matrixNO)=ev(1:nbNO);
            KKN(obj.NiX.matrixN)=ev(nbNO+(1:nbN));
            %correction of the new sample point kernel matrix
            KKN=KKN+KKN'-eye(newNs);
            %assembly of the updated kernel matrix
            KK=[obj.KK KKNO;KKNO' KKN];
            obj.KK=KK;
        end
    end
    obj.requireUpdate=false;
    obj.sampling=[obj.sampling;obj.newSample];
    obj.newSample=[];
else
    %if already computed then load it
    KK=obj.KK;
    KKd=obj.KKd;
    KKdd=obj.KKdd;
end
end