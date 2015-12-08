function GammaThresholdDrvr(params)
% DotThresholdDrvr - Driver program for motion aftereffect experiment.
%
% Syntax:
% DotThresholdDrvr(params)

error(nargchk(1, 1, nargin));

% Read in the list of images.
imagePaths = rdir(params.imageDir);

% Make sure we have a positive number of gammas.
if size(params.gammas, 2) <= 0
	error('Number of gammas must be >= 0.');
end

% Convenience parameters
nImages = size(imagePaths, 1);
nGammas = size(params.gammas, 2);
nTests = nImages * nGammas;	% Number of test in each block of the experiment. There is one test for each possible gamma/image combination.

% Setup the response data.  This will store all the responses.
responseData = zeros(nTests, params.nBlocks+3);

% Get the keyboard listener ready.
mglGetKeyEvent;

% Open the experimental window and (read all of the images into memory
% maybe?)
[win, adaptPatch, testPatch] = OpenEXPWindow(params);
if (params.fpSize > 0)
    win.enableObject('fp');
end

% Eat up keyboard input.
ListenChar(2);

spacing = params.test.rectSize(1);
centerLeft = [-spacing 0];
centerRight = [spacing 0];

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
	
    startingColumn = 1;
    
	% Now run the trials.
	for i = 1:params.nBlocks
		trialOrder = Shuffle(1:nTests);
		
		for j = 1:nTests
			% Explicit trial index, as well as the indiices of the 
            % corresponding gamme and image for the trial.
			index = trialOrder(j);
			gammaIndex = mod(index, nGammas) + 1;
            imageIndex = mod(index, nImages) + 1;
            
			% Set some parameters for the test patch for this trial.
			win.BackgroundColor = params.test.bgRGB;

            % TODO(daphne): replace everything below this with stuff to
            % render the two images. THIS IS WHERE I STOPPED
            if rand() > 0.5
                testDirection = 1;
            else
                testDirection = -1;
            end
            
            if (testDirection == -1)
                testPatch.Center = centerLeft;
                adaptPatch.Center = centerRight;
            else
                testPatch.Center = centerRight;
                adaptPatch.Center = centerLeft;    
            end
            
			% Show the test dots.
			win.enableObject('testPatch');
            win.enableObject('adaptPatch');
			[testPatch, adaptPatch] = MoveBothOfTheDots(win, params, 'testPatch', 'adaptPatch', testPatch, adaptPatch, params.trialDuration);
            win.disableObject('testPatch');
			win.disableObject('adaptPatch');

			% Top-up adaptation.  Adaption dots are show a minimum
			% amount of time and proceed forever until a response is given.
			win.BackgroundColor = params.adapt.bgRGB;
			[adaptPatch, response] = MoveTheDots(win, params, 'adaptPatch', adaptPatch, ...
				params.topupAdaptTime, true);
			
			% Show the feedback if enabled.
            %
            % Feedback parameter of 1 means give feedback on direction
			if params.enableFeedback == 1
				% Stick our trial coherence and the response in an array.
				m = [params.test.dotCoherence(index), response];
				
				% Trials where both values are of the same polarity implies
				% correct trials.  But, need to special case when coherence
                % is 0, since there is no right answer for such trials.  We
                % say correct with probability 0.5 on trials where coherence
                % is 0.
                if (params.test.dotCoherence(index) == 0)
                    if (CoinFlip(1,0.5))
                        textTag = 'correctText';
                    else
                        textTag = 'incorrectText';
                    end
                else
                    if all(m < 0) || all(m > 0)
                        textTag = 'correctText';
                    else
                        textTag = 'incorrectText';
                    end
                end
				
				% Enable the appropriate feedback text.
				win.enableObject(textTag);
				
				% Move the adapation dots for the feedback duration.
				adaptPatch = MoveTheDots(win, params, 'adaptPatch', adaptPatch, ...
					params.feedbackDuration);
				
				% Turn off the feedback text.
				win.disableObject(textTag);
            
            % Feedback parameter of 2 measn give feedback on absence/presence
            % of motion
            elseif params.enableFeedback == 2
                if (testDirection == response)
                    textTag = 'correctText';
                else
                    textTag = 'incorrectText';
                end
                
                % Enable the appropriate feedback text.
				win.enableObject(textTag);
				
				% Move the adapation dots for the feedback duration.
				adaptPatch = MoveTheDots(win, params, 'adaptPatch', adaptPatch, ...
					params.feedbackDuration);
				
				% Turn off the feedback text.
				win.disableObject(textTag);      
            end
			
			% Now do the iti.
			if params.iti > 0
				adaptPatch = MoveTheDots(win, params, 'adaptPatch', adaptPatch, params.iti);
            end
				
			% Store the response.
            %fprintf('correct dir = %d, guessed dir = %d\n', testDirection, response);
			responseData(index, startingColumn) = testDirection;
            responseData(index, startingColumn+1) = response;
            %responseData
        end
        
        startingColumn = startingColumn + 2;
	end
	
	% Close everything down.
	ListenChar(0);
	win.close;
	
	% Figure out some data saving parameters.
	dataFolder = sprintf('%s/data/%s/%s/%s', fileparts(fileparts(which('DotThreshold'))), ...
		params.experimenter, params.experimentName, params.subject);
	if ~exist(dataFolder, 'dir')
		mkdir(dataFolder);
	end
	dataFile = sprintf('%s/%s-%d.csv', dataFolder, params.experimentName, GetNextDataFileNumber(dataFolder, '.csv'));
	
	% Stick the data into a CSV file in the data folder..
	c = CSVFile(dataFile, true);
	c = c.addColumn('Coherence', 'g');
	c = c.setColumnData('Coherence', params.test.dotCoherence');
    
    i = 1;
    trial = 1;
	while i < params.nBlocks * 2;
		cName = sprintf('Correct Direction %d', trial);
		c = c.addColumn(cName, 'd');
		c = c.setColumnData(cName, responseData(:,i));
        
        cName = sprintf('Perceived Direction %d', trial);
		c = c.addColumn(cName, 'd');
		c = c.setColumnData(cName, responseData(:,i+1));
        
        i = i + 2;
        trial = trial + 1;
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
