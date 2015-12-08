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
params.imageDir = 'exp_images';             % The location of the photos
params.gammas = [0.5, 0.7];

% Experimental parameters.
params.nBlocks = 10;                    % Number of blocks
params.trialDuration = 1.0;				% Trial duration (seconds)
params.initialAdaptTime = 1;			% Time for initial adaptation (seconds)
params.topupAdaptTime = 0.3;			% Top-up adapt time. (seconds)
params.enableFeedback = 2;				% Enable/disable trial feedback
                                        %   0 -> no feedback
                                        %   1 -> feedback on direction
                                        %   2 -> feedback on motion vs non-motion
params.feedbackDuration = 0.3;			% Duration of feedback (seconds)
params.iti = 0.5;						% Inter-trial interval (seconds)

% Fixation point
params.fpSize = 4;                      % Fixation point size in pixels (0 -> no fixation point)
params.fpColor = [0 1 0];               % Fixation point RGB

% Key mappings
params.leftKey = {'d' '1'};             % Keys accepted for left/up/absent response
params.rightKey = {'k' '2'};            % Keys accepted for right/down/present response

params.experimenter = 'TAFC';          % Experimenter
params.subject = subjectName;           % Name of the subject.
params.experimentName = sprintf('GammeThreshold'); % Root name of the experiment and data file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Call the driver.
GammaThresholdDrvr(params);
