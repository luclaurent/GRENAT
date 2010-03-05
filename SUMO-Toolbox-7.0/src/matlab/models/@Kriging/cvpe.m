function [out dout] = cvpe( this )

% cvpe (SUMO)
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
%	[out dout] = cvpe( this )
%
% Description:
%	Cross-validated prediction error (leave-one-out)

	%% CVPE
	n = size(this.values, 1);
	cv = zeros(n, size(this.alpha,2) );

	% for CVPE
	%FFinv = inv(F'*F);
	%H = F*FFinv*F';

	% C*Ft = F
	% Removed inverse and F dep.
	FF = this.Ft' * this.C' * this.C * this.Ft;
	H = ((this.C*this.Ft) / FF)*this.Ft'*this.C';

	Cn=inv( this.C*this.C' );
	residual=this.values(this.P,:)-(this.C*this.Ft)*this.alpha; % residual
	% residual = this.C * r
	
	% OLD
	for i=1:n
		a = residual(i,:) ./ (1-H(i,i));
		tn = (residual+H(:,i)*a);
		
		Qn = Cn(i,:)*tn;
		cv(i,:) = Qn ./ Cn(i,i);
	end
	
	%
	%Yt = this.C \ this.values(this.P,:);
	%Qn = this.C' \ Yt;
	
	% NEW:
	%{
	a = residual ./ (1-diag(H));
	tn = (repmat(residual,1,n)+H.*repmat(a', n, 1));
	Qn = diag( Cn*tn );
	cv = Qn ./ diag(Cn);
%}
	
	% unscale
	cv = this.outputScaling(2.*ones(n,1),:) .* cv;
	out = (sqrt(sum(cv.^2)./n));
	
	%% Derivatives (analytical)
	dout = [];
	%{
	TODO
	% values = calculated as above a=.../H...
	if nargout > 1
		for j=1:length(dpsi)
			dpsiCurr = dpsi{j} + dpsi{j}';
			rj = -Cn * dpsiCurr * Cn * values;
			
			dout(1,j) = 0;
			for i=1:n
				sji = Cn(:,i)' * dpsiCurr * Cn(:,i);
				
				dout(1,j) = 1 + 1;
			end
			
		end
	end
	%}
	
end
