function MovingDotsDemo
% MovingDotsDemo - Demonstrates dot lifetime and coherence.
%
% Syntax:
% MovingDotsDemo
%
% Description:
% MovingDotsDemo is a program to demonstrate the effects of dot lifetime
% and coherence.  Dot coherences are specified in the same fashion as the
% DotThreshold experiment.  Dot lifetimes are specified as a vector of
% durations in seconds.
%
% Controls:
% Up/Down Arrow - Change the dot lifetime.
% Left/Right Arrow - Change the dot coherence.
% q - Quit the program.

% List of available dot coherences.
params.dotCoherences = [-1 -0.6 -0.3 -0.15 0 0.15 0.3 0.6 1];

% List of available dot lifetimes.
params.dotLifetimes = [0 0.1 0.25 0.5 0.75 1 Inf];

% Indices into the coherence and lifetime arrays which select state of the
% dot patch currently being shown.
params.coherenceIndex = 5;
params.lifetimeIndex = 4;

% Toggles up/down or left/right coherent motion.  0 = left/right, 1 =
% up/down.
params.HorV = 0;

% Initialize the keyboard queue.
ListenChar(2);
mglGetKeyEvent;

% Create the dot patch and open the GLWindow.
[win, dotPatch] = initDisplay(params);

try
	% Show the dots until aborted.
	keepGoing = true;
	while keepGoing
		% Update the dot positions.
		dotPatch = dotPatch.move(1/60);
		
		% Send the updated dot positions to GLWindow.
		win.setObjectProperty('dotPatch', 'DotPositions', dotPatch.Dots);
		win.draw;
		
		% Check for a keypress.
		key = mglGetKeyEvent;
		
		if ~isempty(key)
			switch key.keyCode
				% Up arrow
				case 127
					params.lifetimeIndex = params.lifetimeIndex + 1;
					if params.lifetimeIndex > length(params.dotLifetimes)
						params.lifetimeIndex = 1;
					end
					
				% Down arrow
				case 126
					params.lifetimeIndex = params.lifetimeIndex - 1;
					if params.lifetimeIndex < 1
						params.lifetimeIndex = length(params.dotLifetimes);
					end
					
				% Left arrow
				case 124
					params.coherenceIndex = params.coherenceIndex - 1;
					if params.coherenceIndex < 1
						params.coherenceIndex = length(params.dotCoherences);
					end
					
				% Right arrow
				case 125
					params.coherenceIndex = params.coherenceIndex + 1;
					if params.coherenceIndex > length(params.dotCoherences);
						params.coherenceIndex = 1;
					end
					
				% Q/q Quit
				case 13
					keepGoing = false;
			end
			
			% Update the dot patch parameters.
			[coherence, direction] = ConvertCoherence(params.dotCoherences(params.coherenceIndex), ...
				params.HorV);
			dotPatch.LifeTime = params.dotLifetimes(params.lifetimeIndex);
			dotPatch.Direction = direction;
			dotPatch.Coherence = coherence;
			
			% Update the info text.
			t = sprintf('Lifetime: %g, Coherence: %g', params.dotLifetimes(params.lifetimeIndex), ...
				params.dotCoherences(params.coherenceIndex));
			win.setText('infoText', t);
		end
	end
	
	ListenChar(0);
	win.close;
catch e
	ListenChar(0);
	win.close;
	rethrow(e);
end





function [win, dotPatch] = initDisplay(params)
% Basic initialization
ClockRandSeed;

% Choose the last attached screen as our target screen, and figure out its
% screen dimensions in pixels.
d = mglDescribeDisplays;
screenDims = d(end).screenSizePixel;

% Open the window.
win = GLWindow('SceneDimensions', screenDims);
win.open;
win.draw;

try
	% Convert the patch coherence value into something usable with
	% DotPatch.
	[coherence, direction] = ConvertCoherence(params.dotCoherences(params.coherenceIndex), ...
		params.HorV);
	
	% Create the adapt patch.
	numDots = 100;
	center = [0 0];
	patchDims = [500 500];
	dotVelocity = 250;
	dotPatch = DotPatch(numDots, center, patchDims, 'Velocity', dotVelocity, ...
		'Coherence', coherence, 'Direction', direction, 'LifeTime', ...
		params.dotLifetimes(params.lifetimeIndex));
	
	% Add the patch to the GLWindow.
	dotRGB = [1 1 1];
	dotSize = 5;
	win.addDotSet(dotPatch.Dots, dotRGB, dotSize, 'Name', 'dotPatch');
	
	% Add info text.
	t = sprintf('Lifetime: %g, Coherence: %g', params.dotLifetimes(params.lifetimeIndex), ...
		params.dotCoherences(params.coherenceIndex));
	win.addText(t, 'Name', 'infoText', 'Center', ...
		[0 patchDims(2)/2+100], 'FontSize', 80, 'Color', [0 1 0]);
catch e
	ListenChar(0);
	win.close;
	rethrow(e);
end
