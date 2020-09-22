%Inputs to the function 
TestDate = input('Test Date (yymmdd)? ');
TestNumber = input('Test Number? ');
NumberofTests = input ('Number of Tests?');

%Read the CSV file with testin info + convert names to an array
DayInfo = readtable(strcat(string(TestDate), ' Drive Day Tests - Sheet1.csv'));
TestsInfo = DayInfo(21:end,:);

%Calibration Inputs 
%Front Lin Pot
FrontPerVoltExcitation = 1;
FrontSensitivity = 5;
FrontOffset = (.6647+.6397)/10;

%Rear Lin Pot
RearPerVoltExcitation = 5;
RearSensitivity = 20;
RearOffset = 2.4;

%Other Inputs
SamplingFrequency = 1200;
maxSteeringAngle = 157.5;

% shock  Inputs
springRate = 80;
dampCoeff = 19.42;

%set up the test # function for the for loop
TestNumber = TestNumber - 1;

%Set up matracies for maximums of multiple tests
CarSpeedMat = [0 0];
gpsMat= [0 0];
fdroopMat = [0 0];
rdroopMat = [0 0];
fbumpMat = [0 0];
rbumpMat = [0 0];
frontForceMat = [0 0];
rearForceMat = [0 0];

for j = (0:1:NumberofTests-1)
    
TestNumber = TestNumber + 1;

%Assign Column values to varribles 
for i = 1:20
    if table2array(DayInfo(i,2)) == "Hall Effect"
        he = i;
    end
    if table2array(DayInfo(i,2)) == "X Acceleration"
        x = i; %these are index values for later
    end
    if table2array(DayInfo(i,2)) == "Y Acceleration"
        y = i;
    end
    if table2array(DayInfo(i,2)) == "Z Acceleration"
        z = i;
    end
    if table2array(DayInfo(i,2)) == "Front Linear Potentiometer"
        flp = i;
    end
    if table2array(DayInfo(i,2)) == "Rear Linear Potentiometer"
        rlp = i;
    end
    if table2array(DayInfo(i,2)) == "String Potentiometer"
        sp = i;
    end
    if table2array(DayInfo(i,2)) == "GPS Latitude"
        lat = i;
    end
    if table2array(DayInfo(i,2)) == "GPS Longitude"
        long = i;
    end
    if table2array(DayInfo(i,2)) == "GPS SOG"
        sog = i;
    end
    %add more ifs when more sensors are attached for later tests
end


%Read in the data from that day and get it into array format
DataFile = strcat(string(TestDate),'DriveDay_',string(sprintf( '%04d',TestNumber)),'.mat');
S = load(DataFile);
RawData = S.Data;

%Figure out timing
% This splits the time into 2 parts and determines a start and end time for
% plotting
TotalTime = size(RawData, 1);
firstCutoff = 1;
for i = 1:TotalTime/2
    if RawData(i,he) > 5 %records last pt for which HE=0 before car starts
        firstCutoff = i;
        break;
    end
end
for j = TotalTime:-1:TotalTime/2
    if RawData(j,he) > 5 %records last pt where HE=0 after car stops
        finalCutoff = j;
        break;
    end
end
%modifies plotting so it is between two cutoffs 
time=(firstCutoff:finalCutoff);

% Filtering The data (need to do more reseach on this)
% filtering the data (2 gaussian filters)
s1 = 100; % sigma for hall effect filter
gf1 = gausswin(6*s1 + 1)';
gf1 = gf1 / sum(gf1); % normalize

s2=10; %sigma and fit for everything else
gf2=gausswin(6*s2+1)';
gf2=gf2/sum(gf2);

%reorganizing/fitting the data
rearLinPot = conv(RawData(time,rlp),gf2,'same');
xAccel = conv(RawData(time,x),gf1,'same');
yAccel = conv(RawData(time,y),gf1,'same');
frontLinPot = conv(RawData(time,flp),gf2,'same');
stringPot = conv(RawData(time,sp),gf2,'same');
zAccel = conv(RawData(time,z),gf1,'same');
hallEffect = conv(RawData(time,he),gf1,'same');

%reorganizing GPS data
longitude = RawData(time,long);
latitude = RawData(time,lat);
sog = conv(RawData(time,sog),gf1,'same');

%Adding a time X axis to the arrays for plotting (subtraction so time
%starts at 0)
TimeSeconds = transpose((time/SamplingFrequency)-(firstCutoff/SamplingFrequency));

%Clear Figure and Start New one numbered same as test
clf(figure(TestNumber))
figure(TestNumber)

%Use Claibration on lin pots to determine disp of shocks

frontShock = (frontLinPot*FrontPerVoltExcitation/FrontSensitivity - FrontOffset)*5;
rearShock = (rearLinPot*RearPerVoltExcitation/RearSensitivity - RearOffset)*5;

%closest to full bump for both potentiometers
maxFrontBump = min(frontShock);
maxRearBump = min(rearShock);

%closest to full droop for both potentiometers
maxFrontDroop = max(frontShock);
maxRearDroop = max(rearShock);

%Start plotting these now!!
subplot(2,3,1);
plot(TimeSeconds,frontShock,"blue");
title("Shock Extension/Compression");
hold on
plot(TimeSeconds,rearShock,"red");
legend('front','rear');
xlabel('Time (sec)');
ylabel('Shock Displacement (inches)');
hold off

%Calculates Shock Velocity 
dxf = diff(frontShock); 
dxr = diff(rearShock);
dt = diff(TimeSeconds); %takes the difference between every time value and 
% the next one (should be 1/1200HZ)
vfshock = dxf./dt; % divide them to get the derivative of displacement (velocity)
vrshock = dxr./dt;

