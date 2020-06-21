% Parent function for DAQ data organization, analysis, and display

testDate = input('Test Date (yymmdd)? ');
testOverview = readtable(strcat(string(testDate), ' Drive Day Tests - Sheet1.csv'));
testName = table2array(testOverview(21:size(testOverview), 4));
testNumber = table2array(testOverview(21:size(testOverview), 1));
dataNameArray = strcat('Data', string(testNumber));

i=input('Test Number? ') +19; %input test number for plotting

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


%for i = 21:size(testOverview,1) %run through each data set and save modified data into new files
    filename(i-20, 1) = strcat(table2array(testOverview(i, 2)), '.mat');
    cleanedDataName = SnipSnap(filename(i-20), testNumber(i-20));
    [time, vfshock, timeSeconds] = ThePlotThiccens(cleanedDataName,testNumber(i-20),testName(i-20));
%end


%begin function snipsnap
%cleans data (only run once, hopefully)
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

%reorganizing GPS data
longitude = Data(time,18);
latitude = Data(time,19);
sog = conv(Data(time,20),gf1,'same');
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
18 - GPS SOG (speed)
19 - GPS altitude
%}
cutData = [hallEffect xAccel yAccel zAccel stringPot frontLinPot rearLinPot latitude longitude sog];
save(newFileName, 'cutData');
cleanedDataName = strcat(newFileName, '.mat');
end

%begin function thePlotThiccens
%plotting function for modified data
%takes data cleaned up in formatting function (DriveDay190929v1.2)
%puts data in a subplot

function[time, vfshock, timeSeconds] = ThePlotThiccens(cleanedDataName,testNumber,testName)
cleanedData = load(cleanedDataName);
cleanedData = cleanedData.cutData;
time=(1:size(cleanedData,1));
timeSeconds = (time/1200.0)-(1/1200.0);

%determining data to plot
hallEffect = cleanedData(time,1);
xAccel = cleanedData(time,2);
yAccel = cleanedData(time,3);
zAccel = cleanedData(time,4);
stringPot = cleanedData(time,5);
frontLinPot = cleanedData(time,6);
rearLinPot = cleanedData(time,7);

latitude = cleanedData(time,8);
longitude = cleanedData(time,9);
sog = cleanedData(time,10);

%plotting GPS data
%[gpsSpeed,gpsMax]=Jeeps(sog); %maybe add this to skrrrt?

%plotting
clf(figure(testNumber))
figure(testNumber)

%shock extension/compression
subplot(2,3,1);
[fshock,rshock,maxfd,maxrd,maxfb,maxrb] = mainSqueeze(rearLinPot,frontLinPot);
plot(timeSeconds,fshock,"blue");
title("Shock Extension/Compression");
hold on
plot(timeSeconds,rshock,"red");
legend('front','rear');
xlabel('Time (sec)');
ylabel('Shock Displacement (inches)');
hold off

% shock velocity
dxf = diff(fshock); % takes the difference between every shock travel value 
% and the next value
dxr = diff(rshock);
dxf = dxf'; %transpose
dxr = dxr';
dt = diff(timeSeconds); %takes the difference between every time value and 
% the next one (should be 1/1200HZ)
vfshock = dxf./dt; % divide them to get the derivative of displacement (velocity)
vrshock = dxr./dt;

time = time(1:end-1); % change size of time so that it matches after 
% differentiation
time = time/1200; % get time into actual seconds

time = time(120:end-120); % get rid of first part of time because there are weird spikes
vfshock = vfshock(120:end-120); %see above
vrshock = vrshock(120:end-120);

time = time'; % transpose
vfshock = vfshock'; % transpose
vrshock = vrshock';

% shock force
springRate = 80;
dampCoeff = 19.42;

cutfshock = fshock(120:end-121);
cutrshock = rshock(120:end-121);

% timeSize = size(time)
% vfShockSize = size(vfshock)
% fShockSize = size(cutfshock)

Ffshock = springRate * cutfshock + dampCoeff * vfshock;
Frshock = springRate * cutrshock + dampCoeff * vrshock;
maxFForce = max(abs(Ffshock));
maxRForce = max(abs(Frshock));
subplot(2,3,2)
plot(time, Ffshock)
hold on
plot (time, Frshock)
hold off
title("Shock Force")
xlabel("time (sec)")
ylabel("force (lbs)")
legend("front", "rear")




