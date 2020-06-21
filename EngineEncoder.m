function [rpm] = EngineEncoder(sampletime, encoder)

numspokes = 2;
spokecount = 0;
numsamples = size(sampletime, 1)
rpm = [];
count = 2;

while count < numsamples
    
    if spokecount == 1 && encoder(count-2) == 0 && encoder(count-1) == 1 % if this is the first spoke of this revolution
        startcount = count - 1 % this is the starting time
    end
    
    if spokecount == numspokes % if all of the spokes have gone around once
        endcount = count - 1 % this is the ending time
        revtime = sampletime(endcount)-sampletime(startcount) % time for one revolution (sec)
        rpm([startcount:endcount]) = 60/revtime % add the new data to the rpm vector
        spokecount = 0
    end
        
    if encoder(count) == 1 && encoder(count-1) == 0
        fprintf('yes')
        spokecount = spokecount + 1
    end
    
    count = count + 1
    
end