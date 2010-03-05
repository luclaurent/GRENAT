function beta = posteriorBeta(this, R, U)

% posteriorBeta (SUMO)
%
%     This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     and you can redistribute it and/or modify it under the terms of the
%     GNU Affero General Public License version 3 as published by the
%     Free Software Foundation.  With the additional provision that a commercial
%     license must be purchased if the SUMO Toolbox is used, modified, or extended
%     in a commercial setting. For details see the included LICENSE.txt file.
%     When referring to the SUMO-Toolbox please make reference to the corresponding
%     publication.
%
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev$
%
% Signature:
%	beta = posteriorBeta(this, R, U)
%
% Description:
%	Calculates beta coefficients of poly
%	Parameters: ModelInfo
%
%	beta is stochastic process
%	with process mean 0 and
%	  process variance tau2*R
%	posterior:
%	mean = R*U'*inv(psi)
%	variance = tau2*R - tau4/sigma2*R*U'*inv(psiD)*U*

	
    %betahat<-R(theta)%*%t(U)%*%solve(psiD(theta))%*%(y-F%*%mu) % (1)
	%residual = (this.values-F*this.alpha); % (2)
	Yt = this.C \ this.values(this.P,:);
	
	
	
	%psi = full(this.C*this.C');
	%old = inv(psi)*residual
    
    % forward and back substitution
    % inv(CC') * residual
    % inv(C')*inv(C)*residual
    % inv(C')* (C \ residual)
    % C' \ (C \ residual)
    % Ct = this.C \ residual; % (1)
	Ct = Yt - this.Ft*this.alpha; % (2)
    fast_acc = this.C' \ Ct;
    
    beta = R*U'*fast_acc;
    beta = abs(beta);
    
    % variance on beta
    if 1
        % return standardized coefficient
        % tau2*R - tau4/sigma2*R*U'*inv(psiD)*U*
        
        % aprox.
        %sigma2 = R - R* U' * inv( this.C * this.C' ) * U * R;
        
        %beta = beta ./ abs( diag( sigma2 ) );
    
    end
end
