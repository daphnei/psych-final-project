% InitializeLADData
%
% Initialize experimental data structures.
%
% 4/16/94		dhb		Pulled out of OpenEXPWindow.
% 								Modified h/v option for angle.
%									No orthogonal motion option.
% 2/8/98    dhb   Update for version 2.

% Make the rects
dotRect = [0 0 rectSize rectSize];
dotRect = CenterRect(dotRect,screenRect);

% Make initial dot arrays
theDots = zeros(nDots,2);
theDots(:,1) = Ranint(nDots,rectSize) + dotRect(2);
theDots(:,2) = Ranint(nDots,rectSize) + dotRect(1);

% Make the offsets	
theOffsets = zeros(movePerFrame,2*nCorrs);
for i = 1:nCorrs
	tmpOffsets = MakeOffsets(movePerFrame,dotCorrs(i),dotMove,...
		hOrV,noRandom);
	theOffsets(:,2*(i-1)+1:2*i) = tmpOffsets;
end

% Make lists of indicies
moveIndices = zeros(movePerFrame,indFrames);
for i = 1:indFrames
	moveIndices(:,i) = ChooseKFromN(nDots,movePerFrame);
end

