%plotting function for modified data
%takes data cleaned up in formatting function (DriveDay190929v1.2)
%puts data in a subplot

function[] = ThePlotThiccens(cleanedDataName,testNumber,testName)
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


%plotting
clf(figure(testNumber))
figure(testNumber)

%shock extension/compression
subplot(2,2,1);
[fshock,rshock,maxfd,maxrd,maxfb,maxrb] = mainSqueeze(rearLinPot,frontLinPot);
plot(timeSeconds,fshock,"blue");
title("Shock Extension/Compression");
hold on
plot(timeSeconds,rshock,"red");
legend('rear','front');
xlabel('Time (sec)');
ylabel('Shock Displacement (inches)');
hold off

%steering angle
subplot(2,2,2)
steeringAngle = ohWowSwerve(stringPot);
plot(timeSeconds,steeringAngle);
title("Steering Angle");
xlabel('Time (sec)');
ylabel('Steering Angle (degrees)');

%car speed
subplot(2,2,3);
[carSpeed,topSpeed]=skrrrt(hallEffect); %turns hall effect to car speed
plot(timeSeconds,carSpeed);
title("Car Speed"); 
xlabel('Time (sec)');
ylabel('Speed (mph)');

%formatting text
speed = "Top Speed: "+string(topSpeed)+" mph";
fdroop = "Closest to Full Droop (front): "+ string(maxfd)+" in";
rdroop = "Cosest to Full Droop (rear): "+ string(maxrd)+" in";
fbump = "Closest to Full Bump (front): "+ string(maxfb)+" in";
rbump = "Closest to Full Bump (rear): "+ string(maxrb)+" in";

%text
subplot(2,2,4);
text(0,0.5,speed+newline+fdroop+newline+rdroop+newline+fbump+newline+rbump);
axis off;
%accels
%{
subplot(2,2,4);
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