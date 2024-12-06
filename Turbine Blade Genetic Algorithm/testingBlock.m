% Test the reset function
[initialObs, loggedSignals] = resetFunction();

% Test the step function with dummy actions
action = [25; 5; 0.3; 0.3];
[nextObs, reward, isDone, loggedSignals] = stepFunction(action, loggedSignals);
disp(nextObs);
disp(reward);
disp(isDone);
