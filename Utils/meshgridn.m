function [varargout] = meshgridn(varargin)
% Arbitrary-dimensional meshgrid
% Slightly different from meshgrid in orderings: x changes by columns, y
% changes by rows
% Probably useless
% Incomplete

n = cellfun(@numel, varargin); % List of lengths

shape = diag(n);
shape(shape == 0) = 1;
shape = num2cell(shape,2); 
% Dimensions to reshape to

rep = repmat(n,nargin,1); % Want each row to be n except on diagonal, where it's 1
t = true(1,nargin);
rep(diag(t)) = t;
rep = num2cell(rep,2); 
% Used to control repmat

varargout = cellfun(@(v,s,r) repmat(reshape(v(:),s),r), varargin(:), shape(:), rep(:),'UniformOutput',false);
% TODO: Use shiftdim instead of reshape? Might be faster.
end

