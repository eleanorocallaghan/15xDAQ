for i=2:31 %run through each data set and save modified data into new files
    Data = load(strcat('190928DriveDay_', num2str(i,'%04.f'), '.mat'));
    DriveDay190929v1_2(i, Data); %saving function
end 

%ask user for test to display
testNumber = input('Test number?');
fileName2 = strcat(string(testNumber),"driveDay190929");
DataPlotting(fileName2);