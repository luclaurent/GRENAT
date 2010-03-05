function desc = getDescription( this )

% getDescription (SUMO)
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
%	desc = getDescription( this )
%
% Description:
%	Return a user friendly description of the model

% get degrees
[numdegrees,dendegrees] = getDegrees( this.degrees, this.freedom );

desc = sprintf( 'Rational model:\n\tBasis: %s\n\tWeights: [%s];  Flags: [%s]\n\t%d degrees of freedom\n\tMaximum degrees: [%s] over [%s]', ...
	func2str( this.baseFunctions{1} ), ...
	num2str( this.degrees.getWeights() ), ...
	num2str( this.degrees.getFlags() ), ...
	this.freedom, ...
	num2str( max( numdegrees ) ), ...
	num2str( max( dendegrees ) ) );
