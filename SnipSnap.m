%Modifications:
%unnecessary data (car wasn't moving) removed from time and data tables
%time on plots made into seconds, with 0 being the point where the car
%started moving
%made script into a function to be called by main code for all projects

function[]=DriveDay190929v1_2(testNumber,filename)
Data=load(filename);
totalTime = size(Data,1);
time=(1:totalTime); %original time scale
duration = (totalTime/1200);

firstCutoff=1.0;
finalCutoff=totalTime;
%the following cutoff loops are based on the hall effect sensor
for i=1:totalTime/2
    if Data(i,16)==0 %records last pt for which HE=0 before car starts
        firstCutoff=i+1;
    end
end
for j=totalTime:-1:totalTime/2
    if Data(j,16)==0 %records last pt where HE=0 after car stops
        finalCutoff=j-1;
    end
end
time=(firstCutoff:finalCutoff); %modified time scale
timeSeconds=(time/1200.0)-(firstCutoff/1200.0);

%testNumber = input("Test Number?");
fileName = strcat(string(testNumber),"driveDay190929");
rearLinPot = Data(time,1);
xAccel = Data(time,2);
yAccel = Data(time,3);
frontLinPot = Data(time,4);
stringPot = Data(time,6);
zAccel = Data(time,7);
hallEffect = Data(time,16);

save(fileName);
end
