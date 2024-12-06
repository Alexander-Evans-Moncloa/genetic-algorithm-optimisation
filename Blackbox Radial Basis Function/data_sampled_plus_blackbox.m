function data_sampled_plus_blackbox(blackboxType)
    % Number of samples and dimensions
    numSamples = 2700;
    numDimensions = 3;

    % Generate Latin Hypercube samples between 0 and 1 for x, y, and z
    sampleMatrix = lhsdesign(numSamples, numDimensions);

    % Extract x, y, and z values
    x = sampleMatrix(:, 1);
    y = sampleMatrix(:, 2);
    z = sampleMatrix(:, 3);

    % Calculate blackbox outputs
    f = zeros(numSamples, 1);
    for i = 1:numSamples
        f(i) = blackbox(x(i), y(i), z(i), blackboxType);
    end

    % Plot the outputs in 3D space
    scatter3(x, y, z, 100, f, 'filled'); % Use f for color mapping
    xlabel('x');
    ylabel('y');
    zlabel('z');
    title(['3D Plot of Blackbox Outputs (Type ' num2str(blackboxType) ')']);
    colorbar; % Show color scale for output values
    grid on;

    % Perform RBF interpolation
    queryPoints = lhsdesign(10000, numDimensions); % Generate 10,000 query points
    xq = queryPoints(:, 1);
    yq = queryPoints(:, 2);
    zq = queryPoints(:, 3);

    % Gaussian RBF parameters
    L = 0.5; % Length scale of the radial basis function
    epsilon = 1 / L^2; % Convert L into epsilon

    rbfValues = zeros(size(xq)); % Initialises variables as 0, creating an array of 0s that is (size(xq)=[10000,10000]) along each axis

    for i = 1:length(xq)    % Starts for loop that cycles through 1 to the longest dimension in xq [10000]
        
        r = sqrt((x - xq(i)).^2 + (y - yq(i)).^2 + (z - zq(i)).^2); % Calculating the Euclidian distance between a point in 3D space and the centre of the RBF
        
        rbf = exp(-epsilon * r.^2); % Actual radial basis function, also known as the Gaussian
        
        rbfValues(i) = sum(rbf .* f) / sum(rbf); % Weighted average
    end

    % Plot interpolated points
    figure;
    scatter3(xq, yq, zq, 50, rbfValues, 'filled');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    title('RBF Interpolated Outputs');
    colorbar;
    grid on;

    % Determine minimum point from RBF simulation
    [minValue, minIndex] = min(rbfValues); % Find minimum value and index
    minPoint = queryPoints(minIndex, :); % Get coordinates of the minimum point
    disp(['Minimum value: ', num2str(minValue)]);
    disp(['Coordinates of minimum point: (x, y, z) = (', num2str(minPoint(1)), ', ', num2str(minPoint(2)), ', ', num2str(minPoint(3)), ')']);

    % Determine maximum point from RBF simulation
    [maxValue, maxIndex] = max(rbfValues); % Find maximum value and index
    maxPoint = queryPoints(maxIndex, :); % Get coordinates of the maximum point
    disp(['Maximum value: ', num2str(maxValue)]);
    disp(['Coordinates of maximum point: (x, y, z) = (', num2str(maxPoint(1)), ', ', num2str(maxPoint(2)), ', ', num2str(maxPoint(3)), ')']);
end

function f = blackbox(dial_1, dial_2, dial_3, type)
    switch type
        case 0
            % A parabolic function that peaks at around (0.5, 0.5, 0.5)
            f = -((dial_1 - 0.5)^2 + (dial_2 - 0.5)^2 + (dial_3 - 0.5)^2);

        case 1
            % Sinusoidal function with a peak around (0.5, 0.5, 0.5)
            f = sin(pi * dial_1) + cos(pi * dial_2) + sin(pi/2 * dial_3);

        case 2
            % Exponential-decay based function with a maximum at (0.5, 0.5, 0.5)
            f = exp(-(dial_1 - 0.5)^2) * exp(-(dial_2 - 0.5)^2) * exp(-(dial_3 - 0.5)^2);

        case 3
            % Absolute difference, maximized near (0.5, 0.5, 0.5)
            f = abs(dial_1 - 0.5) + abs(dial_2 - 0.5) + abs(dial_3 - 0.5);

        case 4
            % Non-linear combination with a maximum near the center
            f = (dial_1 - 0.5)^2 + (dial_2 - 0.5)^3 + (dial_3 - 0.5)^2 - dial_1 * dial_2 * dial_3;

        case 5
            % Rational function with a peak close to (0.5, 0.5, 0.5)
            f = (dial_1 + dial_2 + dial_3) / (1 + abs((dial_1 - 0.5) * (dial_2 - 0.5) * (dial_3 - 0.5)));

        case 6
            % Mixed trigonometric and exponential with peak near (0.5, 0.5, 0.5)
            f = sin(pi * dial_1) * cos(pi * dial_2) + exp(-(dial_1 - 0.5) * (dial_3 - 0.5));

        case 7
            % Cubic function divided by a parabolic term, peak near (0.5, 0.5, 0.5)
            f = ((dial_1 - 0.5)^3 + (dial_2 - 0.5)^3 + (dial_3 - 0.5)^3) / (1 + (dial_1 - 0.5)^2 + (dial_2 - 0.5)^2 + (dial_3 - 0.5)^2);

        case 8
            % Sin and cosine combination with an interaction term, peak near (0.5, 0.5, 0.5)
            f = (sin(pi * (dial_1 - 0.5) * (dial_2 - 0.5)) + cos(pi * (dial_2 - 0.5) * (dial_3 - 0.5)) + sin(pi * (dial_3 - 0.5) * (dial_1 - 0.5))) * (dial_3 - 0.5);

        case 9
            % Logarithmic and exponential mix with a minimum near the center
            f = log(1 + abs(dial_1 - 0.5)) * exp(-abs((dial_2 - 0.5) * (dial_3 - 0.5)));
        
        otherwise
            disp("Enter type between 0 to 9")
            f = NaN; % Assign NaN if type is out of range
    end
end

