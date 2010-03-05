function s = update( s, samples, values )

% update (SUMO)
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
%	s = update( s, samples, values )
%
% Description:
%	 Update the model with new data without fully retraining the model.
%	 This is useful for model types that support on-line learning
%	This base class implementation simply calls construct.  It
%	is up to the model type to give a more efficient implementation

s = construct( s, samples, values );