%steering angle
subplot(2,3,3)
steeringAngle = ohWowSwerve(stringPot);
plot(timeSeconds,steeringAngle);
title("Steering Angle");
xlabel('Time (sec)');
ylabel('Steering Angle (degrees)');

%car speed
subplot(2,3,4);
[carSpeed,topSpeed,gpsSpeed,gpsMax]=skrrrt(hallEffect, sog); %turns hall effect to car speed
plot(timeSeconds,carSpeed);
hold on
plot(timeSeconds,gpsSpeed,"red")
title("Car Speed"); 
xlabel('Time (sec)');
ylabel('Speed (mph)');
legend("from hall effect","from GPS");

%formatting text
speed = "(Hall Effect) Top Speed: "+string(topSpeed)+" mph";
gpsTop="(GPS) Top Speed: "+string(gpsMax)+" mph";
fdroop = "Closest to Full Droop (front): "+ string(maxfd)+" in";
rdroop = "Cosest to Full Droop (rear): "+ string(maxrd)+" in";
fbump = "Closest to Full Bump (front): "+ string(maxfb)+" in";
rbump = "Closest to Full Bump (rear): "+ string(maxrb)+" in";
frontForce = "Highest Force from Shocks (front): " + string(maxFForce) + " lbs";
rearForce = "Highest Force from Shocks (rear): " + string(maxRForce) + " lbs";

%GPS course
subplot(2,3,5);
plot(longitude, latitude)
%evening out the axes
latrange=max(latitude)-min(latitude);
longrange=max(longitude)-min(longitude);
range=max([latrange longrange]);
ylim([min(latitude) min(latitude)+range]); %axes limited by same range
xlim([min(longitude) min(longitude)+range]);
%evening out the axes
xlabel("Longitude (degrees)");
ylabel("Latitude (degrees)");
%must even out axes so course doesn't look stretched
title('Course');

%text
subplot(2,3,6);
text(0,0.5, speed + newline + gpsTop + newline + fdroop + newline + rdroop + newline + fbump + newline + rbump + newline + frontForce + newline + rearForce);
axis off;
%accels
%{
subplot(2,4,8);
plot(timeSeconds,xAccel,"blue");
hold on
plot(timeSeconds,yAccel,"red");
hold on
plot(timeSeconds,zAccel,"green");
title("Accelerometer");
legend('x','y','z');
hold off
%}

sgtitle("Test # "+string(testNumber)+": "+string(testName));

end

%begin the mini functions to do some quick maths to the raw data
%shocks
function [frontShock,rearShock,maxFrontDroop,maxRearDroop, maxFrontBump, maxRearBump]=mainSqueeze(rearLinPot,frontLinPot)
%full droop: shocks are fully extended (5)
%full bump: shocks are fully compressed (0)
%needs for the plot:
%max
%minimum
%adjust plot to actually range from full bump to full droop
% currentRange = 5.0;
% fullBump = 0.0;
% fullDroop = 5.0;
% frontShock = (fullDroop-fullBump)/currentRange*frontLinPot;
% rearShock = (fullDroop-fullBump)/currentRange*rearLinPot;

frontShock = frontLinPot - (.6647+.6397)/2;
rearShock = (5/4)*rearLinPot-2.4;

%closest to full bump for both potentiometers
maxFrontBump = min(frontShock);
maxRearBump = min(rearShock);

%closest to full droop for both potentiometers
maxFrontDroop = max(frontShock);
maxRearDroop = max(rearShock);
end

%steering angle
function [steeringAngle]=ohWowSwerve(stringPot)
%replaces string potentiometer plot
%total steering angle: 315 degree
%angle ranges from  -157.5 to 157.5

maxAngle = 157.5;
%stringPot=cutData(:,5); %stringPot data ranges from -1 to 1
steeringAngle = maxAngle*stringPot;
%returns steering angle for plotting/data updating purposes
end

%speeds
function [hspeed,hmax,gspeed,gmax]=skrrrt(hallEffect, sog)
%replaces car speed plot
%transforms hall effect sensor data to car speed
%from hall effect
hspeed = hallEffect*(1/55)*(20*pi)*60*60*(1/63360);
hmax = max(hspeed);
%from GPS
gspeed=sog/1.61;
gmax=max(gspeed);
end
