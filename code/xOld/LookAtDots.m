% LookAtDots
%
% Program to look at correlated random dots of different
% correlations.
%
% NOTE: Turn off background operation to make MATLAB's cursor go
% away and to keep timing correct.  Failure to do so will result
% in lost keystrokes.
%
% 4/16/94		dhb		Wrote it.
% 2/8/98    dhb   Update for version 2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EXPERIMENTAL PARAMETERS
%
% Dot parameters.  The dot correlations determine
% how strong the stimuli are.  The number must between 
% -1 and 1.  Negative numbers move to the left, positive
% numbers move to the right (when hOrV is set to 0). 
dotCorrs = [-0.3 -0.275 -0.250 -0.225 ...
						-0.2 -0.175 -0.150 -0.125 ...
						-0.1 -0.075 -0.050 -0.025 ...
						 0.0  0.025 0.050 0.075 ...
						 0.1  0.125 0.150 0.175 ...
						 0.2  0.225 0.250 0.275 ...
						 0.3 ];	
nDots = 200;									% Number of dots 
rectSize = 250;								% Size of rectangle
dotSize = 2;									% Size of dots
dotMove = 1;									% Controls size of dot moves
hOrV = 0;											% Angle of dot motion, 0=>left/right, 90=>up/down, etc.
noRandom = 1;									% Orthogonal motion?, 1=>yes, 0=>no

bgColor = [0 0 0];						% Color of background (RGB, each between 0 and 255)
dotColor = [255 255 255];			% Color of dots (RGB, each between 0 and 255)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PROGRAM ITSELF
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convenience parameters
movePerFrame = nDots; 				% Number of dots moved at a time, adpater
indFrames = 2*ceil(5*nDots/movePerFrame); % Number of independent frames
[null,nCorrs] = size(dotCorrs);	% Number of correlations

% Color control
bgVal = 0;			
dotVal = 1;
dotClut = [bgColor ; dotColor];

% Open and initialize variables.
% Use main program open, then override CLUT setting.
OpenEXPWindow;
SCREEN(window,'SetClut',dotClut,0);

% Initialize data structures.
% In a subscript to keep the main program uncluttered.
InitializeLADData;

% Look at the dots.  Arrow keys change correlations.  'q' exits.
done = 0;
whichCorr = floor(length(dotCorrs)/2)+1;
SCREEN(window,'TextSize',18);
SCREEN(window,'DrawText',sprintf('%g',dotCorrs(whichCorr)),100,100,1);
while (done == 0)		
	% Show dots and wait for key press.
	theDots = MoveTheDots(window,theDots,...
							theOffsets(:,2*(whichCorr-1)+1:2*whichCorr),moveIndices,...
							dotSize,dotRect,bgVal,dotVal,-1,1);
	
	% Process any key press.
	key = 0;
	if (KbCheck == 1)
		key = GetChar;
		if (key == 'q' | key == 'Q')
			done = 1;
		elseif (abs(key) == 29)
			SCREEN(window,'DrawText',sprintf('%g',dotCorrs(whichCorr)),100,100,0);
			whichCorr = whichCorr+1;
			if (whichCorr > nCorrs)
				whichCorr = nCorrs;
			end
			SCREEN(window,'DrawText',sprintf('%g',dotCorrs(whichCorr)),100,100,1);
		elseif (abs(key) == 28)
			SCREEN(window,'DrawText',sprintf('%g',dotCorrs(whichCorr)),100,100,0);
			whichCorr = whichCorr-1;
			if (whichCorr < 1)
				whichCorr = 1;
			end	
			SCREEN(window,'DrawText',sprintf('%g',dotCorrs(whichCorr)),100,100,1);	
		end
	end
end

% Close up
CloseEXPWindow;
			
