%plotting function for modified data
%takes data cleaned up in formatting function (DriveDay190929v1.2)
%puts data in a subplot
function[]=DataPlotting(filename)
Data=load(filename);
time=(1:size(Data,1));
timeSeconds=(time/1200.0)-(1/1200.0);

rearLinPot = Data(time,1);
xAccel = Data(time,2);
yAccel = Data(time,3);
frontLinPot = Data(time,4);
stringPot = Data(time,6);
zAccel = Data(time,7);
hallEffect = Data(time,16);

subplot(3,2,1);
%figure(1);
plot(timeSeconds,rearLinPot,"blue");
title("Linear Potentiometers");
hold on
plot(timeSeconds,frontLinPot,"red");
legend('rear','front');

subplot(3,2,2)
%figure(2)
plot(timeSeconds,stringPot);
title("String Potentiometer");

subplot(3,2,3);
%figure(3)
plot(timeSeconds,hallEffect);
title("Hall Effect");

subplot(3,2,4);
%figure(4)
plot(timeSeconds,xAccel,"blue");
hold on
plot(timeSeconds,yAccel,"red");
hold on
plot(timeSeconds,zAccel,"green");
title("Accelerometer");
legend('x','y','z');

carSpeed=hallEffect*(1/55)*(20*pi)*60*60*(1/63360);
subplot(3,2,5);
%figure(5);
plot(timeSeconds,carSpeed,"blue");
title("Car Speed (mph)");

sgtitle(strcat('Test # ',string(testNumber)));
end