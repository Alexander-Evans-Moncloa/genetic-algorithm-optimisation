clc
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript % Runs initialisation script for file paths and names

% Objective function
f = @(X) objFunc(X, Params);

% Implement genetic algorithm optimisation
% Optimising exponential coefficient for twist (X(1)) in range [0, 1],
% exponential coefficient for chord (X(2)) in range [0, 1],
% root twist (X(3)) in range [10, 30], and root chord (X(4)) in range [0.1, 0.5]
lb = [0, 0, 10, 0.1]; % Lower bounds
ub = [1, 1, 30, 0.5]; % Upper bounds
nVars = 4;             % Number of variables (twist coefficient, chord coefficient, root twist, root chord)

% Enable parallel processing in GA options
options = optimoptions('ga', ...
    'Display', 'iter', ...
    'MaxGenerations', 30, ... % Increase number of generations for better convergence
    'PopulationSize', 50); % Increase population size

[X, fval] = ga(f, nVars, [], [], [], [], lb, ub, [], options);

disp('Optimal values found:');
disp(['Twist Coefficient: ', num2str(X(1))]);
disp(['Chord Coefficient: ', num2str(X(2))]);
disp(['Root Twist: ', num2str(X(3)), ' degrees']);
disp(['Root Chord: ', num2str(X(4)), ' meters']);
disp(['Maximum C_P: ', num2str(-fval)]);

databaseConnect(db_path, projectFilePath, 'Disconnect')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Objective Function
function F = objFunc(X, Params)
    % Define number of blades and aerofoil distribution
    numBlades = 3; % Number of blades on rotor
    Foils = {'S1210'}; % Specifies aerofoils to be used (must match name in Ashes aerofoil database)
    foilsDist = [ones(1, 25)]; % Specifies aerofoil distribution based on Foils index
    
    % Exponential distribution for twist and chord
    r = linspace(0, 1, 25)'; % Non-dimensional blade radius
    twistDist = X(3) * exp(-X(1) * r); % Exponential twist distribution
    chordDist = X(4) * exp(-X(2) * r); % Exponential chord distribution

    % Ensure constraints: twist and chord values decrease along the blade
    if any(diff(twistDist) > 0) || any(diff(chordDist) > 0)
        F = Inf; % Penalise invalid configurations
        return;
    end

    % Submit the simulation and read the results
    [rotor, blade] = runSIM(Params, twistDist, chordDist, Foils, foilsDist, numBlades);

    % Objective: Maximize C_P (minimize -C_P)
    [F, I] = max(rotor.CP); % I is load case index that produced max power
    F = -F; % Convert to minimisation
    disp(['Twist Coefficient: ', num2str(X(1))]);
    disp(['Chord Coefficient: ', num2str(X(2))]);
    disp(['Root Twist: ', num2str(X(3)), ' degrees']);
    disp(['Root Chord: ', num2str(X(4)), ' meters']);
    disp(['Maximum C_P: ', num2str(max(rotor.CP))]);

    % Track maximum rotor.CP across generations
    persistent maxCPHistory; % Store maxCP across iterations
    if isempty(maxCPHistory)
        maxCPHistory = []; % Initialise on first call
    end
    maxCPHistory(end + 1) = -F; % Append current maxCP (convert back to positive for tracking)

    % Visualization
    subplot(1, 2, 1);
    plot([2, 4, 6, 8, 10], rotor.CP);
    xlabel('TSR');
    ylabel('C_P');
    title(['Exponential Coefficients: Twist = ', num2str(X(1)), ', Chord = ', num2str(X(2))]);
    hold on;

    subplot(1, 2, 2);
    plot(1:length(maxCPHistory), maxCPHistory, '-o');
    xlabel('Iteration');
    ylabel('Max C_P');
    title('Maximum C_P vs Iteration');
    grid on;
    hold on;

    drawnow;
end
