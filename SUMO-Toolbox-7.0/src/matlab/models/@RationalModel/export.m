function string = export( this, file )

% export (SUMO)
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
%	string = export( this, file )
%
% Description:
%	Export to C function

[inDim outDim] = getDimensions(this);

[numdegrees,dendegrees] = getDegrees( this.degrees, this.freedom );

mxd = max(numdegrees,[],1);
if this.frequencyVariable ~= 0
	mxd(this.frequencyVariable) = min(mxd) - 1;
end
order = sortrows( [mxd.' (1:inDim).'] );
order = order(:,2);

complex = ~isreal( this.numerator ) || ~isreal( this.denominator );

f = fopen( file, 'w' );
if complex 
	fprintf( f, '#include <complex>\nusing std::complex;\n' );
end
fprintf( f, 'inline double square( double x ) { return x*x; }\n' );
fprintf( f, sprintf( 'int permutation[] = { %d ', order(1)-1 ) );
for i=2:length(order)
	fprintf( f, sprintf( ', %d', order(i)-1 ) );
end
fprintf( f,' };\n' );
if complex
	fprintf( f, 'complex<double> evaluate( double x[] ) { ' );
	
	if this.frequencyVariable ~= 0
		[nr,nc] = complexHornerScheme( [ numdegrees(:,order) this.numerator] );
		[dr,dc] = complexHornerScheme( [ zeros(1,this.dimension) 1 ; dendegrees(:,order) this.denominator] );
		fprintf( f, 'return complex<double>(%s,%s) / complex<double>(%s,%s); }\n', ...
			nr,nc,dr,dc );
	else
		fprintf( f, 'return complex<double>((%s) / (%s),0); }\n', ...
			hornerScheme( [ numdegrees(:,order) this.numerator] ), ...
			hornerScheme( [ zeros(1,inDim) 1 ; dendegrees(:,order) this.denominator] ) );
	end
else
	fprintf( f, 'double evaluate( double x[] ) { ' );
	fprintf( f, 'return (%s) / (%s); }\n', ...
		hornerScheme( [ numdegrees(:,order) this.numerator] ), ...
		hornerScheme( [ zeros(1,inDim) 1 ; dendegrees(:,order) this.denominator] ) );
end


fclose(f);
