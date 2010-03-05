function m = createModel(this,individual);

% createModel (SUMO)
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
%	m = createModel(this,individual);
%
% Description:
%	Generate a Rational Model object for the given individual

[ni no] = this.getDimensions();

if(~exist('individual','var') || isempty(individual))

  % TODO return a random model, should really regard the config
  m = this.createRandomModel();

elseif(isa(individual,'Model'))

   m = individual;

else
  % Assume individual is a vector as follows [percent weights flags]
  perc = individual(1);
  w = individual(2:2+ni-1);
  fl = individual(2+ni:end);

  % ensure bounds are respected
  perc = truncate(perc,this.percent.lower,this.percent.upper);
  for i=1:length(w)
    w(i) = truncate(fix(w(i)),this.weight.lower(i),this.weight.upper(i));
  end

  % ensure flags are always 0 or 1
  fl = fl > (this.rational/100);

  m = RationalModel( perc, w, fl, this.frequencyVariable, this.baseFunction, 0 );

end
