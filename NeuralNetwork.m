clear;
close all;

pathOfWaterImage = '.\Water';
pathOfMask = '.\WaterMask';

listOfWaterImage = dir([pathOfWaterImage,'\*.jpg']);
numberOfWaterImage = size(listOfWaterImage,1);
numberOfWaterTrainingExample = ceil(numberOfWaterImage/5);
halfWindow = 1;
winSize = halfWindow*2+1;
numberOfFeatures = winSize*winSize*3;

col = 0;
for m = 1:numberOfWaterTrainingExample
    nameOfImage = listOfWaterImage(m).name;
    pic = imread([pathOfWaterImage,'\',nameOfImage]);
    height = length(1:(2*halfWindow+1):size(pic,1));
    width = length(1:(2*halfWindow+1):size(pic,2));
    col = col + height*width;
end

vector = zeros(numberOfFeatures,col);
y = zeros(1,col);

index = 1;
for m = 1:numberOfWaterTrainingExample
    nameOfImage = listOfWaterImage(m).name;
    %pictemp = double(imread([pathOfWaterImage,'\',nameOfImage]));
    pictemp = imread([pathOfWaterImage,'\',nameOfImage]);
    pic = double(pictemp);
    mask = imread([pathOfMask,'\',nameOfImage]);
    mask = double(mask(:,:,1));
    height = size(pic,1);
    width = size(pic,2);
    picMargin = zeros(height+halfWindow*2,width+halfWindow*2,3);
    picMargin((halfWindow+1):(end-halfWindow),(halfWindow+1):(end-halfWindow),:) = pic;
    for p = 1:(2*halfWindow+1):height
        for q = 1:(2*halfWindow+1):width
            win = picMargin(p:(p+2*halfWindow),q:(q+2*halfWindow),:);
            if(mask(p,q)==255)
                y(index)=0;
            else
                y(index)=1;
            end
            channel1 = win(:,:,1);
            channel2 = win(:,:,2);
            channel3 = win(:,:,3);
            vector(:,index)=[channel1(:);channel2(:);channel3(:)];
            index = index +1;
        end
    end
    disp([num2str(m),' examples loaded']);
end

disp(['Initialization finished']);

numberOfInput = numberOfFeatures;
numberOfNodes = numberOfFeatures*3;

a = 1e0;
mu = 1*1e-1;

rand('seed',0);
w1 = rand(numberOfNodes,numberOfInput+1)*2-1;
w2 = rand(1,numberOfNodes+1)*2-1;
load('NN.mat');
numberOfSamples = length(y);
v1 = w1*[ones(1,size(vector,2));vector];
y1 = 1./(1+exp(-a*v1));
v2 = w2*[ones(1,size(y1,2));y1];
y2 = 1./(1+exp(-a*v2));
cost = sum(sum((y-y2).^2));

ytemp = y2;
ytemp(y2>0.5)=1;
ytemp(y2<=0.5)=0;
err = abs(y-ytemp);
correctRate = length(find(err==0))/length(err);
disp(['correct rate is: ',num2str(correctRate)]);

index = 1;
dec = 0;
while(correctRate<=0.95)
    previousCost = cost;
    disp(['iteration: ',num2str(index)]);
    index = index + 1;
    w2tr = w2(:,2:end)';
    w1tr = w1(:,2:end)';
    e2 = y2-y;
    delta2 = a*e2.*y2.*(1-y2);
    e1 = w2tr*delta2;
    delta1 = a*e1.*y1.*(1-y1);
    for m = 1:size(w2,1)
        helpMatrix = repmat(delta2(m,:),size(y1,1)+1,1);
        deltaW2(m,:) = -mu*sum(transpose(helpMatrix.*[ones(1,size(y1,2));y1]))/numberOfSamples;
    end
    %disp(['change of w2 is :',num2str(max(max(abs(deltaW2/w2))))]);
    w2 = w2 + deltaW2;
    for m = 1:size(w1,1)
        helpMatrix = repmat(delta1(m,:),size(vector,1)+1,1);
        deltaW1(m,:) = -mu*sum(transpose(helpMatrix.*[ones(1,size(vector,2));vector]))/numberOfSamples;
    end
    %disp(['change of w1 is :',num2str(max(max(abs(deltaW1/w1))))]);
    w1 = w1 + deltaW1;
    v1 = w1*[ones(1,size(vector,2));vector];
    y1 = 1./(1+exp(-a*v1));
    v2 = w2*[ones(1,size(y1,2));y1];
    y2 = 1./(1+exp(-a*v2));
    ytemp = y2;
    ytemp(y2>0.5)=1;
    ytemp(y2<=0.5)=0;
    err = abs(y-ytemp);
    correctRate = length(find(err==0))/length(err);
    disp(['correct rate is: ',num2str(correctRate)]);
    cost = sum(sum((y-y2).^2));
    if(cost>previousCost)
        dec = 0;
        mu = mu/2;
        disp(['learning rate is divided by 2']);
    else
        dec = dec + 1;
        if(dec == 100)
            dec = 0;
            %mu = mu*2;
            %disp(['learning rate is multiplied by 2']);
        end
    end
    disp(['cost function is: ',num2str(cost)]);
end

save('NN.mat','w1','w2','mu');

waterPixel = 0;
nonWaterPixel = 0;
waterAsNonWater = 0;
nonWaterAsWater = 0;
for m = (1+numberOfWaterTrainingExample):numberOfWaterImage
    nameOfImage = listOfWaterImage(m).name;
    pic = imread([pathOfWaterImage,'\',nameOfImage]);
    mask = imread([pathOfMask,'\',nameOfImage]);
    mask = double(mask(:,:,1));
    height = size(pic,1);
    width = size(pic,2);
    picMargin = zeros(height+halfWindow*2,width+halfWindow*2,3);
    picMargin((halfWindow+1):(end-halfWindow),(halfWindow+1):(end-halfWindow),:) = double(pic);
    for p = 1:height
        for q = 1:width
            win = picMargin(p:(p+2*halfWindow),q:(q+2*halfWindow),:);
            if(mask(p,q)==255)
                nonWaterPixel = nonWaterPixel + 1;
            else
                waterPixel = waterPixel + 1;
            end
            channel1 = win(:,:,1);
            channel2 = win(:,:,2);
            channel3 = win(:,:,3);
            vector=[channel1(:);channel2(:);channel3(:)];
            v1 = w1*[ones(1,size(vector,2));vector];
            y1 = 1./(1+exp(-a*v1));
            v2 = w2*[ones(1,size(y1,2));y1];
            y2 = 1./(1+exp(-a*v2));
            if(y2>0.5)
                pic(p,q,2)=0;pic(p,q,3)=0;
                if(mask(p,q)==255)nonWaterAsWater = nonWaterAsWater+1;end
            else
                if(mask(p,q)~=255)waterAsNonWater = waterAsNonWater+1;end
            end
        end
    end
    figure
    imshow(pic);
end

disp(['error rate for water pixel: ',num2str(waterAsNonWater/waterPixel)]);
disp(['error rate for non water pixel: ',num2str(nonWaterAsWater/nonWaterPixel)]);
disp(['over all error rate: ',num2str((nonWaterAsWater+waterAsNonWater)/(nonWaterPixel+waterPixel))]);
