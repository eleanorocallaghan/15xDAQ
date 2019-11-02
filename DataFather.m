%DataDaddy but Again lol
%restructuring to allow people to change whats in what plot
date = input('Test Date? (yymmdd)');
testOverview =readtable(string(date)+" Drive Day Tests - Sheet1.csv");

%determining what's in what port
for i = 1:20
    if table2array(testOverview(i,2)) == "Hall Effect"
        he = i;
    end
    if table2array(testOverview(i,2)) == "X Acceleration"
        x = i; %these are index values for later
    end
    if table2array(testOverview(i,2)) == "Y Acceleration"
        y = i;
    end
    if table2array(testOverview(i,2)) == "Z Acceleration"
        z = i;
    end
    if table2array(testOverview(i,2)) == "Front Linear Potentiometer"
        flp = i;
    end
    if table2array(testOverview(i,2)) == "Rear Linear Potentiometer"
        rlp = i;
    end
    if table2array(testOverview(i,2)) == "String Potentiometer"
        sp = i;
    end
    if table2array(testOverview(i,2)) == "GPS Latitude"
        lat = i;
    end
    if table2array(testOverview(i,2)) == "GPS Longitude"
        long = i;
    end
    if table2array(testOverview(i,2)) == "GPS SOG"
        sog = i;
    end
    %add more ifs when more sensors are attached for later tests
end
indices = [he x y z sp flp rlp lat long sog];
testNumbers = table2array(testOverview(21:end,1));
filenames = table2array(testOverview(21:end,2));
testNames = table2array(testOverview(21:end,4));

%for 190928, test 1 doesn't fucking exist lol
%blank tests are 
%the following cut function will run once and then never again
yn = input("Clean Data?(y/n)",'s');
if strcmp(yn,"y")
    cleanedDataNames = string(filenames);
    for j = 1:size(testNumbers)
        if(testNames(j) ~= "N/A")
            cleanedDataNames(j) = SnipSnap(filenames(j),testNumbers(j),indices,date);
        end
    end
    save(string(date)+"Testfiles",'cleanedDataNames');
end

test = input ("Which test do you want?")
if testNames(test) ~= "N/A"
    cdN = load(string(date)+"TestFiles");
    cdN = cdN.cleanedDataNames;
    [time,vfshock,timeSeconds] = ThePlotThiccens(cdN(test),testNumbers(test),testNames(test));
else
    fprintf("There is no test here.");
end

%function to clean the raw test data for plotting purposes
%only run when we want (for now)
%will eventually be run only once (tracked w/ a persistent count)
function [cleanedDataName] = SnipSnap(filename,testNumber,indices,date)
load(string(filename));
%We're using just the "Data" part of the struct
%Data is a (holy shit what the fuck x 27) table with each column being a
%different port
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

time = (firstCutoff:finalCutoff); %modified time scale
cutData = Data(time,indices);

%gaussian filtering
gf1 = gausswin(601)/sum(gausswin(601)); %the real thicc sigma 100 filter
gf2 = gausswin(61)/sum(gausswin(61)); %the normal sigma 10 filter
cutData(:,1) = conv(cutData(:,1),gf1,'same');
cutData(:,10) = conv(cutData(:,10),gf1,'same');
for k = 2:7
    cutData(:,k) = conv(cutData(:,k),gf2,'same');
end
cleanedDataName = string(date)+"Test"+string(testNumber);
save(cleanedDataName,'cutData');
end

%function to plot cleaned data
%attached specifically to the required test
function[time, vfshock, timeSeconds] = ThePlotThiccens(cleanedDataName,testNumber,testName)
cleanedData = load(string(cleanedDataName));
cleanedData = cleanedData.cutData;
time=(1:size(cleanedData,1));
timeSeconds = (time/1200.0)-(1/1200.0);

%determining data to plot
hallEffect = cleanedData(:,1);
xAccel = cleanedData(:,2);
yAccel = cleanedData(:,3);
zAccel = cleanedData(:,4);
stringPot = cleanedData(:,5);
frontLinPot = cleanedData(:,6);
rearLinPot = cleanedData(:,7);

latitude = cleanedData(:,8);
longitude = cleanedData(:,9);
sog = cleanedData(:,10);

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
