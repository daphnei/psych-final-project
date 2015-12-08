% InitializeMAData
%
% Initialize experimental data structures.
%
% 4/16/94		dhb		Pulled out of OpenEXPWindow.
% 								Modified h/v option for angle.
%									No orthogonal motion option.
% 4/18/94		dhb		Order data allocation.									

% Make the rects
adaptRect = [0 0 adaptRectSize adaptRectSize];
adaptRect = CenterRect(adaptRect,screenRect);
testRect = [0 0 testRectSize testRectSize];
testRect = CenterRect(testRect,screenRect);

% Make initial dot arrays
adaptDots = zeros(nAdaptDots,2);
adaptDots(:,1) = Ranint(nAdaptDots,adaptRectSize) + adaptRect(RectLeft);
adaptDots(:,2) = Ranint(nAdaptDots,adaptRectSize) + adaptRect(RectTop);
testDots = zeros(nTestDots,2);
testDots(:,1) = Ranint(nTestDots,testRectSize) + testRect(RectLeft);
testDots(:,2) = Ranint(nTestDots,testRectSize) + testRect(RectTop);

% Make some offsets.  We make one set of offsets for the adapter
% and each of the test correlations to speed things up.
adaptOffsets = MakeOffsets(adaptMovePerFrame,adaptDotCorr,adaptDotMove,...
	adaptHOrV,adaptNoRandom);
	
testOffsets = zeros(testMovePerFrame,2*nTests);
for i = 1:nTests
	tmpOffsets = MakeOffsets(testMovePerFrame,testDotCorrs(i),testDotMove,...
		testHOrV,testNoRandom);
	testOffsets(:,2*(i-1)+1:2*i) = tmpOffsets;
end

% Make lists of dots to move
adaptMoveIndices = zeros(adaptMovePerFrame,adaptIndFrames);
for i = 1:adaptIndFrames
	adaptMoveIndices(:,i) = ChooseKFromN(nAdaptDots,adaptMovePerFrame);
end
testMoveIndices = zeros(testMovePerFrame,testIndFrames);
for i = 1:testIndFrames
	testMoveIndices(:,i) = ChooseKFromN(nTestDots,testMovePerFrame);
end

% Set up space for the data
theData = -1*ones(nTests,nBlocks+1);
theData(:,1) = testDotCorrs';

% Set up space for the order data
theOrderData = -1*ones(nTests*nBlocks,3);
