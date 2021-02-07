%Inputs to the function 
TestDate = input('Test Date (yymmdd)? ');
TestNumber = input('Test Number? ');

%Read the CSV file with testin info + convert names to an array
DayInfo = readtable(strcat(string(TestDate), ' Drive Day Tests - Sheet1.csv'));
TestsInfo = DayInfo(21:end,:);

%Other Inputs
SamplingFrequency = 1200;

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
TotalTime = size(RawData, 1);
timescale = (1: TotalTime);

%pull out the data of interest determined by the interval 
stringPot1 = RawData(timescale,sp);

% change time to seconds and make time intervals
timesec = transpose(timescale/SamplingFrequency);

% complete the forier transform
fft1 = fft(stringPot1);

% next steps pulled from:
% https://www.mathworks.com/help/matlab/ref/fft.html                  
T = 1/SamplingFrequency;   % Sampling period       
L1 = size(timescale,2); 
t1 = (0:L1-1)*T;        % Time vector

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
%axis([-1 20 0 inf])
xlabel('f (Hz)')
ylabel('|P1(f)|')

len = (0:length(fft1)-1)*50/length(fft1);
figure (2)
plot (abs(fft1)*SamplingFrequency);
