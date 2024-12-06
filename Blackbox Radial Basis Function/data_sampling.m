% Number of samples and dimensions
numSamples = 27;
numDimensions = 3;

% Generate Latin Hypercube samples between 0 and 1 for x, y, and z
sampleMatrix = lhsdesign(numSamples, numDimensions);

% Extract x, y, and z values
x = sampleMatrix(:, 1);
y = sampleMatrix(:, 2);
z = sampleMatrix(:, 3);

% Display the generated points
disp('Generated x values:');
disp(x);
disp('Generated y values:');
disp(y);
disp('Generated z values:');
disp(z);

% Plot the samples to visualize their spread in 3D space
scatter3(x, y, z, 'filled');
xlabel('x');
ylabel('y');
zlabel('z');
title('Latin Hypercube Sampled Points in 3D');
grid on;
