clc
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% THE FOLLOWING CODE IS FOR YOU TO CHANGE %

%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript % Runs initialisation script for file paths and names

f = @(X) objFunc(X, Params);

% Optimising root twist (X(1)) in range [20, 30], tip twist (X(2)) in range [0, 10],
% root chord (X(3)) in range [0.1, 0.5], and tip chord (X(4)) in range [0.1, 0.5]
lb = [20, 4, 0.5, 0.1]; % Lower bounds
ub = [25, 5, 0.501, 0.101]; % Upper bounds
nVars = 4;               % Number of variables (root twist, tip twist, root chord, tip chord)

% Set options for simulated annealing
options = optimoptions('simulannealbnd', ...
    'Display', 'iter', ...
    'MaxIterations', 100, ...
    'ReannealInterval', 20, ...
    'InitialTemperature', 100);

% Perform optimisation
[X, fval] = simulannealbnd(f, rand(1, nVars) .* (ub - lb) + lb, lb, ub, options);

disp('Optimal values found:');
disp(['Root Twist: ', num2str(X(1)), ' degrees']);
disp(['Tip Twist: ', num2str(X(2)), ' degrees']);
disp(['Root Chord: ', num2str(X(3)), ' meters']);
disp(['Tip Chord: ', num2str(X(4)), ' meters']);
disp(['Maximum C_P: ', num2str(-fval)]);

databaseConnect(db_path, projectFilePath, 'Disconnect')

function F = objFunc(X, Params)
    % Define number of blades, twist, chord, and aerofoil at each aerodynamical station
    % There are 25 stations, going from root to tip

    numBlades = 3; % Define number of blades on rotor (must be an integer!!)

    % Ensure linear variation in twist and chord
    twistDist = linspace(X(1), X(2), 25)'; % Linearly varying twist from root (X(1)) to tip (X(2))
    chordDist = linspace(X(3), X(4), 25)'; % Linearly varying chord from root (X(3)) to tip (X(4))

    % Ensure constraints: root twist > tip twist and root chord > tip chord
    if X(1) <= X(2) || X(3) <= X(4)
        F = Inf; % Penalise invalid configurations
        return;
    end

    disp(['Root Twist = ', num2str(X(1)), ' degrees, Tip Twist = ', num2str(X(2)), ' degrees']);
    disp(['Root Chord = ', num2str(X(3)), ' meters, Tip Chord = ', num2str(X(4)), ' meters']);

    Foils = {'S1210'}; % Specifies aerofoils to be used (must match name in Ashes aerofoil database)
    foilsDist = [ones(1, 25)]; % Specifies aerofoil distribution based on Foils index
    % ^^ In the above foils distribution, foilDist is set to a vector of ones,
    % as there is only 1 aerofoil in the Foils variable

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Submit the simulation and read the results - do not change
    [rotor, blade] = runSIM(Params, twistDist, chordDist, Foils, foilsDist, numBlades);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % THE FOLLOWING CODE IS FOR YOU TO CHANGE %

    % My simple objective function 
    [F, I] = max(rotor.CP); % I is load case index that produced max power
    F = -F; % To convert to minimisation
    disp(max(rotor.CP))

    % Track maximum rotor.CP across iterations
    persistent maxCPHistory; % Store maxCP across iterations
    if isempty(maxCPHistory)
        maxCPHistory = []; % Initialise on first call
    end
    maxCPHistory(end + 1) = -F; % Append current maxCP (convert back to positive for tracking)

    % Create a subplot for the rotor CP and the angle of attack across the
    % blade

    % Create first subplot
    subplot(1, 2, 1)
    plot([2, 4, 6, 8, 10], rotor.CP)
    xlabel('TSR')
    ylabel('C_P')
    % Add title with twist and chord values
    title(['Root Twist = ', num2str(X(1)), '°, Tip Twist = ', num2str(X(2)), '°, Root Chord = ', num2str(X(3)), ' m, Tip Chord = ', num2str(X(4)), ' m'])
    hold on

    % Plot maxCP values in second subplot
    subplot(1, 2, 2)
    plot(1:length(maxCPHistory), maxCPHistory, '-o')
    xlabel('Iteration')
    ylabel('Max C_P')
    title('Maximum C_P vs Iteration')
    grid on
    hold on

    drawnow
end
