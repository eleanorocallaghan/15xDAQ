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
[gpsSpeed,gpsMax]=Jeeps(sog); %maybe add this to skrrrt?

%plotting
clf(figure(testNumber))
figure(testNumber)

%shock extension/compression
subplot(2,4,1);
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
subplot(2,4,2);
dxf = diff(fshock); % takes the difference between every shock travel value 
% and the next value
dxr = diff(rshock);
dxf = dxf'; %transpose
dxr = dxr';
dt = diff(timeSeconds); %takes the difference between every time value and 
% the next one (should be 1/1200HZ)
vfshock = dxf./dt; % divide them to get the derivative of displacement (velocity)

time = time(1:end-1); % change size of time so that it matches after 
% differentiation
time = time/1200; % get time into actual seconds

time = time(120:end-120); % get rid of first part of time because there are weird spikes
vfshock = vfshock(120:end-120); %see above

time = time'; % transpose
vfshock = vfshock'; % transpose

plot(time, vfshock)

% shock force
springRate = 80;
dampCoeff = 19.42;

cutfshock = fshock(1:end-1);
cutfshock = cutfshock(120:end-120);

% timeSize = size(time)
% vfShockSize = size(vfshock)
% fShockSize = size(cutfshock)

Ffshock = springRate * cutfshock + dampCoeff * vfshock;
maxForce = max(abs(Ffshock))
subplot(2,4,3)
plot(time, Ffshock)

vertWheelForce = maxForce * 5/10


%steering angle
subplot(2,4,4)
steeringAngle = ohWowSwerve(stringPot);
plot(timeSeconds,steeringAngle);
title("Steering Angle");
xlabel('Time (sec)');
ylabel('Steering Angle (degrees)');

%car speed
subplot(2,4,5);
[carSpeed,topSpeed]=skrrrt(hallEffect); %turns hall effect to car speed
plot(timeSeconds,carSpeed);
hold on
plot(timeSeconds,gpsSpeed,"red")
title("Car Speed"); 
xlabel('Time (sec)');
ylabel('Speed (mph)');
legend("from hall effect","from GPS");

%formatting text
speed = "(Hall Effect) Top Speed: "+string(topSpeed)+" mph";
gpsSpeed="(GPS) Top Speed: "+string(gpsMax)+" mph";
fdroop = "Closest to Full Droop (front): "+ string(maxfd)+" in";
rdroop = "Cosest to Full Droop (rear): "+ string(maxrd)+" in";
fbump = "Closest to Full Bump (front): "+ string(maxfb)+" in";
rbump = "Closest to Full Bump (rear): "+ string(maxrb)+" in";

%GPS course
subplot(2,4,6);
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
subplot(2,4,7);
text(0,0.5,speed+newline+gpsSpeed+newline+fdroop+newline+rdroop+newline+fbump+newline+rbump);
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