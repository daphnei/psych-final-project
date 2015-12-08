function obj = initializeDots(obj)
% initializeDots - Creates the initial set of dots.
%
% Syntax:
% obj = obj.initializeDots

error(nargchk(1, 1, nargin));

% Calculate the number of coherent and incoherent dots.
obj.NumCoherentDots = round(obj.NumDots * obj.Coherence / 100);
obj.NumIncoherentDots = obj.NumDots - obj.NumCoherentDots;

% Allocate memory for our data structures.
obj.CoherentDots = zeros(obj.NumCoherentDots, 2);
obj.IncoherentDots = zeros(obj.NumIncoherentDots, 2);
obj.IncoherentComponentVelocities = zeros(obj.NumIncoherentDots, 2);

% Randomize the (x,y) start positions.
obj.CoherentDots(:,1) = rand(obj.NumCoherentDots, 1) * obj.PatchDims(1);
obj.CoherentDots(:,2) = rand(obj.NumCoherentDots, 1) * obj.PatchDims(2);
obj.IncoherentDots(:,1) = rand(obj.NumIncoherentDots, 1) * obj.PatchDims(1);
obj.IncoherentDots(:,2) = rand(obj.NumIncoherentDots, 1) * obj.PatchDims(2);

% Compute the component velocities for the incoherent dots.
for i = 1:obj.NumIncoherentDots
	radDirection = rand * 2 * pi;
	xDelta = obj.Velocity * cos(radDirection);
	yDelta = obj.Velocity * sin(radDirection);
	
	obj.IncoherentComponentVelocities(i,:) = [xDelta yDelta];
end

% Initialize the dot initial start times.
obj.CoherentDotTimes = rand(obj.NumCoherentDots, 1) * obj.LifeTime;
obj.IncoherentDotTimes = rand(obj.NumIncoherentDots, 1) * obj.LifeTime;
