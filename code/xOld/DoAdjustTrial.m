function framesPerSec = DoAdjustTrial(window,...
	adaptDots,adaptOffsets,adaptMoveIndices,...
	adaptDotSize,adaptRect,bgVal,adaptVal,...
	testDots,testOffsets,testMoveIndices,...
	testDotSize,testRect,testVal,trialDuration,waitKey)
%
%
% Do a single trial of the motion aftereffect experiment
%
% 4/11/94		dhb		Wrote it from older tilt aftereffect code.
% 2/16/95		dhb		Change from SysBeep to playsound
% 7/2/95		dhb		Change playsound to soundplay
%									Added waitKey variable

% Sound globals
global theTone theToneRate

% Set default value for waitKey
if (nargin < 15)
	waitKey = 1;
end

% Step 1: Beep and keep adapting
if (waitKey == 1)
	adaptDots = MoveTheDots(window,adaptDots,adaptOffsets,adaptMoveIndices,...
								adaptDotSize,adaptRect,bgVal,adaptVal,-1,1);
	DOTS('DrawDots',adaptDots,bgVal,adaptDotSize);
	if (CharAvail == 1)
		key = GetChar;
		if (key == 'q' | key == 'Q')
			response = qval;	
			return;
		end
	end
else
	DOTS('DrawDots',adaptDots,bgVal,adaptDotSize);
end

% Step 2: Show the test
DOTS('DrawDots',testDots,testVal,testDotSize);
testDots = MoveTheDots(window,testDots,testOffsets,testMoveIndices,...
							testDotSize,testRect,bgVal,testVal,trialDuration/1000);
DOTS('DrawDots',testDots,bgVal,testDotSize);

% Put adapter dots back
DOTS('DrawDots',adaptDots,bgVal,adaptDotSize);
