function Optimise_Cost_Index()
    % Main function to run the genetic algorithm and plot results

    % Parameter ranges for optimisation
    Radius_bounds = [30, 30, 30, 30, 30, 30, 30, 30];    % Bounds for Radius

    % Hard-code the heights for all turbines
    fixed_heights = [90, 110, 90, 110, 90, 110, 90, 110]; 

    % Number of turbines
    num_turbines = 8; 

    % Predefine hard-coded positions for start and end
    Position_bounds = [0, 2000];

    % Combine bounds for optimisation variables (excluding height)
    lb = [repmat(Position_bounds(1), 1, num_turbines - 2), ... % Lower bounds for intermediate positions
          repmat(Radius_bounds(1), 1, num_turbines)];
    ub = [repmat(Position_bounds(2), 1, num_turbines - 2), ... % Upper bounds for intermediate positions
          repmat(Radius_bounds(2), 1, num_turbines)];

    % Genetic Algorithm Options
    options = optimoptions('ga', ...
        'PopulationSize', 200, ...
        'MaxGenerations', 50, ...
        'CrossoverFraction', 0.9, ...
        'MutationFcn', {@mutationadaptfeasible}, ...
        'Display', 'iter', ...
        'PlotFcn', @gaplotbestf); % Plot best fitness per generation

    % Fitness function wrapper (pass fixed heights)
    fitnessFcn = @(x) Cost_Index_Fitness(PrepareParameters(x, num_turbines, fixed_heights));

    % Custom non-linear constraints for spacing (pass fixed heights)
    nonlcon = @(x) SpacingConstraint(PrepareParameters(x, num_turbines, fixed_heights), num_turbines);

    % Run Genetic Algorithm
    [best_params, best_cost] = ga(fitnessFcn, length(lb), [], [], [], [], lb, ub, nonlcon, options);

    % Prepare final positions
    final_params = PrepareParameters(best_params, num_turbines, fixed_heights);
    best_position = final_params.Position;
    best_radius = final_params.Radius;
    best_height = final_params.Height; % Already hard-coded

    % Display results
    fprintf('Best Cost: %.2f\n', -best_cost);
    fprintf('Optimal Position: %s\n', mat2str(best_position, 4));
    fprintf('Optimal Radius: %s\n', mat2str(round(best_radius), 4));
    fprintf('Optimal Height: %s\n', mat2str(best_height, 4));
end


function cost = Cost_Index_Fitness(params)
    % Fitness function wrapper for Cost_Index_Cal

    cost = Cost_Index_Cal(params.Position, params.Radius, params.Height);

end

function params = PrepareParameters(x, num_turbines, fixed_heights)
    % Process the optimisation variables into usable parameters

    % Hard-coded start and end positions
    Position = [0, sort(x(1:num_turbines-2)), 2000]; % Include hard-coded start and end

    % Extract Radius
    Radius = x(num_turbines-1:num_turbines-2+num_turbines);

    % Use fixed heights
    Height = fixed_heights;

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
