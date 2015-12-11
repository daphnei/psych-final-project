function [win] = OpenEXPWindow(params)
% OpenEXPWindow - Open the experimental window and create the dot patches.
%
% Syntax:
% win = OpenEXPWindow(params)
%
% Input:
% params (struct) - Experimental parameters struct.
%
% Output:
% win (GLWindow) - GLWindow object that represents the experimental window.

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

% Add the feedback text.
% TODO(daphne): Might want to modify these and just give a single feedback
% (no conceoption of right or wrong).
win.addText('Correct', 'Name', 'correctText', 'Center', [0 100], ...
	'FontSize', 80, 'Color', [0 1 0]);
win.addText('Incorrect', 'Name', 'incorrectText', 'Center', [0 100], ...
	'FontSize', 80, 'Color', [1 0 0]);

% Add the start text
win.addText('Hit Any Key To Start', 'Name', 'startText', 'Center', [0 0], ...
	'FontSize', 80, 'Color', [1 1 1]);

% Add a fixation point
if (params.fpSize > 0)
    win.addOval([0 0], [params.fpSize params.fpSize], params.fpColor, 'Name', 'fp');
end

% Don't show the patches initially.
win.disableAllObjects;
