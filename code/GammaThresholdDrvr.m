function GammaThresholdDrvr(params)
% DotThresholdDrvr - Driver program for motion aftereffect experiment.
%
% Syntax:
% GammaThresholdDrvr(params)

FAKE = 0;
CORRECT = 1;
INCORRECT = 2;

error(nargchk(1, 1, nargin));

% Read in the list of images.
imagePaths = rdir(params.imageDir);

% Read the contents of each image into memory now, so that we don't slow
% down the experiment later.
for i = 1:size(imagePaths, 1)
    image = imread(imagePaths(i).name);
    image = imresize(image, params.imageScale);
    images{i} = flipdim(double(image), 1) ./ 255;
end

% Make sure we have a positive number of gammas.
if size(params.gammas, 2) <= 0
	error('Number of gammas must be >= 0.');
end

% Convenience parameters
nImages = size(imagePaths, 1);
nGammas = size(params.gammas, 2);
nTests = nImages * nGammas;	% Number of tests in each block of the experiment. There is one test for each possible gamma/image combination.

% Setup the response data.  This will store all the responses.
responseData = zeros(nTests, params.nBlocks);
startingColumn = 1;

% Get the keyboard listener ready.
mglGetKeyEvent;

% Open the experimental window and (read all of the images into memory
% maybe?)
win = OpenEXPWindow(params);
if (params.fpSize > 0)
    win.enableObject('fp');
end

% Eat up keyboard input.
ListenChar(2);

try	
	% Clear out any previous keypresses.
	FlushEvents;
	
	% Show the adaptation dots and wait for a keypress to start.
    win.enableObject('startText');
	win.draw;
	
	% This will block until a key is pressed.
	FlushEvents;
	GetChar;
    win.disableObject('startText');
    
	display('Starting the trials.');
    
    startingColumn = 1;
    
    
	% Now run the trials.
	for i = 1:params.nBlocks
		trialOrder = Shuffle(1:nTests);
        trialHistory = [];
        maxGammaIndex = length(params.gammas);
        currentGammaIndex = params.startingGammaIndex;
        
		for j = 1:nTests
			% Explicit trial index, as well as the indiices of the 
            % corresponding gamme and image for the trial.
			index = trialOrder(j);
            imageIndex = mod(index, nImages) + 1;
            
            theImage = images{imageIndex};
            gamma = params.gammas(currentGammaIndex);

            % TODO: Perform some modification on theGammaAdjustedImage to
            % actually do the gamma adjusting.
            if params.deGamma
                hGamma = vision.GammaCorrector(2.2, 'Correction', 'De-gamma');
                theGammaAdjustedImage = step(hGamma, theImage);
            end
            
            hGamma = vision.GammaCorrector(gamma, 'Correction', 'Gamma');
            theGammaAdjustedImage = step(hGamma, theGammaAdjustedImage);
            % Make sure none of the values in the gamma adjusted image are
            % larger than 1.
            theGammaAdjustedImage = min(theGammaAdjustedImage, 1);

            imageWidth = size(theImage, 2);
            imageHeight = size(theImage, 1);
            spacing = (imageWidth + params.spacing) / 2;
            
			% Set some parameters for the test patch for this trial.
			win.BackgroundColor = params.bgRGB;
            
            % randomly decide whether to present the gamma-adjusted on the
            % left or on the right.
            if rand() > 0.5
                testDirection = 1;
                theImagePosition = [spacing, 0];
                theGammaAdjustedImagePosition = [-spacing, 0];
            else
                testDirection = -1;
                theImagePosition = [-spacing, 0];
                theGammaAdjustedImagePosition = [spacing, 0];
            end
                        
            % Create objects for the unmodified image and the
            % Gamma-adjusted image.
            tic
            win.addImage(theImagePosition, [imageWidth, imageHeight], ...
                theImage, 'Name', 'theImage');
            win.addImage(theGammaAdjustedImagePosition, [imageWidth, imageHeight], ...
                theGammaAdjustedImage, 'Name', 'theGammaAdjustedImage');
            toc
            
            win.enableObject('theImage');
            win.enableObject('theGammaAdjustedImage');
            
            win.draw();
            
			% Show the test dots.
			response = WaitForResponse(win, params, params.trialDuration);

            win.disableObject('theImage');
            win.deleteObject('theImage');
			
            win.disableObject('theGammaAdjustedImage');
            win.deleteObject('theGammaAdjustedImage');
            
            % Redraw the screen to remove the stimulus images.
            win.draw();

            if response == testDirection          
                trialHistory = horzcat(trialHistory, CORRECT);   
                historySize = length(trialHistory);
               if  historySize > 1 && trialHistory(historySize) == CORRECT && trialHistory(historySize - 1) == CORRECT
                  trialHistory = horzcat(trialHistory, FAKE);
                  currentGammaIndex = min(currentGammaIndex + 1, maxGammaIndex);
               end            
            else
                trialHistory = horzcat(trialHistory, INCORRECT);
                currentGammaIndex = max(currentGammaIndex - 1, 1);               
            end
            % The following is the code that tells the user if they are
            % right or wrong. I am not sure if we want to continue doing
            % this or not.
            if params.enableFeedback
                % Trials where both values are of the same polarity implies
                % correct trials.  But, need to special case when coherence
                % is 0, since there is no right answer for such trials.  We
                % say correct with probability 0.5 on trials where coherence
                % is 0.
                if response == testDirection
                    textTag = 'correctText';
                else
                    textTag = 'incorrectText';
                end

                % Enable the appropriate feedback text.
                win.enableObject(textTag);
                win.draw();
                
                % Wait for the user to press a button indicating they are
                % ready to keep going.
                WaitForResponse(win, params, params.trialDuration);
                
                % Turn off the feedback text.
                win.disableObject(textTag);
            end
        
            % Store the response.
            % Store 1 if the response is -1 and the unmodified image is on the left
            % Store 1 if the response is 1 and the unmodified image is on the right
            % Store -1 if the response is not the direction of the unmodified image
            if (response == testDirection)
                responseData(index, startingColumn) = 1;
            else
                responseData(index, startingColumn) = -1;
            end
        end
        startingColumn = startingColumn + 1;
	end
	
	% Close everything down.
	ListenChar(0);
	win.close;
	
	% Figure out some data saving parameters.
	dataFolder = sprintf('%s/data/%s/%s/%s', fileparts(fileparts(which('GammaThreshold'))), ...
		params.experimenter, params.experimentName, params.subject);
	if ~exist(dataFolder, 'dir')
		mkdir(dataFolder);
	end
	dataFile = sprintf('%s/%s-%d.csv', dataFolder, params.experimentName, GetNextDataFileNumber(dataFolder, '.csv'));
	
	% Stick the data into a CSV file in the data folder..
	c = CSVFile(dataFile, true);
	c = c.addColumn('Image', 'g');
	c = c.setColumnData('Image', {imagePaths.name});
    
    c = c.addColumn('Gamma', 'g');
	c = c.setColumnData('Gamma', params.gammas');
    
    i = 1;
	while i < params.nBlocks;
		cName = sprintf('Choice %d', i);
		c = c.addColumn(cName, 'd');
		c = c.setColumnData(cName, responseData(:,i));
        
        i = i + 2;
	end
	c.write;
	
catch e
	ListenChar(0);
	win.close;
	
	if strcmp(e.message, 'abort')
		fprintf('- Experiment aborted, nothing saved.\n');
	else
		rethrow(e);
	end
end
