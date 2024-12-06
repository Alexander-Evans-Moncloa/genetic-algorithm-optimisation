clc;
clear all;
close all;

% Initialise parameters (paths, names, etc.)
InitialiseScript;

% Define observation space (state) and action space
numVars = 4; % [Root Twist, Tip Twist, Root Chord, Tip Chord]
observationInfo = rlNumericSpec([numVars, 1], ...
    'LowerLimit', [20; 0; 0.1; 0.1], ...
    'UpperLimit', [30; 10; 0.5; 0.5]);
observationInfo.Name = 'Rotor Parameters'; % Name of the observation
observationInfo.Description = 'Root Twist, Tip Twist, Root Chord, Tip Chord';

actionInfo = rlNumericSpec([numVars, 1], ...
    'LowerLimit', [20; 0; 0.1; 0.1], ...
    'UpperLimit', [30; 10; 0.5; 0.5]);
actionInfo.Name = 'Action Parameters';

% Define the number of actions (which should be the same size as numVars)
numActions = numVars; % Since action space has same size as observation space

% Define environment using custom step and reset functions
env = rlFunctionEnv(observationInfo, actionInfo, ...
    @stepFunction, @resetFunction);

% Define critic network
criticNetwork = [
    featureInputLayer(numVars, "Normalization", "none", "Name", "state")
    fullyConnectedLayer(128, "Name", "fc1")
    reluLayer("Name", "relu1")
    fullyConnectedLayer(128, "Name", "fc2")
    reluLayer("Name", "relu2")
    fullyConnectedLayer(1, "Name", "output")];
criticOptions = rlRepresentationOptions('LearnRate', 1e-3, 'GradientThreshold', 1);
critic = rlValueRepresentation(criticNetwork, observationInfo, 'Observation', {'state'}, criticOptions);

% Define actor network
actorNetwork = [
    featureInputLayer(numVars, "Normalization", "none", "Name", "Rotor Parameters") % Input layer (state)
    fullyConnectedLayer(128, "Name", "fc1")  % First hidden layer
    reluLayer("Name", "relu1")  % ReLU activation for the first hidden layer
    fullyConnectedLayer(128, "Name", "fc2")  % Second hidden layer
    reluLayer("Name", "relu2")  % ReLU activation for the second hidden layer
    fullyConnectedLayer(numActions, "Name", "act")  % Output layer with the number of actions
    softmaxLayer("Name", "softmax")  % Softmax to convert output to probabilities
];

% Create layer graph from the actor network
actorLayerGraph = layerGraph(actorNetwork);

% Create the stochastic actor representation correctly
actor = rlStochasticActorRepresentation(actorLayerGraph, observationInfo, actionInfo);

% Define DDPG agent
agentOptions = rlDDPGAgentOptions('SampleTime', 0.1, ...
    'DiscountFactor', 0.99, 'MiniBatchSize', 64, 'ExperienceBufferLength', 1e6);
agent = rlDDPGAgent(actor, critic, agentOptions);

% Train the agent
trainOpts = rlTrainingOptions('MaxEpisodes', 100, ...
    'MaxStepsPerEpisode', 50, ...
    'StopTrainingCriteria', 'AverageReward', ...
    'StopTrainingValue', -1e-3, ...
    'Verbose', true, ...
    'Plots', 'training-progress');
train(agent, env, trainOpts);

% Step function
function [nextObs, reward, isDone, loggedSignals] = stepFunction(action, loggedSignals)
    % Extract action variables
    rootTwist = action(1);
    tipTwist = action(2);
    rootChord = action(3);
    tipChord = action(4);

    % Constraints: Ensure valid design
    if rootTwist <= tipTwist || rootChord <= tipChord
        reward = -Inf; % Invalid design
        isDone = true;
        nextObs = action; % Same observation
        return;
    end

    % Access simulation parameters
    Params = loggedSignals.Params;

    % Generate twist and chord distributions
    twistDist = linspace(rootTwist, tipTwist, Params.twistResolution)';
    chordDist = linspace(rootChord, tipChord, Params.twistResolution)';

    % Run simulation
    try
        [rotor, ~] = runSIM(Params, twistDist, chordDist, Params.Foils, Params.foilsDist, Params.numBlades);
        % Reward is the maximum Cp (negative for minimisation)
        [reward, ~] = max(rotor.CP);
        reward = -reward; % Convert to minimisation
    catch ME
        warning("Error in runSIM: %s", ME.message);
        reward = -Inf; % Penalise for failure
    end

    % Continue exploration
    isDone = false;
    nextObs = action; % Update observation
end

% Reset function
function [initialObs, loggedSignals] = resetFunction()
    % Initial state observation
    initialObs = [25; 5; 0.3; 0.3]; % Root Twist, Tip Twist, Root Chord, Tip Chord
    
    % Simulation parameters
    loggedSignals.Params = struct( ...
        'numBlades', 3, ...            % Number of blades
        'Foils', 'S1210', ...          % Single airfoil type as string
        'foilsDist', ones(1, 25), ...  % Airfoil distribution
        'twistResolution', 25 ...      % Twist resolution
    );
end
