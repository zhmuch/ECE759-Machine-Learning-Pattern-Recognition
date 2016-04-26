%Principal Component Analysis

clear;
close all;
 
pathOfWaterImage = '.\Water';
pathOfMask = '.\WaterMask';
 
listOfWaterImage = dir([pathOfWaterImage,'\*.jpg']);
numberOfWaterImage = size(listOfWaterImage,1);
halfWindow = 1;
winSize = halfWindow*2+1;
numberOfFeatures = winSize*winSize*3;
 
numberOfPixel = 0;
for m = 1:numberOfWaterImage
    nameOfImage = listOfWaterImage(m).name;
    pictemp = imread([pathOfWaterImage,'\',nameOfImage]);
    pic = double(pictemp);
    height = size(pic,1);
    width = size(pic,2);
    numberOfPixel = numberOfPixel + height*width;
end
 
vector = zeros(27,numberOfPixel);
index = 0;
for m = 1:numberOfWaterImage
    nameOfImage = listOfWaterImage(m).name;
    pictemp = imread([pathOfWaterImage,'\',nameOfImage]);
    pic = double(pictemp);
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
            index = index + 1;
            vector(:,index) = v;
        end
    end
    if(mod(m,10)==0)disp([num2str(numberOfWaterImage-m),' images left']);end
end
 
vectorMean = mean(vector')';
vectorMeanMatrix = repmat(vectorMean,1,numberOfPixel);
vectorProcessed = vector - vectorMeanMatrix;
sigma = zeros(27,27);
for m = 1:numberOfPixel
    v = vectorProcessed(:,m);
    sigma = sigma+v*v';
end
sigma = sigma/numberOfPixel;
 
[U,S,V] = svd(sigma);
for m = 1:27
    subSigma = S(1:m,1:m);
    remainingVariance = trace(subSigma)/trace(S);
    disp(['Decreasing the vector to ',num2str(m),' dimensions can retain ',num2str(remainingVariance*100),' percent of the variance']);
end
