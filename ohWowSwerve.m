function [steeringAngle]=ohWowSwerve(stringPot)
%replaces string potentiometer plot
%total steering angle: 315 degree
%angle ranges from  -157.5 to 157.5

maxAngle=157.5;
%stringPot=cutData(:,5); %stringPot data ranges from -1 to 1
steeringAngle=maxAngle*stringPot;
%returns steering angle for plotting/data updating purposes
end