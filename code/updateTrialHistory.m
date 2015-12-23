function [ updatedTrialHistory, updatedIndex ] = updateTrialHistory( trialHistory, currentIndex, maxIndex, isCorrectResponse)

FAKE = 0;
CORRECT = 1;
INCORRECT = 2;

updatedTrialHistory = trialHistory;
updatedIndex = currentIndex;

if isCorrectResponse          
     updatedTrialHistory = horzcat(trialHistory, CORRECT);
     historySize = length(updatedTrialHistory);
     % two correct in a row, become harder
     if  historySize > 1 && updatedTrialHistory(historySize) == CORRECT && updatedTrialHistory(historySize - 1) == CORRECT
         updatedTrialHistory = horzcat(updatedTrialHistory, FAKE);
         updatedIndex = min(currentIndex + 1, maxIndex);
     end
 else % one incorrect, become easier
     updatedTrialHistory = horzcat(trialHistory, INCORRECT);
     updatedIndex = max(currentIndex - 1, 1);
 end
end

