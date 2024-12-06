% Load or define parameters
InitialiseScript; % Load Params

% Create custom environment
env = WindTurbineEnv(Params);

% Define the observation and action spaces
obsInfo = env.getObservationInfo();
actInfo = env.getActionInfo();

parpool('local', 2);

% Create the actor network
statePath = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'fc3')
];
actor = rlDeterministicActorRepresentation(statePath, obsInfo, actInfo, ...
    'Observation', {'state'}, 'Action', {'fc3'});

% Create the critic network
statePath = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
    fullyConnectedLayer(128, 'Name', 'state_fc1')
    reluLayer('Name', 'state_relu1')
];

actionPath = [
    featureInputLayer(actInfo.Dimension(1), 'Normalization', 'none', 'Name', 'action')
    fullyConnectedLayer(128, 'Name', 'action_fc1')
];

commonPath = [
    additionLayer(2, 'Name', 'add')
    reluLayer('Name', 'common_relu')
    fullyConnectedLayer(64, 'Name', 'common_fc1')
    reluLayer('Name', 'common_relu2')
    fullyConnectedLayer(1, 'Name', 'critic_output')
];

criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork, actionPath);
criticNetwork = addLayers(criticNetwork, commonPath);
criticNetwork = connectLayers(criticNetwork, 'state_relu1', 'add/in1');
criticNetwork = connectLayers(criticNetwork, 'action_fc1', 'add/in2');

% Critic representation
critic = rlQValueRepresentation(criticNetwork, obsInfo, actInfo, ...
    'Observation', {'state'}, 'Action', {'action'});

% DDPG agent options
agentOptions = rlDDPGAgentOptions(... 
    'SampleTime', 0.1, ...
    'TargetSmoothFactor', 1e-3, ...
    'ExperienceBufferLength', 1e6, ...
    'MiniBatchSize', 64);

% Create the DDPG agent
agent = rlDDPGAgent(actor, critic, agentOptions);

% Enable GPU for actor and critic representations
if canUseGPU
    actor.Options.UseDevice = 'gpu';
    critic.Options.UseDevice = 'gpu';
end


% Training options
trainOpts = rlTrainingOptions(... 
    'MaxEpisodes', 500, ...
    'MaxStepsPerEpisode', 100, ...
    'StopTrainingCriteria', 'AverageReward', ...
    'StopTrainingValue', -0.1, ...
    'UseParallel', true, ...
    'SaveAgentCriteria', 'EpisodeReward', ...
    'SaveAgentValue', -0.1, ...
    'Plots', 'training-progress');

% Train the agent
trainedAgent = train(agent, env, trainOpts);
