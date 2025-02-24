function GammaThreshold(subjectName)
% DotThreshold - Program to measure psychometric function for direction of dot movement.
%
% Syntax:
% DotThreshold
%
% Description:
% Program to measure psychometric function for direction of dot movement.
% The program uses the method of constant stimuli.
%
% The program also allows one to play "adapting" dots in between the trials.
% This can be used to measure a motion aftereffect, which will show up as
% a shift of the psychometric function.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EXPERIMENTAL PARAMETERS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Test parameteters.  These determine the properties of the test stimuli.
params.imageDir = 'test_images';         % The location of the photos
%params.gammas = logspace(0, 1, 30) / 10 + 1; % Gamma values to darken the image.
%params.gammas = logspace(0, 1, 30) / 10; % Gamma values to lighten the image.

params.gammasBelow = log(linspace(exp(1),exp(2.199),20));             % The different gamma values to test out.
params.startingGammaBelowIndex = 1; %floor(size(params.gammasBelow,2) / 2);
params.gammasAbove = fliplr(log(linspace(exp(2.201),exp(3.4),20)));
params.startingGammaAboveIndex = 1; %floor(size(params.gammasAbove,2) / 1);

params.imageScale = 0.2;                % Use this for giant images to scale them down.
params.deGamma = true;

params.imageSaveFile = 'images.mat';

addpath(params.imageDir);

params.spacing = 100;                    % How much spacing to put between the two images.
params.bgRGB = [0,0,0];                 % The background color.

% Experimental parameters.
params.nTrials = 300;                   % This is the total number of trials to be shown. The trials shown are chosen randomly from the possible trials that could be shown.
params.trialDuration = 0.5;				% Trial duration (seconds)
params.initialAdaptTime = 1;			% Time for initial adaptation (seconds)
params.topupAdaptTime = 0.3;			% Top-up adapt time. (seconds)
params.enableFeedback = 1;				% Enable/disable trial feedback
                                        %   0 -> no feedback
                                        %   1 -> feedback
params.feedbackDuration = 10;			% Duration of feedback (seconds)
params.iti = 0.5;						% Inter-trial interval (seconds)

% Fixation point
params.fpSize = 4;                      % Fixation point size in pixels (0 -> no fixation point)
params.fpColor = [0 1 0];               % Fixation point RGB

% Key mappings
params.leftKey = {'d' '1'};             % Keys accepted for left/up/absent response
params.rightKey = {'k' '2'};            % Keys accepted for right/down/present response

params.experimenter = 'test';          % Experimenter
params.subject = subjectName;           % Name of the subject.
params.experimentName = sprintf('GammaThreshold'); % Root name of the experiment and data file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Call the driver.
GammaThresholdDrvr(params);
