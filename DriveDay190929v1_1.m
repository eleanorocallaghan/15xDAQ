%Modifications:
%unnecessary data (car wasn't moving) removed from time and data tables
%time on plots made into seconds, with 0 being the point where the car
%started moving

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

testNumber = input("Test Number?");
fileName = strcat(string(testNumber),"driveDay190929");
rearLinPot = Data(time,1);
xAccel = Data(time,2);
yAccel = Data(time,3);
frontLinPot = Data(time,4);
stringPot = Data(time,6);
zAccel = Data(time,7);
hallEffect = Data(time,16);
figure(1);
plot(timeSeconds,rearLinPot,"blue");
title("Linear Potentiometers");
hold on
plot(timeSeconds,frontLinPot,"red");
figure(2)
plot(timeSeconds,stringPot);
title("String Potentiometer");
figure(3)
plot(timeSeconds,hallEffect);
title("Hall Effect");
figure(4)
plot(timeSeconds,xAccel,"blue");
hold on
plot(timeSeconds,yAccel,"red");
hold on
plot(timeSeconds,zAccel,"green");
title("Accelerometer");
save(fileName);
carSpeed=hallEffect*(1/55)*(20*pi)*60*60*(1/63360);
figure(5);
plot(timeSeconds,carSpeed,"blue");
title("Car Speed (mph)");

