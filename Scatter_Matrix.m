clear;
close all;
 
pathOfWaterImage = '.\Water';
pathOfMask = '.\WaterMask';
 
listOfWaterImage = dir([pathOfWaterImage,'\*.jpg']);
numberOfWaterImage = size(listOfWaterImage,1);
halfWindow = 1;
winSize = halfWindow*2+1;
numberOfFeatures = winSize*winSize*3;
 
water = 0;
nonWater = 0;
for m = 1:numberOfWaterImage
    nameOfImage = listOfWaterImage(m).name;
    pictemp = imread([pathOfWaterImage,'\',nameOfImage]);
    pic = double(pictemp);
    mask = imread([pathOfMask,'\',nameOfImage]);
    mask = double(mask(:,:,1));
    height = size(pic,1);
    width = size(pic,2);
    for p = 1:height
        for q = 1:width
            if(mask(p,q)==255)nonWater = nonWater+1;
            else water = water +1;
            end
        end
    end
    if(mod(m,10)==0)disp([num2str(numberOfWaterImage-m),' images left']);end
end
 
vectorWater = zeros(27,water);
vectorNonWater = zeros(27,nonWater);
 
water = 0;
nonWater = 0;
for m = 1:numberOfWaterImage
    nameOfImage = listOfWaterImage(m).name;
    pictemp = imread([pathOfWaterImage,'\',nameOfImage]);
    pic = double(pictemp);
    mask = imread([pathOfMask,'\',nameOfImage]);
    mask = double(mask(:,:,1));
    height = size(pic,1);
    width = size(pic,2);
    picMargin = zeros(height+halfWindow*2,width+halfWindow*2,3);
    picMargin((halfWindow+1):(end-halfWindow),(halfWindow+1):(end-halfWindow),:) = pic;
    for p = 1:height
        for q = 1:width
            win = picMargin(p:(p+2*halfWindow),q:(q+2*halfWindow),:);
            channel1 = win(:,:,1);
            channel2 = win(:,:,2);
            channel3 = win(:,:,3);
            v=[channel1(:);channel2(:);channel3(:)];
            if(mask(p,q)==255)
                water = water+1;
                vectorWater(:,water)=v;
            else
                nonWater = nonWater+1;
                vectorNonWater(:,nonWater)=v;
            end
        end
    end
    if(mod(m,10)==0)disp([num2str(numberOfWaterImage-m),' images left']);end
end
 
pWater = water/(water+nonWater);
pNonWater = nonWater/(water+nonWater);
 
waterMean = mean(vectorWater')';
nonWaterMean = mean(vectorNonWater')';
 
sigmaWater = zeros(27,27);
for m = 1:water
    v = vectorWater(:,m);
    sigmaWater = sigmaWater + (v-waterMean)*(v-waterMean)';
end
sigmaWater = sigmaWater/water;
 
sigmaNonWater = zeros(27,27);
for m = 1:nonWater
    v = vectorNonWater(:,m);
    sigmaNonWater = sigmaNonWater + (v-nonWaterMean)*(v-nonWaterMean)';
end
sigmaNonWater = sigmaNonWater/nonWater;
 
sw = sigmaWater*pWater+sigmaNonWater*pNonWater;
 
globalMean = pWater*waterMean + pNonWater*nonWaterMean;
 
sb = pWater*(waterMean-globalMean)*(waterMean-globalMean)'+pNonWater*(nonWaterMean-globalMean)*(nonWaterMean-globalMean)';
 
sm = sw+sb;
j1 = trace(sm)/trace(sw);

