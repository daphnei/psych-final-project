% MotionAfterDrvr
%
% Driver program for motion aftereffect experiment.
%
% 2/15/95			dhb			Pulled this out separately.
% 7/3/95			dhb			Wrote it from FC version.

% Convenience parameters
[nil,nTestCorrs] = size(testDotCorrs);
adaptMovePerFrame = floor(nAdaptDots); 	% Number of dots moved at a time, adpater
testMovePerFrame = floor(nTestDots);		% Number of dots moved at a time, test
adaptIndFrames = ceil(10*nAdaptDots/adaptMovePerFrame); 	% Number of independent frames
testIndFrames = ceil(10*nTestDots/testMovePerFrame); 		% Number of independent frames
[null,nTests] = size(testDotCorrs);				% Number of test correlations
nTrials = nBlocks*nTests;									% Number of trials

% Set up trial indicator tone
global theTone theToneRate
theToneRate = 12000;
timeAxis = (1:500)/theToneRate;
theTone = exp(((timeAxis-250).^2)/(100^2)) .* sin(2*pi*500*timeAxis);

% Enforce limit
if (adaptMovePerFrame < 2)
	adaptMovePerFrame = 2;
end
if (testMovePerFrame < 2)
	testMovePerFrame = 2;
end

% Color control
bgVal = 0;			
adaptVal = 1;
testVal = 2;
dotClut = [bgColor ; adaptColor ; testColor];

% Open and initialize variables.
OpenEXPWindow;

% Preload timing MEX file
GetSecs;

% Initialize data structures.
% In a subscript to keep the main program uncluttered.
InitializeMAData;

% Initial adaptation, wait for keypress to start.
DOTS('DrawDots',adaptDots,adaptVal,adaptDotSize);
while (CharAvail == 0)
end
GetChar;
[adaptDots,adaptFramesPerSec] = MoveTheDots(window,adaptDots,adaptOffsets,adaptMoveIndices,...
							adaptDotSize,adaptRect,bgVal,adaptVal,initialAdaptTime);

% Now run adjustments
theAdjusts = []; 
while (1)
	trialOrder = Shuffle(1:nTests);
	whichCorr = trialOrder(1);
	
	done = 0;
	while (1)
		% Top up adaptation
		adaptDots = MoveTheDots(window,adaptDots,adaptOffsets,adaptMoveIndices,...
							adaptDotSize,adaptRect,bgVal,adaptVal,-1,1);
	
		% Process key press
		if (CharAvail == 1)
			key = GetChar;
			if (key == 'q' | key == 'Q')
				done = 1;
				break;
			elseif (key == 'a' | key == 'A')
				disp(sprintf('Adjustment accepted at %g',testDotCorrs(whichCorr)));
				theAdjusts = [theAdjusts testDotCorrs(whichCorr)]; 
				break;
			elseif (key == ' ')
				% Show dots
				DoAdjustTrial(window,...
					adaptDots,adaptOffsets,adaptMoveIndices,...
					adaptDotSize,adaptRect,bgVal,adaptVal,...
					testDots,testOffsets(:,2*(whichCorr-1)+1:2*whichCorr),testMoveIndices,...
					testDotSize,testRect,testVal,trialDuration,0);
			elseif (abs(key) == 29 | abs(key) == 30)
				whichCorr = whichCorr+1;
				if (whichCorr > nTestCorrs)
					whichCorr = nTestCorrs;
				end
			elseif (abs(key) == 28 | abs(key) == 31)
				whichCorr = whichCorr-1;
				if (whichCorr < 1)
					whichCorr = 1;
				end	
			end
		end
	end
	if (done == 1)
		break;
	end
end

% Close the experimental window
CloseExpWindow;

% Display the mean and standard deviation
[nil,nAdjusts] = size(theAdjusts);
disp(' ');
if (nAdjusts > 1)
  disp(sprintf('Mean adjustment: %g',mean(theAdjusts)));
  disp(sprintf('Standard deviation: %g',std(theAdjusts)));
elseif (nAdjusts > 0)
	fprintf(1,'Adjustment: %g\n',theAdjusts(1));
end
