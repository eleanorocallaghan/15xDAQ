%calling this HighestInTheRoom
%calculates maximum speeds and shock forces from all the tests

date=input("Test Date?(yymmdd)",'s');
filenames = load(date+"TestFiles");
filenames = filenames.cleanedDataNames;
%max of the max speeds, hall effect and GPS
rmh = 0; %reference maximum (hall effect)
htest=0;
rmg = 0; %reference maximum (GPS) (km/h)
gtest=0;
rmf = 0; %reference maximum (front shock force)
ftest = 0;
rmr = 0; %reference maximum (rear shock force)
rtest = 0;

for i = 1:size(filenames)
    if string(filenames(i)) ~= "N/A"
        data=load(string(filenames(i)));
        data=data.cutData;
        time = (1:size(data(:,1)));
        timeSeconds = time/1200.0 -1200.0;
        %speeds
        if max(data(:,1)) >= rmh
            rmh = max(data(:,1));
            htest = i;
        end
        if max(data(:,10)) >= rmg
            rmg = max(data(:,10));
            gtest = i;
        end
        %shock forces (oh boy)
        frontLinPot = data(:,6);
        rearLinPot = data(:,7);
        [fshock,rshock,maxfd,maxrd,maxfb,maxrb] = mainSqueeze(rearLinPot,frontLinPot);
        
        % shock velocity
        dxf = diff(fshock); % takes the difference between every shock travel value 
        % and the next value
        dxr = diff(rshock);
        dxf = dxf'; %transpose
        dxr = dxr';
        dt = diff(timeSeconds); %takes the difference between every time value and 
        % the next one (should be 1/1200HZ)
        vfshock = dxf./dt; % divide them to get the derivative of displacement (velocity)
        vrshock = dxr./dt;

        time = time(1:end-1); % change size of time so that it matches after 
        % differentiation
        time = time/1200; % get time into actual seconds

        time = time(120:end-120); % get rid of first part of time because there are weird spikes
        vfshock = vfshock(120:end-120); %see above
        vrshock = vrshock(120:end-120);
        time = time';
        vfshock = vfshock'; % transpose
        vrshock = vrshock';
        % shock force 
        springRate = 80;
        dampCoeff = 19.42;

        cutfshock = fshock(120:end-121);
        cutrshock = rshock(120:end-121);

        % timeSize = size(time)
        % vfShockSize = size(vfshock)
        % fShockSize = size(cutfshock)

        Ffshock = springRate * cutfshock + dampCoeff * vfshock;
        Frshock = springRate * cutrshock + dampCoeff * vrshock;
        maxFForce = max(abs(Ffshock));
        maxRForce = max(abs(Frshock));
        %time = time'; % transpose
        if maxFForce >= rmf
            rmf = maxFForce;
            ftest = i;
        end
        if maxRForce >= rmr
            rmr = maxRForce;
            rtest = i;
        end
    end
end


fastestHall = rmh*(1/55)*(20*pi)*60*60*(1/63360);
fastestGPS = rmg./1.61;

fprintf(newline+"Fastest Hall Effect Speed: "+string(fastestHall)+" mph, from test " +htest);
fprintf(newline+"Fastest GPS Speed: "+string(fastestGPS)+" mph, from test "+gtest);

fprintf(newline+"Maximum Front Shock Force: "+rmf+" lb, from test "+ftest);
fprintf(newline+"Maximum Rear Shock Force: "+rmr+" lb, from test "+rtest);


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