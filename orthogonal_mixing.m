function [reflected_v] = orthogonal_mixing(v)

%sprintf('Size of vect (%g, %g) ', [size(v)])
%sprintf('Sum of vect (%g) ', [sum(v)])

reflected_v = repmat(sum(v)/size(v, 2)*-2,1,size(v,2)) ;
end