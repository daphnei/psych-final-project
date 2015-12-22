function [ updatedTrialHistory, updatedIndex ] = updateTrialHistory( trialHistory, currentIndex, maxIndex, isCorrectResponse)

FAKE = 0;
CORRECT = 1;
INCORRECT = 2;

if isCorrectResponse          
     updatedTrialHistory = horzcat(trialHistory, CORRECT);
     historySize = length(trialHistory);
     % two correct in a row, become harder
     if  historySize > 1 && trialHistory(historySize) == CORRECT && trialHistory(historySize - 1) == CORRECT
         updatedTrialHistory = horzcat(trialHistory, FAKE);
         updatedIndex = min(currentIndex + 1, maxIndex);
     else
         updatedIndex = max(currentIndex - 1, 1); 
     end
 else % one incorrect, become easier
     updatedTrialHistory = horzcat(trialHistory, INCORRECT);
     updatedIndex = max(currentIndex - 1, 1);
 end
end

