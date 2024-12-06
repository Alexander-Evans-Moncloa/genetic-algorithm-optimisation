function Optimise_Pareto_Front()
    % Main function to run gamultiobj and plot Pareto curve

    % Parameter bounds
    Radius_bounds = [30, 50];    % Bounds for Radius
    Height_bounds = [90, 110];   % Bounds for Height
    Position_bounds = [0, 2000]; % Bounds for Position
    
    % Number of turbines
    num_turbines = 8;

    % Define bounds for the optimisation variables
    lb = [repmat(Position_bounds(1), 1, num_turbines - 2), ...
          repmat(Radius_bounds(1), 1, num_turbines), ...
          repmat(Height_bounds(1), 1, num_turbines)];
    ub = [repmat(Position_bounds(2), 1, num_turbines - 2), ...
          repmat(Radius_bounds(2), 1, num_turbines), ...
          repmat(Height_bounds(2), 1, num_turbines)];

    % gamultiobj Options
    options = optimoptions('gamultiobj', ...
        'PopulationSize', 200, ...
        'MaxGenerations', 50, ...
        'CrossoverFraction', 0.9, ...
        'MutationFcn', {@mutationadaptfeasible}, ...
        'Display', 'iter', ...
        'PlotFcn', @gaplotpareto); % Plot Pareto front during optimisation

    % Objective function: energy production and rotor cost
    objFcn = @(x) MultiObjectiveFcn(PrepareParameters(x, num_turbines), num_turbines);

    % Non-linear constraints for turbine spacing
    nonlcon = @(x) SpacingConstraint(PrepareParameters(x, num_turbines), num_turbines);

    % Run gamultiobj
    [pareto_solutions, pareto_front] = gamultiobj(objFcn, length(lb), [], [], [], [], lb, ub, nonlcon, options);

    % Plot the Pareto front
    figure;
    scatter(pareto_front(:, 2), -pareto_front(:, 1), 'filled'); % Energy vs Cost
    xlabel('Rotor Cost');
    ylabel('Annual Energy Production');
    title('Pareto Front');
    grid on;

    % Display best solutions
    disp('Pareto Solutions:');
    disp(pareto_solutions);
    disp('Pareto Front (Energy vs Cost):');
    disp(pareto_front);
end

function objectives = MultiObjectiveFcn(params, num_turbines)
    % Multi-objective fitness function for gamultiobj
    % Objectives: Minimise rotor cost and maximise energy production (negative)

    Position = params.Position;
    Radius = params.Radius;
    Height = params.Height;

    % Initialise objectives
    total_cost = 0;
    total_energy = 0;

    for i = 1:num_turbines
        total_cost = total_cost + Rotar_Cost_Cal(Radius(i));
        total_energy = total_energy + AEP_Cal(Deficit_Cal(Position(i), Radius(i), Height(i)), Radius(i));
    end

    % First objective: minimise rotor cost
    % Second objective: maximise annual energy production (negative for minimisation)
    objectives = [ -total_energy, total_cost ]; % Note the negative sign for maximisation
end

function params = PrepareParameters(x, num_turbines)
    % Process the optimisation variables into usable parameters

    % Hard-coded start and end positions
    Position = [0, sort(x(1:num_turbines-2)), 2000]; % Include hard-coded start and end

    % Extract Radius and Height
    Radius = x(num_turbines-1:num_turbines-2+num_turbines);
    Height = x(num_turbines-1+num_turbines:end);

    % Package into struct
    params.Position = Position;
    params.Radius = Radius;
    params.Height = Height;
end

function [c, ceq] = SpacingConstraint(params, num_turbines)
    % Non-linear constraint to ensure minimum spacing between positions

    Position = params.Position;
    min_spacing = 150; % Minimum spacing in meters

    % Inequality constraint: ensure spacing is greater than the minimum
    c = zeros(num_turbines-1, 1);
    for i = 2:num_turbines
        c(i-1) = min_spacing - (Position(i) - Position(i-1));
    end

    % No equality constraints
    ceq = [];
end
