function GammaThresholdDrvr(params)
% DotThresholdDrvr - Driver program for motion aftereffect experiment.
%
% Syntax:
% GammaThresholdDrvr(params)

error(nargchk(1, 1, nargin));

% Read in the list of images.
imagePaths = rdir(sprintf('%s/**/*.jpg', params.imageDir));
if isempty(imagePaths)
    error('Error: Make sure that image directory has been added to the path.\n');
end

% Read the contents of each image into memory now, so that we don't slow
% down the experiment later.
if exist(params.imageSaveFile, 'file') ~= 2
    tic
    for i = 1:size(imagePaths, 1)
        image = imread(imagePaths(i).name);
        if size(image, 2) > 500
            image = imresize(image, params.imageScale);
        end
        images{i} = flipdim(double(image), 1) ./ 255;
    end
    save(params.imageSaveFile, 'images');
    toc
else
    tic
    load(params.imageSaveFile);
    toc
end

% Convenience parameters
nImages = size(imagePaths, 1);
nGammas = length(params.gammasBelow) + length(params.gammasAbove);
nTests = nImages * nGammas;	% Number of tests that could possibly be shown. There is one test for each possible gamma/image combination.

% Setup the response data.  This will store all the responses.
% Col 1: Gamma value
% Col 2: 1 if face photo, 0 if nature photo
% Col 3: 1 if user gets trial correct, 0 otherwise
responseData = zeros(params.nTrials, 3);

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
    
    
    maxGammaBelowIndex = length(params.gammasBelow);
    maxGammaAboveIndex = length(params.gammasAbove);
    
    % Now run the trials.
    trialOrder = Shuffle(1:nTests);
    currentGammaBelowIndex = params.startingGammaBelowIndex;
    currentGammaAboveIndex = params.startingGammaAboveIndex;
    
    trialHistoryBelow = [];
    trialHistoryAbove = [];
    
    isAbove = rand(nTests, 1) > 0.5;
    
    for j = 1:params.nTrials
        % Explicit trial index, as well as the indiices of the
        % corresponding gamma and image for the trial.
        index = trialOrder(j);
        imageIndex = mod(index, nImages) + 1;
        
        theImage = images{imageIndex};
        
        % This is a horrible hack to figure out what type of image it is.
        isFaceImage = (size(theImage, 1) == 250 && size(theImage, 2) == 250);
        
        % TODO: Perform some modification on theGammaAdjustedImage to
        % actually do the gamma adjusting.
        if params.deGamma
            theGammaAdjustedImage = theImage .^ (1/2.2);
        else
            theGammaAdjustedImage = theImage;
        end
        
        if isAbove(j)
            gamma = params.gammasAbove(currentGammaAboveIndex);
            display(sprintf('Gamma ABOVE: %d\n', currentGammaAboveIndex));
        else
            gamma = params.gammasBelow(currentGammaBelowIndex);
            display(sprintf('Gamma BELOW: %d\n', currentGammaBelowIndex));
        end
        
        theGammaAdjustedImage = theGammaAdjustedImage .^ gamma;
        
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
        win.addImage(theImagePosition, [imageWidth, imageHeight], ...
            theImage, 'Name', 'theImage');
        win.addImage(theGammaAdjustedImagePosition, [imageWidth, imageHeight], ...
            theGammaAdjustedImage, 'Name', 'theGammaAdjustedImage');
        
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
        
        % update the history based on which side was ran
        isCorrectResponse = response == testDirection;
        if isAbove(j)
            display('CORRECT');
            [trialHistoryAbove, currentGammaAboveIndex] = updateTrialHistory(trialHistoryAbove, currentGammaAboveIndex, maxGammaAboveIndex, isCorrectResponse);
        else
            display('  WRONG');
            [trialHistoryBelow, currentGammaBelowIndex] = updateTrialHistory(trialHistoryBelow, currentGammaBelowIndex, maxGammaBelowIndex, isCorrectResponse);
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
            display(sprintf('Response = %d, testDirection = %d', response, testDirection));
            
            if response == testDirection
                textTag = 'correctText';
            else
                textTag = 'incorrectText';
            end
            
            % Enable the appropriate feedback text.
            win.enableObject(textTag);
            win.draw();
            
            % Could wait for the user to press a button to indicate
            % thet are readt to move on, but instead we will just put
            % it on a timer.
            %WaitForResponse(win, params, params.trialDuration);
            pause(params.trialDuration);
            
            % Turn off the feedback text.
            win.disableObject(textTag);
        end
        
        % Store the response.
        % Col 1: Gamma value
        % Col 2: 1 if face photo, 0 if nature photo
        % Col 3: 1 if user gets trial correct, 0 otherwise
        responseData(j, :) = [gamma, isFaceImage, response == testDirection];

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
    c = c.addColumn('Gamma', 'g');
    c = c.setColumnData('Gamma', responseData(:, 1));
    
    c = c.addColumn('IsFace', 'g');
    c = c.setColumnData('IsFace', responseData(:, 2));
   
    c = c.addColumn('CorrectResponse', 'g');
    c = c.setColumnData('CorrectResponse', responseData(:, 3));
    
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
