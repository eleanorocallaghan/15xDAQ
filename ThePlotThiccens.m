%plotting function for modified data
%takes data cleaned up in formatting function (DriveDay190929v1.2)
%puts data in a subplot

function[]=ThePlotThiccens(cleanedDataName,testNumber)
cleanedData=load(cleanedDataName);
cleanedData = cleanedData.cutData;
time=(1:size(cleanedData,1));
timeSeconds=(time/1200.0)-(1/1200.0);

rearLinPot = cleanedData(time,7);
xAccel = cleanedData(time,2);
yAccel = cleanedData(time,3);
frontLinPot = cleanedData(time,6);
stringPot = cleanedData(time,5);
zAccel = cleanedData(time,4);
hallEffect = cleanedData(time,1);

close all
clf(figure(testNumber))
figure(testNumber)
subplot(3,2,1);
plot(timeSeconds,rearLinPot,"blue");
title("Linear Potentiometers");
hold on
plot(timeSeconds,frontLinPot,"red");
legend('rear','front');
hold off

subplot(3,2,2)
plot(timeSeconds,stringPot);
title("String Potentiometer");

subplot(3,2,3);
plot(timeSeconds,hallEffect);
title("Hall Effect");

subplot(3,2,4);
plot(timeSeconds,xAccel,"blue");
hold on
plot(timeSeconds,yAccel,"red");
hold on
plot(timeSeconds,zAccel,"green");
title("Accelerometer");
legend('x','y','z');
hold off

carSpeed=hallEffect*(1/55)*(20*pi)*60*60*(1/63360);
subplot(3,2,5);
plot(timeSeconds,carSpeed,"blue");
title("Car Speed (mph)");

sgtitle(strcat('Test # ',string(testNumber)));
end