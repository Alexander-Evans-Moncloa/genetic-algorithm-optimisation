function Genetic_Algorithm_Cost_Optimisation()
    % Main function to run the genetic algorithm and plot results

    % Parameter ranges for optimisation
    Position_bounds = [0, 2000]; % Bounds for Position
    Radius_bounds = [20, 100];  % Bounds for Radius
    Height_bounds = [50, 200];  % Bounds for Height
    
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

    % Run Genetic Algorithm
    [best_params, best_cost] = ga(@(x) Cost_Index_Cal(x, num_turbines), ...
                                  length(lb), [], [], [], [], lb, ub, [], options);

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

function [Cost_Index] = Cost_Index_Cal(inputs, num_turbines)
    % Cost Index Calculation
    % Extract Position, Radius, and Height from inputs
    Position = inputs(1:num_turbines);
    Radius = inputs(num_turbines+1:2*num_turbines);
    Height = inputs(2*num_turbines+1:end);

    % Parameter
    Sim_years = 5; % Years to simulate for cost index
    Sim_conversion_rate = 0.27; % Energy export conversion rate (£/kWh)

    % Calculate the deficit
    Deficit = Deficit_Cal(Position, Radius, Height);

    % Calculate the cost of rotars
    Total_Rotar_Cost = Rotar_Cost_Cal(Radius);

    % Calculate the annual energy production
    [Total_AEP, ~] = AEP_Cal(Deficit, Radius);

    % Calculate the net cost
    Cost_Index = Total_Rotar_Cost - Sim_years * Sim_conversion_rate * Total_AEP;
end