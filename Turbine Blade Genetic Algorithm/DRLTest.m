% Test the trained agent
numTestSteps = 100;
obs = reset(env);

for step = 1:numTestSteps
    % Get action from the trained agent
    action = getAction(trainedAgent, obs);

    % Step through the environment
    [obs, reward, isDone] = step(env, action);

    % Optionally log results or visualize
    fprintf('Step %d: Reward = %.4f\n', step, reward);

    if isDone
        break;
    end
end
