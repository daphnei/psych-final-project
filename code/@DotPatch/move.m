function obj = move(obj, duration)
% move - Updates the position of the dots.
%
% Syntax:
% obj = obj.move(duration)
%
% Description:
% Updates the position of the dots on the patch based on the dot
% velocities, current positions, direction, and the specified duration.
%
% Input:
% duration (scalar) - The duration the dots should move.
%
% Output:
% obj (DotPatch) - The updated DotPatch object with the new dot positions.

error(nargchk(2, 2, nargin));

if obj.NumCoherentDots >= 1
	% Update the lifetime tracker.
	obj.CoherentDotTimes = obj.CoherentDotTimes + duration;
	
	% Look for dots whose lifetime has been exceeded.
	dl = obj.CoherentDotTimes > obj.LifeTime;
	numReborn = sum(dl);
	
	% Wrap the dead dot lifetime clocks around to reset them.
	obj.CoherentDotTimes(dl) = obj.CoherentDotTimes(dl) - obj.LifeTime;
	
	% Randomize the position of the reborn dots.
	for i = 1:2
		obj.CoherentDots(dl,i) = rand(numReborn, 1) * obj.PatchDims(i);
	end
	
	% Calculate the component distant moved for our coherent dots.
	componentDist = obj.ComponentVelocity * duration;
	
	% Add this to our coherent dot positions.
	for i = 1:2
		obj.CoherentDots(:,i) = obj.CoherentDots(:,i) + componentDist(i);
	end
	
	% Wrap points that have moved outside the bounds.  This wraps for both the
	% X and Y directions.
	for i = 1:2
		% Dots that passed the left/bottom boundary.
		dl = obj.CoherentDots(:,i) < 0;
		
		% How far those dots surpassed the boundary.
		surpassDist = obj.CoherentDots(dl,i);
		
		% Wrap them around the right/top boundary by how far they surpassed the
		% left/bottom boundary.
		obj.CoherentDots(dl,i) = obj.PatchDims(i) + surpassDist;
		
		% Dots that passed the right/top boundary.
		dl = obj.CoherentDots(:,i) > obj.PatchDims(i);
		
		% How far those dots surpassed the boundary.
		surpassDist = obj.CoherentDots(dl,i) - obj.PatchDims(i);
		
		% Wrap them around the left/bottom boundary by how far they surpassed
		% the right/top boundary.
		obj.CoherentDots(dl,i) = surpassDist;
	end
end

if obj.NumIncoherentDots >= 1
	% Update the lifetime tracker.
	obj.IncoherentDotTimes = obj.IncoherentDotTimes + duration;
	
	% Look for dots whose lifetime has been exceeded.
	dl = obj.IncoherentDotTimes > obj.LifeTime;
	numReborn = sum(dl);
	
	% Wrap the dead dot lifetime clocks around to reset them.
	obj.IncoherentDotTimes(dl) = obj.IncoherentDotTimes(dl) - obj.LifeTime;
	
	% Randomize the position of the reborn dots.
	for i = 1:2
		obj.IncoherentDots(dl,i) = rand(numReborn, 1) * obj.PatchDims(i);
	end
	
	% Calculate the component distant moved for our incoherent dots.
	componentDist = obj.IncoherentComponentVelocities * duration;
	
	% Update the dot positions.
	obj.IncoherentDots = obj.IncoherentDots + componentDist;
	
	% Wrap the points if necessary.
	for i = 1:2
		% Dots that passed the left/bottom boundary.
		dl = obj.IncoherentDots(:,i) < 0;
		
		% How far those dots surpassed the boundary.
		surpassDist = obj.IncoherentDots(dl,i);
		
		% Wrap them around the right/top boundary by how far they surpassed the
		% left/bottom boundary.
		obj.IncoherentDots(dl,i) = obj.PatchDims(i) + surpassDist;
		
		% Dots that passed the right/top boundary.
		dl = obj.IncoherentDots(:,i) > obj.PatchDims(i);
		
		% How far those dots surpassed the boundary.
		surpassDist = obj.IncoherentDots(dl,i) - obj.PatchDims(i);
		
		% Wrap them around the left/bottom boundary by how far they surpassed
		% the right/top boundary.
		obj.IncoherentDots(dl,i) = surpassDist;
	end
end
