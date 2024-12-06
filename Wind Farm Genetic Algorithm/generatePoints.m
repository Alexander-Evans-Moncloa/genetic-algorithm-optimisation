clear
clc

domainlength = 2000;
radiusRange = [30 50];
heightRange = [90 110];

testSpacing = sort(round(2000*lhsdesign(7,1)));
testSpacing(1) = 0;
testSpacing(end) = 2000;
testRadius = round(radiusRange(1) + range(radiusRange)*lhsdesign(8,1), 1);
testHeight = round(heightRange(1) + range(heightRange)*lhsdesign(8,1), 1);