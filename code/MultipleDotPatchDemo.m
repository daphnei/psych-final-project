function MultipleDotPatchDemo
% MultipleDotPatchDemo - Demo to show how to display 2 dot patches.

% For this demo, we'll use the pixel dimensions of our screen to represent
% our coordinate system.  We query the computer for a description of all
% attached displays.  We're going to use the last attached screen to
% display our stimulus.
displayInfo = mglDescribeDisplays;
screenDimsPx = displayInfo(end).screenSizePixel;

% First we'll create our dot patch objects.  The DotPatch class is used to
% represent a dot patch.  This class is separate from the one that actually
% draws the dots on the screen.  DotPatch merely abstracts the positional
% and movement data and provides some helper functions to update their
% position over time.

% Number of dots in the patch.
numDots = 500;

% The dimensions of our patch.  For our purposes, this will the width and
% height of the patch in screen pixels.
patchDims = [500 500];

% The origin of the dot patch.  The dot patch is centered around this point
% in (x,y) space.  This allows you to translate where the patch is located.
center = [-300 0];
	
% Create the actual patch.
dotPatchLeft = DotPatch(numDots, center, patchDims);

% Now we'll make the other patch.
center = [300 0];
dotPatchRight = DotPatch(numDots, center, patchDims);

% A dot patch should have a direction and velocity specified in order to
% animate the dots over time.  Direction is specifed in degress where 0
% degrees is rightward movement.  Velocity is in arbitrary units per
% second.  We specified our dot patches in pixel dimensions so we can treat
% this value in this demo program as pixels per second.
dotPatchLeft.Velocity = 250;
dotPatchRight.Velocity = 125;
dotPatchLeft.Direction = 0;
dotPatchRight.Direction = 180;

% We should also specifiy the coherence of the dot patch.  Coherence is
% specified as a percentage in the range [0,100].  100 being totally coherent
% and 0 having no coherence.
dotPatchLeft.Coherence = 100;
dotPatchRight.Coherence = 50;

% If you want to define the dot direction and coherence in the same fashion
% as the DotThreshold program, take a look at the ConvertCoherence
% function.

% Next we create the GLWindow object that actually displays the dots.  We
% tell it to use the pixel dimensions of the screen as the size of our
% coordinate system.  Position (0,0) is the center of our display.
win = GLWindow('SceneDimensions', screenDimsPx);
win.open;

% We stick the remaining code in a try/catch statement so that if an error
% occurs the open GLWindow object is automatically closed.
try
	% GLWindow doesn't know anything about dot patches except how to draw a
	% list of dots and setting visual parameters like color and dot size.  It
	% does nothing in regards to modifying the dot positional data, so you'll
	% be using the DotPatch class to actually update the dot positions for the
	% animation and the GLWindow class to render them.
	
	% You can use the Dots property of the DotPatch class to get the dot
	% positions.
	dotPositions = dotPatchLeft.Dots;
	
	% RGB of the dot patch.
	dotRGB = [1 0 0];
	
	% Size of the dots in pixels.
	dotSize = 5;
	
	% Add the dot data to GLWindow.
	win.addDotSet(dotPositions, dotRGB, dotSize, 'Name', 'leftPatch');
	
	% Do the same for the other patch.
	dotRGB = [0 1 0];
	dotSize = 5;
	win.addDotSet(dotPatchRight.Dots, dotRGB, dotSize, 'Name', 'rightPatch');
	
	% Have Matlab gobble up keypresses so we don't see them on the screen.
	ListenChar(2);
	
	% Flush our keypress queue.
	mglGetKeyEvent;
	
	% There are several variables we're going to use in our loop to turn
	% things on/off or to adjust patch parameters.  We'll set them up here.
	
	% Toggles the patches on/off.
	enableLeftPatch = true;
	enableRightPatch = true;
	
	% Now we'll go into a loop to accept keyboard command until we abort.
	keepGoing = true;
	while keepGoing
		% To animate the dots we need to update their position before every
		% draw.  The draws will come at the refresh rate of the display,
		% which is 60Hz for the lab displays.  The DotPatch class has a
		% function called "move" which lets us update the dot positions for
		% a specified duration.  This function incorporates the direction,
		% velocity, and coherence variables, which can be adjusted at any
		% time.
		%dotPatchLeft = dotPatchLeft.move(1/60);
		%dotPatchRight = dotPatchRight.move(1/60);
		
		% We've updated the underlying data, but we still have to send this
		% data to GLWindow.  We use the name specified using addDotSet to
		% reference the patches.
		win.setObjectProperty('leftPatch', 'DotPositions', dotPatchLeft.Dots);
		win.setObjectProperty('rightPatch', 'DotPositions', dotPatchRight.Dots);
		
		% Render the scene.
		win.draw;
		
		% Check of any keypresses.
		key = mglGetKeyEvent;
		
		% If a key was pressed "key" will be non-empty.
		if ~isempty(key)
			switch key.charCode
				% Quit our program.
				case 'q'
					keepGoing = false;
					
				% Toggle the left patch.
				case 'o'
					enableLeftPatch = ~enableLeftPatch;
					win.setObjectProperty('leftPatch', 'Enabled', enableLeftPatch);
					
				% Toggle the right patch.
				case 'p'
					enableRightPatch = ~enableRightPatch;
					win.setObjectProperty('rightPatch', 'Enabled', enableRightPatch);
					
				% Increase left patch velocity.
				case 'w'
					dotPatchLeft.Velocity = dotPatchLeft.Velocity + 50;
					
				% Decrease left patch velocity.
				case 's'
					dotPatchLeft.Velocity = dotPatchLeft.Velocity - 50;
					
				% Increase left patch direction.
				case 'e'
					dotPatchLeft.Direction = dotPatchLeft.Direction + 22.5;
					
				% Decrease left patch direction.
				case 'd'
					dotPatchLeft.Direction = dotPatchLeft.Direction - 22.5;
					
				% Increase left patch coherence.  Doing this causes a total
				% recalculation of dot positions, which can be time
				% expensive.
				case 'r'
					newCoherence = dotPatchLeft.Coherence + 10;
					
					% Make sure we don't go above 100%.
					if newCoherence > 100
						newCoherence = 100;
					end
					
					dotPatchLeft.Coherence = newCoherence;
					
				% Decrease left patch coherence.  Doing this causes a total
				% recalculation of dot positions, which can be time
				% expensive.
				case 'f'
					newCoherence = dotPatchLeft.Coherence - 10;
					
					% Make sure we don't go above 100%.
					if newCoherence < 0
						newCoherence = 0;
					end
					
					dotPatchLeft.Coherence = newCoherence;
					
				% Move the left patch left.
				case 'j'
					dotPatchLeft.Center = dotPatchLeft.Center - [100 0];
					
				% Move the left patch right.
				case 'l'
					dotPatchLeft.Center = dotPatchLeft.Center + [100 0];
					
				% Move the left patch up.
				case 'i'
					dotPatchLeft.Center = dotPatchLeft.Center + [0 100];
					
				% Move the left patch down.
				case 'k'
					dotPatchLeft.Center = dotPatchLeft.Center - [0 100];
			end
		end
	end
	
	% Close the GLWindow.
	win.close;
	
	% Tell Matlab to stop eating keypresses.
	ListenChar(0);
catch e
	% Close the open GLWindow if an error occurred.
	win.close;
	
	% Tell Matlab to stop eating keypresses.
	ListenChar(0);
	
	% Toss the error to the command window.
	rethrow(e);
end
