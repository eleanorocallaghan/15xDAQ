function [carSpeed,topSpeed]=skrrrt(hallEffect)
%replaces car speed plot
%transforms hall effect sensor data to car speed
carSpeed = hallEffect*(1/55)*(20*pi)*60*60*(1/63360);
topSpeed = max(carSpeed);
end