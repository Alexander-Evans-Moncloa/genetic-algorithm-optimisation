% Debugged and Optimised Code
clc;
clear;

% Load Initialization Script
InitialiseScript; % Ensure this script is in the same directory or path

% Define number of segments
numSegments = 50; % Number of blade segments (adjust as needed)

% Define Genetic Algorithm bounds
% Twist bounds [minTwistStart, maxTwistStart, minTwistEnd, maxTwistEnd]
% Chord bounds [minChordStart, maxChordStart, minChordEnd, maxChordEnd]
lb = [0, 5, 0.1, 0.2];
ub = [10, 15, 0.3, 0.4];

% Define objective function
objFunc = @(X) optimiseBlade(X, Params, numSegments);

parpool('local');

% Genetic Algorithm Options
options = optimoptions('gamultiobj', ...
    'UseParallel', true, ... % Parallel computation for faster runtime
    'PlotFcn', {@gaplotpareto, @gaplotscorediversity}, ...
    'Display', 'iter', ...
    'MaxGenerations', 100, ...
    'PopulationSize', 200);

% Run Genetic Algorithm
[X, F] = gamultiobj(objFunc, 4, [], [], [], [], lb, ub, options);

% Display Results
disp('Optimal Twist and Chord Values:');
disp(X);

disp('Objective Function Values (e.g., CP):');
disp(F);

% Objective Function Definition
function F = optimiseBlade(X, Params, numSegments)
    % Define twist and chord distributions
    newTwist = linspace(X(1), X(2), numSegments)'; % Twist distribution
    newChord = linspace(X(3), X(4), numSegments)'; % Chord distribution

    % Run simulation
    [rotor, ~] = runSIM(Params, newTwist, newChord);

    % Check rotor outputs
    if ~isfield(rotor, 'CP') || isempty(rotor.CP)
        error('Simulation did not return CP. Check runSIM implementation.');
    end

    % Define objectives
    F(1) = -max(rotor.CP); % Maximising CP (converted to minimisation)
    F(2) = std(rotor.CP); % Minimising standard deviation for efficiency
end

% Simulation Function Placeholder
function [rotor, blade] = runSIM(Params, newTwist, newChord)
    % Simulate rotor performance
    % Replace with your actual simulation logic
    % Example outputs (use your real logic here)
    rotor.CP = sin(linspace(0, 2 * pi, 100)) + 0.5; % Example CP values
    blade = struct(); % Example blade data
end
