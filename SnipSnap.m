%Snip Snap redux + some dataDaddy stuff
%restructuring to allow people to change whats in what plot
date = input('Test Date? (yymmdd)');
testOverview =readtable(string(date)+" Drive Day Tests - Sheet1.csv");

%determining what's in what port
for i = 1:20
    if table2array(testOverview(i,2)) == "Hall Effect"
        he = i;
    end
    if table2array(testOverview(i,2)) == "X Acceleration"
        x = i; %these are index values for later
    end
    if table2array(testOverview(i,2)) == "Y Acceleration"
        y = i;
    end
    if table2array(testOverview(i,2)) == "Z Acceleration"
        z = i;
    end
    if table2array(testOverview(i,2)) == "Front Linear Potentiometer"
        flp = i;
    end
    if table2array(testOverview(i,2)) == "Rear Linear Potentiometer"
        rlp = i;
    end
    if table2array(testOverview(i,2)) == "String Potentiometer"
        sp = i;
    end
    if table2array(testOverview(i,2)) == "GPS Latitude"
        lat = i;
    end
    if table2array(testOverview(i,2) == "GPS Longitude"
        long = i;
    end
    if table2array(testOverview(i,2)) == "GPS SOG"
        sog = i;
    end
    %add more ifs when more sensors are attached for later tests
end
indices = [he x y z sp flp rlp lat long sog]
testNumbers = table2array(testOverview(21:end,1));
testNames = table2array(testOverview(21:end,2));

%for 190928, test 1 doesn't fucking exist lol
%blank tests are 
%the following cut function will run once and then never again
yn = input("Clean Data?(y/n)");
if yn == "y"
    for j = 1:size(testNumbers)
        if(testNames(j) ~= "N/A")
            cleanedDataName = SnipSnap(testNames(j),testNumbers(j),indices);
        end
    end
end

test = input ("Which test do you want")
