clc;
clear;

% Ensure GPU is available
if gpuDeviceCount == 0
    error('No GPU device found. Ensure a compatible GPU is installed.');
else
    disp('GPU device detected. Utilising GPU for computation.');
end

% Start a parallel pool if none exists
if isempty(gcp('nocreate'))
    parpool; % Default pool based on available CPU cores
    disp('Parallel pool started.');
else
    disp('Parallel pool already active.');
end

% Load Initialisation Script
InitialiseScript; % Ensure this script is in the same directory or path

% Define number of blade segments
numSegments = 50; % Number of blade segments (adjust as needed)

% Define Genetic Algorithm bounds
% [minTwistStart, maxTwistStart, minChordStart, maxChordEnd]
lb = [0, 5, 0.1, 0.2];  % Twist (deg), Chord (m)
ub = [10, 15, 0.3, 0.4]; % Twist (deg), Chord (m)

% Define objective function
objFunc = @(X) optimiseBladeGPU(X, Params, numSegments);

% Genetic Algorithm Options
options = optimoptions('ga', ...
    'UseParallel', true, ...  % Enables parallel computation
    'UseVectorized', false, ...  % Ensures function evaluations are not vectorized
    'PlotFcn', {@gaplotpareto, @gaplotscorediversity}, ...
    'Display', 'iter', ...
    'MaxGenerations', 200, ... % Increase generations to explore more
    'PopulationSize', 300, ...  % Increase population size for diversity
    'EliteCount', 20, ...       % Keep the best solutions to avoid losing quality
    'SelectionFcn', @selectiontournament, ...  % Change selection function for diversity
    'FunctionTolerance', 1e-6, ... % Ensure convergence is strict
    'MutationFcn', {@mutationuniform, 0.2}, ... % Mutation rate set to 0.2
    'CrossoverFcn', @crossoversinglepoint); % Default crossover function

% Run Genetic Algorithm
[X, F] = ga(objFunc, 4, [], [], [], [], lb, ub, [], options); % Ensure no nonlcon is passed

% Display Results
disp('Optimal Twist and Chord Values:');
disp(X);

disp('Objective Function Values (Max Cp):');
disp(F);

%% Objective Function with GPU Utilisation
function F = optimiseBladeGPU(X, Params, numSegments)
    % Move parameters to GPU
    X = gpuArray(X);

    % Define twist and chord distributions
    newTwist = gpuArray(linspace(X(1), X(2), numSegments)'); % Twist distribution
    newChord = gpuArray(generateChordDistribution(X(3), X(4), numSegments)); % Modified Chord distribution

    % Run simulation on GPU
    [rotor, ~] = runSIMGPU(Params, newTwist, newChord);

    % Check rotor outputs
    if ~isfield(rotor, 'CP') || isempty(rotor.CP)
        error('Simulation did not return CP. Check runSIMGPU implementation.');
    end

    % Define the objective as a scalar value
    rotorCP = gather(rotor.CP); % Transfer results back to CPU
    maxCP = max(rotorCP); % Max Cp is our primary objective
    stdCP = std(rotorCP); % Standard deviation to penalise irregular performance
    
    % Combine both objectives into a single scalar value (weighted sum)
    weight1 = 1;  % Weight for maximum Cp
    weight2 = 0.5; % Weight for standard deviation (penalisation)
    
    % Minimise negative max CP and standard deviation
    F = -weight1 * maxCP + weight2 * stdCP; % Combine objectives into one scalar value
end


%% Generate Chord Distribution with Peak at Base and Thinness at Tip
function chordDist = generateChordDistribution(minChord, maxChord, numSegments)
    % Define chord distribution (parabolic or exponential)
    r = linspace(0, 1, numSegments);  % Radial positions from root to tip
    chordDist = minChord + (maxChord - minChord) * (1 - r.^2); % Parabolic decay (modify for different profiles)
end

%% GPU-Compatible Simulation Function
function [rotor, blade] = runSIMGPU(Params, newTwist, newChord)
    % Simulate rotor performance
    % Replace with your actual GPU-accelerated simulation logic

    % Example outputs (replace with actual simulation code)
    numCases = 100; % Number of test cases
    rotor.CP = gpuArray(sin(linspace(0, 2 * pi, numCases)) + 0.5); % Example CP values
    blade = struct(); % Example blade data

    % Add GPU-compatible computation logic for aerodynamic simulations here
    % If possible, implement `runSIM` logic with GPU arrays
end
