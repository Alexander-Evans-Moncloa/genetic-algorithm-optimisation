clc
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% THE FOLLOWING CODE IS FOR YOU TO CHANGE%

%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript % runs initialisation script for file paths and names

f = @(X) objFunc(X, Params);

% Implement genetic algorithm optimisation
% Optimising twist (X(1)) in range [-10, 10] and chord (X(2)) in range [0.1, 0.5]
lb = [-10, 0.1]; % Lower bounds
ub = [10, 0.5];  % Upper bounds
nVars = 2;       % Number of variables (twist and chord)
options = optimoptions('ga', 'Display', 'iter', 'MaxGenerations', 2);

[X, fval] = ga(f, nVars, [], [], [], [], lb, ub, [], options);

disp('Optimal values found:');
disp(['Twist: ', num2str(X(1)), ' degrees']);
disp(['Chord: ', num2str(X(2)), ' meters']);
disp(['Maximum C_P: ', num2str(-fval)]);

% Disconnect from the database after optimization
disp('Optimization complete. Disconnecting from database...');
databaseConnect(db_path, projectFilePath, 'Disconnect');

% Define the fitness function for GA optimization
function F = objFunc(X, Params)
    % Define number of blades, twist, chord, and aerofoil at each aerodynamical station
    % There are 25 stations, going from root to tip

    numBlades = 3; % Define number of blades on rotor (must be an integer!!)

    % Move the optimization variables (twist and chord) to GPU
    newTwist = gpuArray(ones(25, 1) * X(1)); % Creates a constant twist distribution of X(1) degrees
    newChord = gpuArray(ones(25, 1) * X(2)); % Creates a constant chord distribution of X(2) meters

    disp(strcat('twist = ', num2str(X(1)), ' degrees, chord = ', num2str(X(2)), ' meters'))

    Foils = {'S826'}; % Specifies aerofoils to be used (must match name in Ashes aerofoil database)
    foilsDist = gpuArray(ones(1, 25)); % Move the foil distribution to the GPU
    
    % Move GPU data back to CPU before database interaction
    newTwist_cpu = gather(newTwist); % Convert to CPU arrays
    newChord_cpu = gather(newChord); % Convert to CPU arrays
    foilsDist_cpu = gather(foilsDist); % Convert to CPU arrays
    
    % Check if the database is open and reconnect if necessary
    checkDatabaseConnection(); % Ensure database is connected

    % Submit the simulation and read the results - run the simulation on GPU
    [rotor, blade] = runSIM(Params, newTwist_cpu, newChord_cpu, Foils, foilsDist_cpu, numBlades);
    
    % My simple objective function
    [F, I] = max(rotor.CP); % I is load case index that produced max power
    F = -F; % To convert to minimisation
    disp(max(rotor.CP))

    % Create a subplot for the rotor CP and the angle of attack across the blade
    subplot(1, 2, 1)
    plot([2, 4, 6, 8, 10], gather(rotor.CP)) % Move rotor.CP data back to CPU for plotting
    xlabel('TSR')
    ylabel('C_P')
    % Add title with twist and chord values
    title(['Twist = ', num2str(X(1)), ' degrees, Chord = ', num2str(X(2)), ' meters'])
    hold on

    % Create second subplot
    subplot(1, 2, 2)
    plot(linspace(0, 1, 25), gather(blade.AngleOfAttack(I, :))) % Move blade.AngleOfAttack data back to CPU
    xlabel('r/R') % Normalised spanwise location across blade - where r/R  
    ylabel('Angle of attack')
    % Add title with twist and chord values
    title(['Twist = ', num2str(X(1)), ' degrees, Chord = ', num2str(X(2)), ' meters'])
    hold on
    drawnow
end


% Ensure that the database connection is properly closed
function checkDatabaseConnection()
    if ~isDatabaseOpen()  % Example: Check for an open connection function
        disp('Database not open, opening connection...');
        databaseConnect(db_path, projectFilePath, 'Connect');
    end
end

% Check if the database is open (you may need to implement this depending on your setup)
function status = isDatabaseOpen()
    try
        % Assuming `db_path` is the path to the database and `projectFilePath` is the project file
        % You should implement a check here to verify if the database is open
        status = true; % Placeholder, implement your actual check
    catch
        status = false;
    end
end