atime = TimeSeconds(120:end-120); % get rid of first part of time because there are weird spikes
vfshock = vfshock(120:end-120); %see above
vrshock = vrshock(120:end-120);
%Calculate Shock force
Ffshock = springRate * (frontShock(120:end-121)) + dampCoeff * vfshock;
Frshock = springRate * (rearShock(120:end-121)) + dampCoeff * vrshock;
maxFForce = max(abs(Ffshock));
maxRForce = max(abs(Frshock));
subplot(2,3,2)
plot(atime(1:end-1), Ffshock)
hold on
plot (atime(1:end-1), Frshock)
hold off
title("Shock Force")
xlabel("time (sec)")
ylabel("force (lbs)")
legend("front", "rear")

%steering angle
subplot(2,3,3)
steeringAngle = maxSteeringAngle*stringPot;
plot (TimeSeconds,steeringAngle);
title("Steering Angle");
xlabel('Time (sec)');
ylabel('Steering Angle (degrees)');

%car speed
subplot(2,3,4);
%from hall effect
carSpeed = hallEffect*(1/55)*(20*pi)*60*60*(1/63360);
%from GPS
gpsSpeed = sog/1.61;
plot(TimeSeconds,carSpeed);
hold on
plot(TimeSeconds,gpsSpeed,"red")
title("Car Speed"); 
xlabel('Time (sec)');
ylabel('Speed (mph)');
legend("from hall effect","from GPS");

%formatting text
speed = "(Hall Effect) Top Speed: "+string(max(carSpeed))+" mph";
gpsTop="(GPS) Top Speed: "+string(max(gpsSpeed))+" mph";
fdroop = "Closest to Full Droop (front): "+ string(maxFrontDroop)+" in";
rdroop = "Cosest to Full Droop (rear): "+ string(maxRearDroop)+" in";
fbump = "Closest to Full Bump (front): "+ string(maxFrontBump)+" in";
rbump = "Closest to Full Bump (rear): "+ string(maxRearBump)+" in";
frontForce = "Highest Force from Shocks (front): " + string(maxFForce) + " lbs";
rearForce = "Highest Force from Shocks (rear): " + string(maxRForce) + " lbs";

%Add maxs to matracies
CarSpeedMat = [CarSpeedMat; TestNumber max(carSpeed)];
gpsMat= [gpsMat; TestNumber max(gpsSpeed)];
fdroopMat = [fdroopMat ; TestNumber maxFrontDroop];
rdroopMat = [rdroopMat ; TestNumber maxRearDroop];
fbumpMat = [fbumpMat ; TestNumber maxFrontBump];
rbumpMat = [rbumpMat ; TestNumber maxRearBump];
frontForceMat = [frontForceMat ; TestNumber maxFForce];
rearForceMat = [rearForceMat ; TestNumber maxRForce];

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

%Print text
subplot(2,3,6);
text(0,0.5, speed + newline + gpsTop + newline + fdroop + newline + rdroop + newline + fbump + newline + rbump + newline + frontForce + newline + rearForce);
axis off;
TestName = table2array(TestsInfo(TestNumber,4));
sgtitle("Test # "+string(TestNumber)+": "+string(TestName));

end

figure('Name','Maximums','NumberTitle','off');

[A,B] = max(abs((CarSpeedMat)));
[C,D] = max(abs((gpsMat)));
[E,F] = max(abs((fdroopMat)));
[G,H] = max(abs((rdroopMat)));
[I,J] = max(abs((fbumpMat)));
[K,L] = max(abs((rbumpMat)));
[M,N] = max(abs((frontForceMat)));
[O,P] = max(abs((rearForceMat)));

%formatting text
Maxspeed = "(Hall Effect) Top Speed: "+ string(CarSpeedMat(B(1,2),2))+" mph                              From Test Number"+string(CarSpeedMat(B(1,2),1));
MaxgpsTop="(GPS) Top Speed: "+ string(gpsMat(D(1,2),2))+" mph                                            From Test Number" +string(gpsMat(D(1,2),1));
Maxfdroop = "Closest to Full Droop (front): "+ string(fdroopMat(F(1,2),2))+" in                          From Test Number" +string(fdroopMat(F(1,2),1));
Maxrdroop = "Cosest to Full Droop (rear): "+ string(rdroopMat(H(1,2),2))+" in                            From Test Number" +string(rdroopMat(H(1,2),1));
Maxfbump = "Closest to Full Bump (front): "+ string(fbumpMat(J(1,2),2))+" in                             From Test Number" +string(fbumpMat(J(1,2),1));
Maxrbump = "Closest to Full Bump (rear): "+ string(rbumpMat(L(1,2),2))+" in                              From Test Number" +string(rbumpMat(L(1,2),1));
MaxfrontForce = "Highest Force from Shocks (front): " + string(frontForceMat(N(1,2),2))+" lbs            From Test Number" +string(frontForceMat(N(1,2),1));
MaxrearForce = "Highest Force from Shocks (rear): " + string(rearForceMat(P(1,2),2))+" lbs               From Test Number" +string(rearForceMat(P(1,2),1));

text(0,0.5, Maxspeed + newline + MaxgpsTop + newline + Maxfdroop + newline + Maxrdroop + newline + Maxfbump + newline + Maxrbump + newline + MaxfrontForce + newline + MaxrearForce);
axis off;
sgtitle("Maximums from All Tests");


disp('done');
