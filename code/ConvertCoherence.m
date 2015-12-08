function [coherence, direction] = ConvertCoherence(coherence, HorV)
% ConvertCoherence - Converts a coherence scalar into a % coherence and direction.
%
% Syntax:
% [coherence, direction] = ConvertCoherence(coherence)
%
% Description:
% Coherence and direction in the MotionAfter set of experiments are specified as a
% scalar value in the range [-1, 1] and a flag indicating left/right or up/down
% motion.  Within the code, dot patches are represented by the DotPatch class which 
% encodes coherence as a value from 0 to 100 and direction as an angle in
% the range [0, 360] degrees.  This function converts the scalar coherence
% into something usable by the DotPatch class.
%
% Input:
% coherence (scalar) - Coherence value from one of the MotionAfter
%   experiments.
% HorV (scalar) - 0 = left/right, 1 = up/down.
%
% Output:
% coherence (scalar) - The coherence for the DotPatch class in %.
% direction (scalar) - The angle of the direction of motion in degrees.

error(nargchk(2, 2, nargin));

% Make sure the coherence value is within the proper range.
if ~isscalar(coherence) || coherence < -1 || coherence > 1
	error('"coherence" must be a scalar in the range [-1,1].');
end

% Now make sure HorV is legit.
if ~any(HorV == [0 1])
	error('"HorV" must be either 0 or 1.');
end

if HorV
	% Vertical
	
	if coherence > 0
		% Upward motion.
		direction = 90;
	else
		% Downward motion.
		direction = -90;
	end
else
	% Horizontal
	
	if coherence > 0
		% Rightward motion.
		direction = 0;
	else
		% Leftware motion.
		direction = 180;
	end
end

% Convert coherence into a %.
coherence = abs(coherence) * 100;
