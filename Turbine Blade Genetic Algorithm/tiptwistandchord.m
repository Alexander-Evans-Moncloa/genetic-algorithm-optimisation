% Given values
rootTwist = 19.1669; % degrees
rootChord = 0.30838; % meters
twistCoeff = 0.99854;
chordCoeff = 0.66468;

% Calculate tip twist and chord
tipTwist = rootTwist * exp(-twistCoeff * 1);
tipChord = rootChord * exp(-chordCoeff * 1);

% Display results
disp(['Tip Twist: ', num2str(tipTwist), ' degrees']);
disp(['Tip Chord: ', num2str(tipChord), ' meters']);
