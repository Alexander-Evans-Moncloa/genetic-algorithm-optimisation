function Optimize_Cost_Index()
    % Main function to run the genetic algorithm and plot results

    % Parameter ranges for optimisation
    Position_bounds = [0, 2000]; % Bounds for Position
    Radius_bounds = [30, 50];  % Bounds for Radius
    Height_bounds = [90, 110];  % Bounds for Height
    
    % Number of turbines (should match input size)
    num_turbines = 8; 

    % Combine bounds into a single matrix
    lb = [repmat(Position_bounds(1), 1, num_turbines), ... % Lower bounds
          repmat(Radius_bounds(1), 1, num_turbines), ...
          repmat(Height_bounds(1), 1, num_turbines)];
    ub = [repmat(Position_bounds(2), 1, num_turbines), ... % Upper bounds
          repmat(Radius_bounds(2), 1, num_turbines), ...
          repmat(Height_bounds(2), 1, num_turbines)];

    % Genetic Algorithm Options
    options = optimoptions('ga', ...
        'PopulationSize', 50, ...
        'MaxGenerations', 100, ...
        'Display', 'iter', ...
        'PlotFcn', @gaplotbestf); % Plot best fitness per generation

    % Fitness function wrapper
    fitnessFcn = @(x) Cost_Index_Fitness(x, num_turbines);

    % Run Genetic Algorithm
    [best_params, best_cost] = ga(fitnessFcn, length(lb), [], [], [], [], lb, ub, [], options);

    % Extract best values for Position, Radius, and Height
    best_position = best_params(1:num_turbines);
    best_radius = best_params(num_turbines+1:2*num_turbines);
    best_height = best_params(2*num_turbines+1:end);

    % Display results
    fprintf('Best Cost: %.2f\n', best_cost);
    fprintf('Optimal Position: %s\n', mat2str(best_position, 4));
    fprintf('Optimal Radius: %s\n', mat2str(best_radius, 4));
    fprintf('Optimal Height: %s\n', mat2str(best_height, 4));
end

function cost = Cost_Index_Fitness(x, num_turbines)
    % Fitness function wrapper for Cost_Index_Cal

    % Extract Position, Radius, and Height from the input vector
    Position = x(1:num_turbines);
    Radius = x(num_turbines+1:2*num_turbines);
    Height = x(2*num_turbines+1:end);


    % Ensure input dimensions match expectations
    if numel(Position) ~= num_turbines || ...
       numel(Radius) ~= num_turbines || ...
       numel(Height) ~= num_turbines
        error('Input vector dimensions do not match expected turbine count.');
    end

    % Loop through each turbine and calculate the cost
    cost = 0; % Initialise the cost
    for i = 1:num_turbines
        % Compute cost for each turbine individually
        cost = cost + Cost_Index_Cal(Position(i), Radius(i), Height(i));
    end
end