function [this err residual sigma2] = updateRegression( this, F )

% updateRegression (SUMO)
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
%	[this err residual sigma2] = updateRegression( this, F )
%
% Description:
%	Updates regression part

	err = [];
	
    %% Get least squares solution

    % decorrelation transformation:
    % Yt - Ft*coeff = inv(C)Y - inv(C)F*coeff
    % so Ft = inv(C)F <=> C Ft = F -> solve for Ft

	% Forward substitution
	Ft = this.C \ F(this.P,:); % T1

    % Bayesian Linear regression:
    %tmp = inv(this.F'*this.F + A)*(this.F'*this.F * betaPrior + A*betaPriorMean

    % Ft can now be ill-conditioned -> QR factorisation of Ft = QG'
    [Q R] = qr(Ft,0);
    if  rcond(R) < 1e-10
		% Check   F  
		err = 'F/Ft is ill-conditioned.';
		return;
    end

    % Now we know Ft is good, compute Yt
    % so Yt = inv(C)Y <=> C Yt = Y -> solve for Yt
    Yt = this.C \ this.values(this.P,:);
	
    % transformation is done, now fit it:
    % Q is unitary = orthogonal for real values -> inv(Q) = Q'
    alpha = R \ (Q'*Yt); % polynomial coefficients

	%residual2 = this.values - this.F * alpha % simple
    %residual2 = C * residual; % take correlation into account for real variance
    % sigma2 = (residual' * T2) ./ n; % simple

	% compute variance
    residual = Yt - Ft*alpha;
    sigma2 = sum(residual.^2) / size(this.values, 1);	% keep
	
	%% keep
	this.alpha = alpha;
	
	% inv(C11') * inv(C) * values or (inv(C)*residual)
	this.gamma = this.C(1:this.rank,1:this.rank)' \ residual;
	
	this.Ft = Ft;
	this.R = R;
	this.sigma2 = this.outputScaling(2,:).^2.*sigma2; % unscaled
end
