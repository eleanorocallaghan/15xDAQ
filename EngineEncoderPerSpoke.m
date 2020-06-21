function [rpm] = EngineEncoderPerSpoke(sampletime, encoder)
frequency = 1
numspokes = 2;
spokecount = 0;
numsamples = size(sampletime, 1)
rpm = [];
count = 2;
time(1) = sampletime(2)-sampletime(1)

for i = 2:numsamples
    if encoder(i) == 1 && encoder(i-1) == 0 
        time(i) = sampletime(i)-sampletime(i-1);
        rpm(i) = (1/numspokes)/(time(i)/60)
        if time(i) > 2*time(i-1) | time(i) < (1/2)*time(i-1)
            time(i)=[];
            encoder(i)= [];
            rpm(i) = [];
        end
    end             
end 
for j = 1:length(time)
    averagerpm
end 