%Modifications:
%unnecessary data (car wasn't moving) removed from time and data tables
%time on plots made into seconds, with 0 being the point where the car
%started moving
%made script into a function to be called by main code for all projects

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

function[]=SnipSnap(fileName, testNumber)
load(string(fileName));
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
newFileName = strcat('190929Test',string(testNumber));
%{
rearLinPot = Data(time,1);
xAccel = Data(time,2);
yAccel = Data(time,3);
frontLinPot = Data(time,4);
stringPot = Data(time,6);
zAccel = Data(time,7);
hallEffect = Data(time,16);
%}
save(newFileName);
end
