classdef DotPatch
	% DotSet - Class to represent a patch of dots.
	%
	% DotPatch Properties:
	% NumDots - Number of dots in the patch.
	%
	% DotPatch Methods:
	% DotPatch - Constructor
	
	% Properties the user has full access to.
	properties
		NumDots;
		PatchDims;
		Center;
		
		Direction = 0;
		LifeTime = Inf;
		Velocity = 1;
	end
	
	properties (Dependent = true)
		Coherence;
	end
	
	% Properties that the user can see, but not set.  These properties also
	% are calculated at call time.
	properties (SetAccess = protected, Dependent = true)
		ComponentVelocity;
		Dots;
	end
	
	% Internal properties hidden from the user.
	properties (Access = protected)
		CoherentDots;
		NumCoherentDots;
		IncoherentDots;
		NumIncoherentDots;
		IncoherentComponentVelocities;
		CoherentDotTimes;
		IncoherentDotTimes;
		ClassInitialized = false;
		PrivateCoherence = 100;
	end
	
	methods
		function obj = DotPatch(numDots, center, patchDims, varargin)
			% DotPatch - DotPatch consructor.
			%
			% Syntax:
			% obj = DotPatch(numDots, center, patchDims, [dotPatchOpts]);
			
			error(nargchk(3, Inf, nargin));
			
			parser = inputParser;
			
			% Add some optional Key/Value parameters.
			parser.addParamValue('Coherence', obj.Coherence);
			parser.addParamValue('Direction', obj.Direction);
			parser.addParamValue('LifeTime', obj.LifeTime);
			parser.addParamValue('Velocity', obj.Velocity);
			
			% Execute the parser to make sure input is good.
			parser.parse(varargin{:});
			
			% Create a standard Matlab structure from the parser results.
			parserResults = parser.Results;
			
			obj.NumDots = numDots;
			obj.PatchDims = patchDims;
			obj.Center = center;
			
			% Copy the parser parameters to the DotPatch object.
			pNames = fieldnames(parserResults);
			for i = 1:length(pNames)
				obj.(pNames{i}) = parserResults.(pNames{i});
			end
			
			% Initialize the dots.
			obj = obj.initializeDots;
			
			% Flag that the dots have been initially setup.  This is a flag
			% used by other functions that call the same initialization
			% routines.
			obj.ClassInitialized = true;
		end
		
		obj = move(obj, duration)
	end
	
	% Methods internal to the class.
	methods (Access = protected)
		obj = initializeDots(obj)
	end
	
	% Get/Set functions.
	methods
		function value = get.Coherence(obj)
			value = obj.PrivateCoherence;
		end
		function obj = set.Coherence(obj, value)
			if value > 100 || value < 0
				error('Coherence must be in the range [0,100].');
			end
			
			obj.PrivateCoherence = value;
			
			if obj.ClassInitialized
				obj = obj.initializeDots;
			end
		end
		
		function value = get.Dots(obj)
			% Concatenate the list of coherent and incoherent dots.
			value = [obj.CoherentDots ; obj.IncoherentDots];
			
			% Reposition the dots to the 'Center' property.
			offset = -obj.PatchDims/2 + obj.Center;
			value(:,1) = value(:,1) + offset(1); % X
			value(:,2) = value(:,2) + offset(2); % Y
		end
		
		function value = get.ComponentVelocity(obj)
			% Compute the component velocities.
 			radDirection = obj.Direction / 180 * pi;
 			xDelta = obj.Velocity * cos(radDirection);
			yDelta = obj.Velocity * sin(radDirection);
			
			value = [xDelta yDelta];
		end
	end
end
