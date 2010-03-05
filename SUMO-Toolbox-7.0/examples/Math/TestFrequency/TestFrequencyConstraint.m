function y = TestFrequencyConstraint(x)

	% calculate the distance from the center
	%distance = dot(x, x, 2);

	% only allow samples that lie within the unit circle
	%y = 1 - sqrt(distance);
	
	% 1D example!
	y = x(:,1) - 0.8;
end