//  Matlab script for image classification:

clear;
close all;
 
pathOfWaterImage = '.\Project1\Water';
pathOfMask = '.\Project1\WaterMask';
pathOfNonWaterImage = '.\Project1\NoWater';
 
windowSize = 20;%20
 
listOfWaterImage = dir([pathOfWaterImage,'\*.jpg']);
numberOfWaterImage = size(listOfWaterImage,1);
numberOfWaterTrainingExample = ceil(numberOfWaterImage/3);
 
listOfNonWaterImage = dir([pathOfNonWaterImage,'\*.jpg']);
numberOfNonWaterImage = size(listOfNonWaterImage,1);
numberOfNonWaterTrainingExample = ceil(numberOfNonWaterImage/3);
 
numberOfSubImage = 0;
numberOfSubWaterImage = 0;
numberOfSubNonWaterImage = 0;
 
vectorWater = [];
vectorNonWater = [];
numberOfElements = 8; %8
stepSize = 1/(numberOfElements);
 
for m = 1:numberOfWaterTrainingExample
    nameOfImage = listOfWaterImage(m).name;
    pic = imread([pathOfWaterImage,'\',nameOfImage]);
    pichsv = rgb2hsv(pic);
    mask = imread([pathOfMask,'\',nameOfImage]);
    mask = mask(:,:,1);
    height = size(pic,1);
    width = size(pic,2);
    water = 0;
    noWater = 0;
    for p = 1:windowSize:(height-windowSize)
        for q = 1:windowSize:(width-windowSize)
            subpic = pic( p:(p+windowSize-1), q:(q+windowSize-1),:);
            subpichsv = pichsv( p:(p+windowSize-1), q:(q+windowSize-1),:);
            submask = mask(  p:(p+windowSize-1), q:(q+windowSize-1) );
            if(sum(sum(submask))/numel(submask)==255)
                numberOfSubNonWaterImage = numberOfSubNonWaterImage + 1;
                noWater = noWater + 1;
                idx = numberOfSubNonWaterImage;
                vectorNonWater = [vectorNonWater,zeros(numberOfElements*6,1)];
                for n = 1:size(subpic,1)
                    for l = 1:size(subpic,2)
                        red = double(subpic(n,l,1))/255;
                        green = double(subpic(n,l,2))/255;
                        blue = double(subpic(n,l,3))/255;
                        redIdx = floor((red)/stepSize)+1;
                        if(redIdx > numberOfElements)redIdx = numberOfElements;end
                        greenIdx = floor((green)/stepSize)+1;
                        if(greenIdx > numberOfElements)greenIdx = numberOfElements;end
                        blueIdx = floor((blue)/stepSize)+1;
                        if(blueIdx > numberOfElements)blueIdx = numberOfElements;end
                        
                        h = subpichsv(n,l,1);
                        s = subpichsv(n,l,2);
                        v = subpichsv(n,l,3);
                        hIdx = floor((h)/stepSize)+1;
                        if(hIdx > numberOfElements)hIdx = numberOfElements;end
                        sIdx = floor((s)/stepSize)+1;
                        if(sIdx > numberOfElements)sIdx = numberOfElements;end
                        vIdx = floor((v)/stepSize)+1;
                        if(vIdx > numberOfElements)vIdx = numberOfElements;end    
                            
                        vectorNonWater(redIdx,idx) = vectorNonWater(redIdx,idx) + 1;
                        vectorNonWater(greenIdx+numberOfElements,idx) = vectorNonWater(greenIdx+numberOfElements,idx) + 1;
                        vectorNonWater(blueIdx+numberOfElements*2,idx) = vectorNonWater(blueIdx+numberOfElements*2,idx) + 1;
                        vectorNonWater(hIdx+numberOfElements*3,idx) = vectorNonWater(hIdx+numberOfElements*3,idx) + 1;
                        vectorNonWater(sIdx+numberOfElements*4,idx) = vectorNonWater(sIdx+numberOfElements*4,idx) + 1;
                        vectorNonWater(vIdx+numberOfElements*5,idx) = vectorNonWater(vIdx+numberOfElements*5,idx) + 1;
                    end
                end
            else
                numberOfSubWaterImage = numberOfSubWaterImage + 1;
                water = water +1;
                idx = numberOfSubWaterImage;
                vectorWater = [vectorWater,zeros(numberOfElements*6,1)];
                for n = 1:size(subpic,1)
                    for l = 1:size(subpic,2)
                        red = double(subpic(n,l,1))/255;
                        green = double(subpic(n,l,2))/255;
                        blue = double(subpic(n,l,3))/255;
                        redIdx = floor((red)/stepSize)+1;
                        if(redIdx > numberOfElements)redIdx = numberOfElements;end
                        greenIdx = floor((green)/stepSize)+1;
                        if(greenIdx > numberOfElements)greenIdx = numberOfElements;end
                        blueIdx = floor((blue)/stepSize)+1;
                        if(blueIdx > numberOfElements)blueIdx = numberOfElements;end
                        
                        h = subpichsv(n,l,1);
                        s = subpichsv(n,l,2);
                        v = subpichsv(n,l,3);
                        hIdx = floor((h)/stepSize)+1;
                        if(hIdx > numberOfElements)hIdx = numberOfElements;end
                        sIdx = floor((s)/stepSize)+1;
                        if(sIdx > numberOfElements)sIdx = numberOfElements;end
                        vIdx = floor((v)/stepSize)+1;
                        if(vIdx > numberOfElements)vIdx = numberOfElements;end    
                            
                        vectorWater(redIdx,idx) = vectorWater(redIdx,idx) + 1;
                        vectorWater(greenIdx+numberOfElements,idx) = vectorWater(greenIdx+numberOfElements,idx) + 1;
                        vectorWater(blueIdx+numberOfElements*2,idx) = vectorWater(blueIdx+numberOfElements*2,idx) + 1;
                        vectorWater(hIdx+numberOfElements*3,idx) = vectorWater(hIdx+numberOfElements*3,idx) + 1;
                        vectorWater(sIdx+numberOfElements*4,idx) = vectorWater(sIdx+numberOfElements*4,idx) + 1;
                        vectorWater(vIdx+numberOfElements*5,idx) = vectorWater(vIdx+numberOfElements*5,idx) + 1;
                    end
                end
            end
        end
    end
    disp(['water ratio: ',num2str(water/(water+noWater))]);
    %disp(['no water ratio: ',num2str(noWater/(water+noWater))]);
end
 
for m = 1:numberOfNonWaterTrainingExample
    nameOfImage = listOfNonWaterImage(m).name;
    pic = imread([pathOfNonWaterImage,'\',nameOfImage]);
    pichsv = rgb2hsv(pic);
    
    height = size(pic,1);
    width = size(pic,2);
    for p = 1:windowSize:(height-windowSize)
        for q = 1:windowSize:(width-windowSize)
            subpic = pic( p:(p+windowSize-1), q:(q+windowSize-1),:);
            subpichsv = pichsv( p:(p+windowSize-1), q:(q+windowSize-1),:);
            numberOfSubNonWaterImage = numberOfSubNonWaterImage + 1;
            idx = numberOfSubNonWaterImage;
            vectorNonWater = [vectorNonWater,zeros(numberOfElements*6,1)];
            for n = 1:size(subpic,1)
                for l = 1:size(subpic,2)
                    red = double(subpic(n,l,1))/255;
                    green = double(subpic(n,l,2))/255;
                    blue = double(subpic(n,l,3))/255;
                    redIdx = floor((red)/stepSize)+1;
                    if(redIdx > numberOfElements)redIdx = numberOfElements;end
                    greenIdx = floor((green)/stepSize)+1;
                    if(greenIdx > numberOfElements)greenIdx = numberOfElements;end
                    blueIdx = floor((blue)/stepSize)+1;
                    if(blueIdx > numberOfElements)blueIdx = numberOfElements;end
 
                    h = subpichsv(n,l,1);
                    s = subpichsv(n,l,2);
                    v = subpichsv(n,l,3);
                    hIdx = floor((h)/stepSize)+1;
                    if(hIdx > numberOfElements)hIdx = numberOfElements;end
                    sIdx = floor((s)/stepSize)+1;
                    if(sIdx > numberOfElements)sIdx = numberOfElements;end
                    vIdx = floor((v)/stepSize)+1;
                    if(vIdx > numberOfElements)vIdx = numberOfElements;end    
 
                    vectorNonWater(redIdx,idx) = vectorNonWater(redIdx,idx) + 1;
                    vectorNonWater(greenIdx+numberOfElements,idx) = vectorNonWater(greenIdx+numberOfElements,idx) + 1;
                    vectorNonWater(blueIdx+numberOfElements*2,idx) = vectorNonWater(blueIdx+numberOfElements*2,idx) + 1;
                    vectorNonWater(hIdx+numberOfElements*3,idx) = vectorNonWater(hIdx+numberOfElements*3,idx) + 1;
                    vectorNonWater(sIdx+numberOfElements*4,idx) = vectorNonWater(sIdx+numberOfElements*4,idx) + 1;
                    vectorNonWater(vIdx+numberOfElements*5,idx) = vectorNonWater(vIdx+numberOfElements*5,idx) + 1;
                end
            end
        end
    end
end
vectorWater = vectorWater/windowSize^2;
vectorNonWater = vectorNonWater/windowSize^2;
muWater = mean(vectorWater')';
muNonWater = mean(vectorNonWater')';
 
numberOfSubImage = numberOfSubNonWaterImage + numberOfSubWaterImage;
pWater = numberOfSubWaterImage/numberOfSubImage;
pNonWater = numberOfSubNonWaterImage/numberOfSubImage;
 
sigmaWater = zeros(numberOfElements*6);
for m = 1:numberOfSubWaterImage
    vec = vectorWater(:,m) - muWater;
    sigmaWater = sigmaWater + vec*vec';
end
sigmaWater = sigmaWater/numberOfSubWaterImage;
 
sigmaNonWater = zeros(numberOfElements*6);
for m = 1:numberOfSubNonWaterImage
    vec = vectorNonWater(:,m) - muNonWater;
    sigmaNonWater = sigmaNonWater + vec*vec';
end
sigmaNonWater = sigmaNonWater/numberOfSubNonWaterImage;
 
A = inv(sigmaNonWater) - inv(sigmaWater);
omega = (inv(sigmaWater))*muWater - (inv(sigmaNonWater))*muNonWater;
b0 = log(pWater/pNonWater)+0.5*log(det(sigmaNonWater)/det(sigmaWater))+0.5*(muNonWater'*(inv(sigmaNonWater))*muNonWater-muWater'*(inv(sigmaWater))*muWater);
 
right = 0; wrong = 0;
for m = (numberOfWaterTrainingExample+1):numberOfWaterImage
 
    nameOfImage = listOfWaterImage(m).name;
    pic = imread([pathOfWaterImage,'\',nameOfImage]);
    
    pichsv = rgb2hsv(pic);
    
    vec = zeros(numberOfElements*6,1);
    for n = 1:size(pic,1)
        for l = 1:size(pic,2)
            red = double(pic(n,l,1))/255;
            green = double(pic(n,l,2))/255;
            blue = double(pic(n,l,3))/255;
            redIdx = floor((red)/stepSize)+1;
            if(redIdx > numberOfElements)redIdx = numberOfElements;end
            greenIdx = floor((green)/stepSize)+1;
            if(greenIdx > numberOfElements)greenIdx = numberOfElements;end
            blueIdx = floor((blue)/stepSize)+1;
            if(blueIdx > numberOfElements)blueIdx = numberOfElements;end
 
            h = pichsv(n,l,1);
            s = pichsv(n,l,2);
            v = pichsv(n,l,3);
            hIdx = floor((h)/stepSize)+1;
            if(hIdx > numberOfElements)hIdx = numberOfElements;end
            sIdx = floor((s)/stepSize)+1;
            if(sIdx > numberOfElements)sIdx = numberOfElements;end
            vIdx = floor((v)/stepSize)+1;
            if(vIdx > numberOfElements)vIdx = numberOfElements;end    
 
            vec(redIdx) = vec(redIdx) + 1;
            vec(greenIdx+numberOfElements) = vec(greenIdx+numberOfElements) + 1;
            vec(blueIdx+numberOfElements*2) = vec(blueIdx+numberOfElements*2) + 1;
            vec(hIdx+numberOfElements*3) = vec(hIdx+numberOfElements*3) + 1;
            vec(sIdx+numberOfElements*4) = vec(sIdx+numberOfElements*4) + 1;
            vec(vIdx+numberOfElements*5) = vec(vIdx+numberOfElements*5) + 1;
        end
    end
    vec = vec/(size(pic,1)*size(pic,2));
    discriminant = 0.5*vec'*A*vec+omega'*vec+b0;
    if(discriminant>0)disp('Water: Right');right = right+1;else disp('Water: Wrong');wrong=wrong+1;end
end
 
 
right2 = 0; wrong2 = 0;
for m = (numberOfNonWaterTrainingExample+1):numberOfNonWaterImage
    nameOfNonImage = listOfNonWaterImage(m).name;
    pic = imread([pathOfNonWaterImage,'\',nameOfNonImage]);
 
    pichsv = rgb2hsv(pic);
    
    vec = zeros(numberOfElements*6,1);
    for n = 1:size(pic,1)
        for l = 1:size(pic,2)
            red = double(pic(n,l,1))/255;
            green = double(pic(n,l,2))/255;
            blue = double(pic(n,l,3))/255;
            redIdx = floor((red)/stepSize)+1;
            if(redIdx > numberOfElements)redIdx = numberOfElements;end
            greenIdx = floor((green)/stepSize)+1;
            if(greenIdx > numberOfElements)greenIdx = numberOfElements;end
            blueIdx = floor((blue)/stepSize)+1;
            if(blueIdx > numberOfElements)blueIdx = numberOfElements;end
 
            h = pichsv(n,l,1);
            s = pichsv(n,l,2);
            v = pichsv(n,l,3);
            hIdx = floor((h)/stepSize)+1;
            if(hIdx > numberOfElements)hIdx = numberOfElements;end
            sIdx = floor((s)/stepSize)+1;
            if(sIdx > numberOfElements)sIdx = numberOfElements;end
            vIdx = floor((v)/stepSize)+1;
            if(vIdx > numberOfElements)vIdx = numberOfElements;end    
 
            vec(redIdx) = vec(redIdx) + 1;
            vec(greenIdx+numberOfElements) = vec(greenIdx+numberOfElements) + 1;
            vec(blueIdx+numberOfElements*2) = vec(blueIdx+numberOfElements*2) + 1;
            vec(hIdx+numberOfElements*3) = vec(hIdx+numberOfElements*3) + 1;
            vec(sIdx+numberOfElements*4) = vec(sIdx+numberOfElements*4) + 1;
            vec(vIdx+numberOfElements*5) = vec(vIdx+numberOfElements*5) + 1;
        end
    end
    vec = vec/(size(pic,1)*size(pic,2));
    discriminant = 0.5*vec'*A*vec+omega'*vec+b0;
    if(discriminant<0)disp('No Water: Right');right2 = right2+1;else disp('No water: Wrong');wrong2=wrong2+1;end
end
 
disp(['Correct rate is: ',num2str((right+right2)/(right+right2+wrong+wrong2))]);
