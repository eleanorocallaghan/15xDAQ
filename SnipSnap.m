%Modifications:
%unnecessary data (car wasn't moving) removed from time and data tables
%time on plots made into seconds, with 0 being the point where the car
%started moving
%made script into a function to be called by main code for all projects

%{
desired column order:
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

function[cleanedDataName]=SnipSnap(fileName, testNumber)
load(string(fileName));
totalTime = size(Data,1);
time = (1:totalTime); %original time scale
%duration = (totalTime/1200);

firstCutoff = 1.0;
finalCutoff = totalTime;
%the following cutoff loops are based on the hall effect sensor
%testArray=zeros(10,1);
for i = 1:totalTime/2
    if Data(i,16) > 5 %records last pt for which HE=0 before car starts
        firstCutoff = i;
        break;
    end
end
for j = totalTime:-1:totalTime/2
    if Data(j,16) > 5 %records last pt where HE=0 after car stops
        finalCutoff = j;
        break;
    end
end

time=(firstCutoff:finalCutoff); %modified time scale

%timeSeconds=(time/1200.0)-(firstCutoff/1200.0);

newFileName = strcat('190929Test',string(testNumber));

% filtering the data (2 gaussian filters)
s1 = 100; % sigma for hall effect filter
gf1 = gausswin(6*s1 + 1)';
gf1 = gf1 / sum(gf1); % normalize

s2=10; %sigma and fit for everything else
gf2=gausswin(6*s2+1)';
gf2=gf2/sum(gf2);

%reorganizing/fitting the data
rearLinPot = conv(Data(time,1),gf2,'same');
xAccel = conv(Data(time,2),gf1,'same');
yAccel = conv(Data(time,3),gf1,'same');
frontLinPot = conv(Data(time,4),gf2,'same');
stringPot = conv(Data(time,6),gf2,'same');
zAccel = conv(Data(time,7),gf1,'same');
hallEffect = conv(Data(time,16),gf1,'same');

% Data(time,1)=hallEffect;
% Data(time,2)=xAccel; %redundant
% Data(time,3)=yAccel; %redundant
% Data(time,4)=zAccel;
% Data(time,5)=stringPot;
% Data(time,6)=frontLinPot;
% Data(time,7)=rearLinPot;

cutData = [hallEffect xAccel yAccel zAccel stringPot frontLinPot rearLinPot];
save(newFileName, 'cutData');
cleanedDataName = strcat(newFileName, '.mat');
end
