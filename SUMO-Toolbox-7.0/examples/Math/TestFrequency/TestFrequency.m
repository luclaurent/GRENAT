function [out] = TestFrequency(samples)

% for each sample, generate a set of frequency responses
out = [];

for i = 1 : size(samples,1)
    f = [-1 : .2 : 1]';
    x = repmat(samples(i,1), size(f,1), 1);
    
    values = x .^3 .* sin(x .* 30) .* exp(-f.^2 / 0.1);
    % values = x .^4 .* 2 .* sin(x);
    
    out = [out ; x f values];
end
