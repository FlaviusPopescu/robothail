function [res] = phit(x, m, s)
%x - the measurement whose likelihood is wanted: z_t^k
% m - mean = z_t^k*
% s - variance = standard_deviation^2;  in this case standard_deviation = sigma_hit

res = 1 / ( sqrt(  det(s) * (2 * pi)^(length(x)) ) ) * exp( -1/2 * ( x - m ) * inv(s) * (x - m)' );