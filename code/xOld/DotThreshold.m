% DotThreshold
%
% Program to measure psychometric function for direction of dot
% movement.  The program uses the method of constant stimuli and
% allows only for constant spacing between the stimuli.
%
% NOTE: Turn off background operation to make MATLAB's cursor go
% away and to keep timing correct.  Failure to do so will result
% in lost keystrokes.
%
% 4/10/94		dhb		Wrote it.
% 4/11/94		dhb		Lots of work on it.
% 4/14/94		dhb		Horizontal/veritcal options.
% 4/16/94		dhb		Modified h/v option for angle.
%									No orthogonal motion option.
%									Auto set of movePerFrame variables.
% 4/18/94		dhb		Keep order trial order data for the curious.
%									It can be found at end in variable theOrderData.
% 4/19/94		dhb		Fix parameter comments.
%									Fix odd/number problem.
% 4/25/94		dhb		Force movePerFrame positive
% 2/15/95		dhb		Pulled out driver from parameter setting.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EXPERIMENTAL PARAMETERS
%
% Adaptation parameters.  The adaptor dot correlation determines
% how strong the adapting stimulus is.  The number must between 
% -1 and 1.  Negative numbers move to the left, positive numbers move
% to the right (when adaptHOrV = 0).
adaptDotCorr = 0.0;						% Adapter dot correlation
nAdaptDots = 400;							% Number of adapter dots 
adaptRectSize = 300;					% Size of adapter rectangle
adaptDotSize = 2;							% Size of adapter dots
adaptDotMove = 2;							% Controls size of dot moves, adapter
adaptHOrV = 0;								% Angle of dot motion, 0=>left/right, 90=>up/down, etc.
adaptNoRandom = 1;						% Orthogonal motion?, 1=>yes, 0=>no

% Test parameteters.  The list testDotCorrs determines what dot
% correlations you will be tested on.  The numbers must be between
% -1 and 1.  Negative numbers move to left, positive numbers move
% to the right (when testHOrV = 0).  It is wise to use a symmetric
% list and to include 0.0.
testDotCorrs = [-0.20 -0.15 -0.09 -0.06 -0.03 -0.01 0.0 0.01 0.03 0.06 0.09 0.15 0.20];
nTestDots = 400;							% Number of test dots
testRectSize = 300;						% Size of test rectangle
testDotSize = 2;							% Size of test dots
testDotMove = 2;							% Controls size of dot moves, test
testHOrV = 0;									% Angle of dot motion, 0=>left/right, 90=>up/down, etc.
testNoRandom = 1;							% Orthogonal motion?, 1=>yes, 0=>no

% Experimental parameters.
nBlocks = 8;									% Number of blocks
trialDuration = 500;					% Trial duration (milliseconds) ...
initialAdaptTime = 1;					% Time for initial adaptation (seconds)
topUpAdaptTime = 0;						% Top up adapt time (seconds)
waitKey = 0;									% Wait on trials?

adaptBgColor = [0 0 0];				% Color of adaptation background (RGB, each between 0 and 255)
testBgColor = [0 0 0];				% Color of test background (RGB, each between 0 and 255)
adaptColor = [0 0 0];					% Color of adapter dots (RGB, each between 0 and 255)
testColor = [255 0 0];				% Color of square (RGB, each between 0 and 255)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Turn off screen saver, filesharing
% AD('Off');
% FS('Off');

% Define globals
global THRESHOLD
THRESHOLD = 1;

% Call driver
MotionAfterDrvr;

% Rescale plot appropriately
axis([testDotCorrs(1) testDotCorrs(length(testDotCorrs)) 0 1]);

% Turn stuff back on
% AD('On');
% FS('On');

