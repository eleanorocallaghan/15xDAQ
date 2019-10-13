totalTime = size(Data,1);
time = (1:totalTime); 
duration = (totalTime/1200) % sample rate was 1200 Hz
testNumber = input("Test Number? ");

% get data from TCS data matrix based on port #
rearLinPot = Data(:,1);
xAccel = Data(:,2);
yAccel = Data(:,3);
frontLinPot = Data(:,4);
stringPot = Data(:,6);
zAccel = Data(:,7);
hallEffect = Data(:,16);

% plot linear potentiomter data
clf(figure(1))
figure(1);
plot(time,rearLinPot,"blue");
title("Linear Potentiometers");
hold on
plot(time,frontLinPot,"red");
legend('rear', 'front');

% plot string potentiomter data
clf(figure(2))
figure(2)
plot(time,stringPot);
title("String Potentiometer");

% plot hall effect data
clf(figure(3))
figure(3)
plot(time,hallEffect);
title("Hall Effect");

% plot accelerometer data
clf(figure(4))
figure(4)
plot(time,xAccel,"blue");
hold on
plot(time,yAccel,"red");
hold on
plot(time,zAccel,"green");
title("Accelerometer");

% plot car speed data
carSpeed = hallEffect*(1/55)*(22*pi)*60*60*(1/63360); %divide by number of 
% teeth, multiply by wheel circumference, convert to hours from seconds, 
% convert to miles from inches
clf(figure(5))
figure(5);
plot(time,carSpeed,"blue");
title("Car Speed (mph)");

% save data
fileName = strcat(string(testNumber),"driveDay190929");
save(fileName);

