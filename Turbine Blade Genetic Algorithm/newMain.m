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

% Implement genetic algorithm optimisation
% Optimising twist (X(1)) in range [-10, 10] and chord (X(2)) in range [0.1, 0.5]
lb = [-10, 0.1]; % Lower bounds
ub = [10, 0.5];  % Upper bounds
nVars = 2;       % Number of variables (twist and chord)

% Enable parallel processing in GA options
options = optimoptions('ga', ...
    'Display', 'iter', ...
    'MaxGenerations', 1); % Enable parallel computation

[X, fval] = ga(f, nVars, [], [], [], [], lb, ub, [], options);

disp('Optimal values found:');
disp(['Twist: ', num2str(X(1)), ' degrees']);
disp(['Chord: ', num2str(X(2)), ' meters']);
disp(['Maximum C_P: ', num2str(-fval)]);

databaseConnect(db_path, projectFilePath, 'Disconnect')

function F = objFunc(X, Params)
    % Define number of blades, twist, chord, and aerofoil at each aerodynamical station
    % There are 25 stations, going from root to tip

    numBlades = 3; % Define number of blades on rotor (must be an integer!!)

    newTwist = ones(25, 1) * X(1); % Creates a constant twist distribution of X(1) degrees
    newChord = ones(25, 1) * X(2); % Creates a constant chord distribution of X(2) meters

    disp(strcat('twist = ', num2str(X(1)), ' degrees, chord = ', num2str(X(2)), ' meters'))

    Foils = {'S1210'}; % Specifies aerofoils to be used (must match name in Ashes aerofoil database)
    foilsDist = [ones(1, 25)]; % Specifies aerofoil distribution based on Foils index
    % ^^ In the above foils distribution, foilDist is set to a vector of ones,
    % as there is only 1 aerofoil in the Foils variable

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Submit the simulation and read the results - do not change
    [rotor, blade] = runSIM(Params, newTwist, newChord, Foils, foilsDist, numBlades);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % THE FOLLOWING CODE IS FOR YOU TO CHANGE %

    % Rotor and blade are structures, and can be explored. 
    % For example - double clicking "rotor" in the workspace, there are 5 fields
    % within the structure. 
    % You can access each of these variables by typing rotor.variablename
    % e.g. here's the rotor CP plotted for each load case in the batch file
    % Looking at the batch file, you can see it runs different tip speed ratios
    % (TSRs), and each element in rotor.CP is the CP for each TSR
    % We also plot the angle of attack of the blade (at the highest CP) across the span to give
    % an example of exploring the blade results output.

    % My simple objective function 
    [F, I] = max(rotor.CP); % I is load case index that produced max power
    F = -F; % To convert to minimisation
    disp(max(rotor.CP))

    % Create a subplot for the rotor CP and the angle of attack across the
    % blade

    % Create first subplot
    subplot(1, 2, 1)
    plot([2, 4, 6, 8, 10], rotor.CP)
    xlabel('TSR')
    ylabel('C_P')
    % Add title with twist and chord values
    title(['Twist = ', num2str(X(1)), ' degrees, Chord = ', num2str(X(2)), ' meters'])
    hold on

    % Create second subplot
    subplot(1, 2, 2)
    plot(linspace(0, 1, 25), blade.AngleOfAttack(I, :)) % Plot the angle of attack distribution for the load case that produced the max CP
    xlabel('r/R') % Normalised spanwise location across blade - where r/R  
    ylabel('Angle of attack')
    % Add title with twist and chord values
    title(['Twist = ', num2str(X(1)), ' degrees, Chord = ', num2str(X(2)), ' meters'])
    hold on
    drawnow
   
end
