function [response,adaptDots,testDots,framesPerSec] = DoATrial(window,...
	adaptDots,adaptOffsets,adaptMoveIndices,...
	adaptDotSize,adaptRect,adaptBgVal,adaptVal,...
	testDots,testOffsets,testMoveIndices,...
	testDotSize,testRect,testBgVal,testVal,trialDuration,waitKey,...
	adaptBgColor,testBgColor)
%
%
% Do a single trial of the motion aftereffect experiment
%
% 4/11/94		dhb		Wrote it from older tilt aftereffect code.
% 2/16/95		dhb		Change from SysBeep to playsound
% 7/2/95		dhb		Change playsound to soundplay
%									Added waitKey variable
% 5/8/96		dhb		Separate test and adapter dot colors.
%						dhb		Timing.
% 6/27/96   dhb   Added global THRESHOLD
% 4/29/98		dhb		SoundPlay -> SND, sychronous.

% Sound globals
global theTone theToneRate THRESHOLD

% Set default value for waitKey
if (nargin < 15)
	waitKey = 1;
end

% Define key values
dval = 0;
kval = 1;
qval = -1;

% Step 1: Beep and keep adapting
if (THRESHOLD ~= 1)
	SND('Play',theTone,theToneRate);
	SND('Wait');
	SND('Close');
end
if (waitKey == 1)
	adaptDots = MoveTheDots(window,adaptDots,adaptOffsets,adaptMoveIndices,...
								adaptDotSize,adaptRect,adaptBgVal,adaptVal,-1,1);
	DOTS(window,'DrawDots',adaptDots,adaptBgVal,adaptDotSize);
	if (CharAvail == 1)
		key = GetChar;
		if (key == 'q' | key == 'Q')
			response = qval;	
			return;
		end
	end
else
	DOTS(window,'DrawDots',adaptDots,adaptBgVal,adaptDotSize);
end

% Step 2: Show the test
SetColor(window,testBgVal,testBgColor');
DOTS(window,'DrawDots',testDots,testVal,testDotSize);
[testDots,framesPerSec] = MoveTheDots(window,testDots,testOffsets,testMoveIndices,...
							testDotSize,testRect,testBgVal,testVal,trialDuration/1000);
DOTS(window,'DrawDots',testDots,testBgVal,testDotSize);
SetColor(window,testBgVal,adaptBgColor');

% Step 3: Get the response while continuing to adapt.  The while
% loop is unecessary but does no damage.
done = 0;
while (done == 0)
	DOTS(window,'DrawDots',adaptDots,adaptBgVal,adaptDotSize);
	adaptDots = MoveTheDots(window,adaptDots,adaptOffsets,adaptMoveIndices,...
							adaptDotSize,adaptRect,adaptBgVal,adaptVal,-1,1);
  if (CharAvail == 1)
    key = GetChar;
    if (key == 'd' | key == 'D') 
      response = dval;
      done = 1;
    elseif (key == 'k' | key == 'K')
      response = kval;
      done = 1;
    elseif (key == 'q' | key == 'Q')
      response = qval;
      done = 1;
    end
  end 
end
