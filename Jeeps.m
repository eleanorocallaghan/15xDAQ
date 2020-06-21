%goal: plot GPS data
%sample rate 3Hz
%GPSData=readtable("190928DriveDay_0015-gps.csv");
function [speed,maxSpeed] = Jeeps(sog)
%scanTime=GPSData{:,1}; %no clue what this actually is lol

%longitude=GPSData{:,4}; %y location in plot
%latitude=GPSData{:,3}; %x location in plot

%speed=GPSData{:,9}/1.61; %compare w/car speed (in mph)

%{
figure(1)
subplot(2,2,1)
plot(lat,long);
title("Course");

subplot(2,2,2)
plot(time,lat,'red');
title("Latitude vs Time");

subplot(2,2,4)
plot(time,long,'blue');
title("Longitude vs Tme");


subplot(2,2,3)
plot(time,speed);
title("Speed (Max: "+string(max(speed))+"mph)");

sgtitle("GPS data");
%}
end