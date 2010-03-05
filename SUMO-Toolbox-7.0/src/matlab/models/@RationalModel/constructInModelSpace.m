function this = constructInModelSpace( this, samples, values )

% constructInModelSpace (SUMO)
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
% Revision: $Rev: 6376 $
%
% Signature:
%	this = constructInModelSpace( this, samples, values )
%
% Description:
%	Build a rational model through the samples and values
%	Model parameters are:
%	 percentage : number of free variables as a percentage of the number
%	     of sample points
%	 degrees : a structure returning the order in which degrees of freedom
%	     are selected
%	 frequencyVariable : a special input which is treated as complex
%	     frequency, models are built slightly different in order to obtain
%	     real coefficients.

this = this.constructInModelSpace@Model(samples, values);

% Fix some variables. I'd rather do it in the constructor but then the
% number of dimensions isn't yet available
[in out] = this.getDimensions();

this.baseFunctions = cfix( this.baseFunctions, in );
this.degrees = update( this.degrees, 2 );

if this.frequencyVariable > 0
	this.baseFunctions{this.frequencyVariable} = @powerBase;
end

this = buildModel( this );
