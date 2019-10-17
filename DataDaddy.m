% Parent function for DAQ data organization, analysis, and display

testdate = input('Test Date (yymmdd)? ');
testOverview = readtable(strcat(string(testdate), ' Drive Day Tests - Sheet1.csv'));
testNumber = table2array(testOverview(17:size(testOverview), 1));
dataNameArray = strcat('Data', string(testNumber));

%{
column order:
1 - hall effect
2 - x accel
3 - y accel
4 - z accel
5 - string pot
6 - front lin pot
7 - rear lin pot
8 - tachometer
9 - tie rod strain
10 - front upper a arm strain
12 - back upper a arm strain
13 - j arm strain
14 - front h arm strain
15 - back h arm strain
16 - GPS latitude
17 - GPS longitude
18 - GPS COG (track)
19 - GPS SOG (speed)
20 - GPS altitude
%}


for i = 25%size(testOverview, 1) %run through each data set and save modified data into new files
    filename(i-16, 1) = strcat(table2array(testOverview(i, 2)), '.mat');
    SnipSnap(filename(i-16), testNumber(i-16))
end

%thePlotThiccens(strcat('190929Test2.mat'));

%{
%ask user for test to display
testNumber = input('Test number?');
fileName2 = strcat(string(testNumber),"driveDay190929");
DataPlotting(fileName2);
%}