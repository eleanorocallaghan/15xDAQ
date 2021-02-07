%Inputs to the function 
TestDate = input('Test Date (yymmdd)? ');
TestNumber = input('Test Number? ');

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
timebeg = (1:firstCutoff);
timeend = (finalCutoff:TotalTime);

%pull out the data of interest determined by the interval 
stringPot1 = RawData(timebeg,sp);
stringPot2 = RawData(timeend,sp);

% change time to seconds and make time intervals
timebegsec = transpose(timebeg/SamplingFrequency);
timeendsec = transpose(timeend/SamplingFrequency);

% complete the forier transform
fft1 = fft(stringPot1);
fft2 = fft(stringPot2);

% next steps pulled from:
% https://www.mathworks.com/help/matlab/ref/fft.html                  
T = 1/SamplingFrequency;   % Sampling period       
L1 = size(timebeg,2); 
L2 = size(timeend,2); 
t1 = (0:L1-1)*T;        % Time vector
t2 = (0:L2-1)*T;

%have to do some different stuff depending on if it is odd or even
s1 = (-1)^(L1);
if s1 == -1
    P21 = abs(fft1/L1);
    P11 = P21(1:L1/2+.5);
    P11(2:end-1) = 2*P11(2:end-1);
    f1 = SamplingFrequency*(0:(L1/2))/L1;
else
    P21 = abs(fft1/L1);
    P11 = P21(1:L1/2+1);
    P11(2:end-1) = 2*P11(2:end-1);  
   f1 = SamplingFrequency*(0:(L1/2))/L1;
end  
figure(1)
plot(f1,P11*SamplingFrequency) 
title('Single-Sided Amplitude Spectrum of X(t)')
axis([-1 20 0 inf])
xlabel('f (Hz)')
ylabel('|P1(f)|')

s2 = (-1)^(L2);
if s2 == -1
    P22 = abs(fft2/L2);
    P12 = P22(1:L2/2+.5);
    P12(2:end-1) = 2*P12(2:end-1);
    f2 = SamplingFrequency*(0:(L2/2))/L2;
else
    P22 = abs(fft2/L2);
    P12 = P22(1:L2/2+1);
    P12(2:end-1) = 2*P12(2:end-1); 
    f2 = SamplingFrequency*(0:(L2/2))/L2;
end  
figure(2)
plot(f2,P12*SamplingFrequency) 
axis([-1 20 0 inf])
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')