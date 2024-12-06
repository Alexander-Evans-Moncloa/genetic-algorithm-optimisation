clc
clear all
close all

% Initialise the script
InitialiseScript;

% Define the number of segments
numSegments = 25;

% Define the objective function
f = @(X) objFunc(X, Params, numSegments);

% Define the lower and upper bounds for the optimisation variables
lb = [0, 0];  % Minimum root and tip twist angles (in degrees)
ub = [15, 15]; % Maximum root and tip twist angles (in degrees)

% Set options for the genetic algorithm
options = optimoptions('gamultiobj', 'Display', 'iter', 'PlotFcn', @gaplotpareto);

% Run the genetic algorithm
[X_opt, F_val] = gamultiobj(f, 2, [], [], [], [], lb, ub, [], options);

% Display the optimal root and tip twist angles
disp('Optimal Root and Tip Twist Angles:');
disp(X_opt);

% Objective function for the genetic algorithm
function F = objFunc(X, Params, numSegments)
    % Input: X(1) is the root twist angle, X(2) is the tip twist angle

    % Generate the linear twist distribution
    newTwist = linspace(X(1), X(2), numSegments)'; % Linearly interpolated twist

    % Create a constant chord distribution (for simplicity)
    newChord = ones(numSegments, 1) * 0.2;

    % Define other parameters
    numBlades = 3; % Number of blades
    Foils = {'S826'}; % Aerofoil
    foilsDist = ones(1, numSegments); % Uniform aerofoil distribution

    % Submit the simulation and read results
    [rotor, blade] = runSIM(Params, newTwist, newChord, Foils, foilsDist, numBlades);

    % Objective: Maximise power coefficient (CP)
    [maxCP, I] = max(rotor.CP);
    F(1) = -maxCP; % Negate to convert to minimisation problem

    % Optional: Add another objective, e.g., minimising material usage
    F(2) = mean(newChord); % Example: average chord length
end
