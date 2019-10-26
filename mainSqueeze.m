function [frontShock,rearShock,maxFrontDroop,maxRearDroop, maxFrontBump, maxRearBump]=mainSqueeze(rearLinPot,frontLinPot)
%full droop: shocks are fully extended (5)
%full bump: shocks are fully compressed (0)
%needs for the plot:
%max
%minimum
%adjust plot to actually range from full bump to full droop
% currentRange = 5.0;
% fullBump = 0.0;
% fullDroop = 5.0;
% frontShock = (fullDroop-fullBump)/currentRange*frontLinPot;
% rearShock = (fullDroop-fullBump)/currentRange*rearLinPot;

frontShock = frontLinPot - (.6647+.6397)/2;
rearShock = (5/4)*rearLinPot-2.4;

%closest to full bump for both potentiometers
maxFrontBump = min(frontShock);
maxRearBump = min(rearShock);

%closest to full droop for both potentiometers
maxFrontDroop = max(frontShock);
maxRearDroop = max(rearShock);
end