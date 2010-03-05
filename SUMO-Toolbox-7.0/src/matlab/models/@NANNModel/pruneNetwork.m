function s = pruneNetwork( s, samples, values )

% pruneNetwork (SUMO)
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
%	s = pruneNetwork( s, samples, values )
%
% Description:
%	Prune the network using one of the available pruning techniques

NetDef = s.network.NetDef;
W1 = s.network.W1;
W2 = s.network.W2;
trparms = settrain;
trparms = settrain(trparms,'maxiter',s.config.epochs,'infolevel',0);

switch s.config.pruneTechnique
	case 0
		% No pruning
	case 1
		% Remove small weights
		[NetDef, W1, W2] = magnitudeThreshold(NetDef, W1, W2,samples, values, s.config.threshold);
	case 2
		% Magnitude based pruning
		[thd,NSSEvec,FPEvec,deff_vec,pvec]= magnitudeprune(NetDef,W1,W2,samples,values,trparms,[s.config.retrain s.config.percentage],samples,values);
		[minfpe,index] = min(NSSEvec(pvec));
		index = pvec(index);
		[W1,W2] = netstruc(NetDef,thd,index);
	case 3
		% Optimal brain damage
		[thd,NSSEvec,FPEvec,NSSEtestvec,deff_vec,pvec]= obdprune(NetDef,W1,W2,samples,values, trparms,[s.config.retrain s.config.percentage],samples,values);
		[minfpe,index] = min(NSSEvec(pvec));
		index = pvec(index);
		[W1,W2] = netstruc(NetDef,thd,index);
	case 4
		% Optimal brain surgeon
		[thd,NSSEvec,FPEvec,NSSEtestvec,deff_vec,pvec]= obsprune(NetDef,W1,W2,samples,values, trparms,[s.config.retrain s.config.percentage],samples,values);
		[minfpe,index] = min(NSSEvec(pvec));
		index = pvec(index);
		[W1,W2] = netstruc(NetDef,thd,index);
	otherwise
		error(sprintf('Invalid prune technique %d',s.config.pruneTechnique));
			
end

% Save changes to Network
s.network.NetDef = NetDef;
s.network.W1 = W1;
s.network.W2 = W2;
