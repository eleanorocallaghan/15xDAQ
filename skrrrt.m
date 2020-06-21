function [carSpeed,topSpeed,speed,maxSpeed]=skrrrt(hallEffect, sog)
%replaces car speed plot
%transforms hall effect sensor data to car speed
%from hall effect
carSpeed = hallEffect*(1/55)*(20*pi)*60*60*(1/63360);
topSpeed = max(carSpeed);
%from GPS
speed=sog/1.61;
maxSpeed=max(speed);
end