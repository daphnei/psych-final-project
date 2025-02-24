function [response] = WaitForResponse(win, params, duration, getResponse)
% MoveTheDots - Basic dot mover.
%
% Syntax:
% dotPatch = MoveTheDots(win, params, patchName, params, dotPatch, dotCoherence)
% dotPatch = MoveTheDots(win, params, patchName, params, dotPatch, dotCoherence, getResponse)
%
% Description:
% Animates a patch of dots for a specified amount of time.  If toggled to
% get a response, the function runs for a minimum time specified by
% "duration" and then continues forever until a response is detected.  If a
% response comes duration the minimum duration, the animation ends
% immediately following the duration.  The abort key will always exit the
% animation regardless of when it's received.
%
% Input:
% win (GLWindow) - The GLWindow object.
% params - Experimental parameters structure
% patchName (string) - The name of the patch when added to GLWindow.
% dotPatch (DotPatch) - The target dot patch.
% duration - Duration to go for.
% getResponse (logical) - If true, the function processes a response.
%
% Output:
% dotPatch (DotPatch) - The updated dot patch.

error(nargchk(3, 4, nargin));

if nargin == 3
	getResponse = true;
end

% Reset the keyboard queue.
mglGetKeyEvent;

t0 = mglGetSecs;
keepLooping = true;
response = [];
while keepLooping
	% Process any keypresses.
	key = mglGetKeyEvent;
	if ~isempty(key)
		switch key.charCode
			% Left/Down
			case params.leftKey
				response = -1;
			
			% Right/Up
			case params.rightKey
				response = 1;
			
			% Abort.
			case 'q'
				error('abort');
		end
	end
	
	if getResponse
		% Don't allow the loop to quit until we've reached the minimum
		% duration.
		if (mglGetSecs - t0) > duration && ~isempty(response)
			keepLooping = false;
		end
	else
		% Look to see if we've gone the duration.
		if (mglGetSecs - t0) > duration
			keepLooping = false;
			
			% Trash the response if not toggled to get it.
			response = [];
		end
	end
end
