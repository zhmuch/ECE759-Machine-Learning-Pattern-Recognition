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
    height = length(1:(2*halfWindow+1)*10:size(pic,1));
    width = length(1:(2*halfWindow+1)*10:size(pic,2));
    col = col + height*width;
end
 
vector = zeros(numberOfFeatures,col);
y = zeros(1,col);
 
index = 1;
for m = 1:numberOfWaterTrainingExample
    nameOfImage = listOfWaterImage(m).name;
    pictemp = imread([pathOfWaterImage,'\',nameOfImage]);
    pic = double(pictemp);
    mask = imread([pathOfMask,'\',nameOfImage]);
    mask = double(mask(:,:,1));
    height = size(pic,1);
    width = size(pic,2);
    picMargin = zeros(height+halfWindow*2,width+halfWindow*2,3);
    picMargin((halfWindow+1):(end-halfWindow),(halfWindow+1):(end-halfWindow),:) = pic;
    for p = 1:(2*halfWindow+1)*10:height
        for q = 1:(2*halfWindow+1)*10:width
            win = picMargin(p:(p+2*halfWindow),q:(q+2*halfWindow),:);
            if(mask(p,q)==255)
                y(index)=-1;
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
 
numberOfSamples = length(y);
 
sigmaSquare = 0.5e4;
 
ker = zeros(numberOfSamples);
yMulti = zeros(numberOfSamples);
for m = 1:numberOfSamples
    for n = 1:numberOfSamples
        ker(m,n) = exp(-norm(vector(:,m)-vector(:,n))^2/sigmaSquare);
        yMulti(m,n) = y(m)*y(n);
    end
end
 
C = 100;
lambdaInit = rand(numberOfSamples,1)*C;
fun = @(lambda) 0.5*sum(sum(  repmat(lambda,1,size(lambda,1)).*repmat(lambda,1,size(lambda,1))'.*yMulti.*ker   ))-sum(lambda);
%lambdaResult = fmincon(fun,lambdaInit,[],[],y,0,zeros(numberOfSamples,1),C*ones(numberOfSamples,1));
load('SVM.mat');
disp(['lambda has been calculated']);
load('NN.mat');
w0 = w2(1);
correct = 0;
index = 1;
for m = 1:numberOfSamples
    dupli = repmat(vector(:,m),1,numberOfSamples);
    temp = (dupli-vector).^2;
    temp = sum(temp);
    temp = exp(-temp/sigmaSquare);
    gx(index) = (temp.*y)*lambdaResult+w0;
    if(gx(index)*y(m)>0)correct=correct+1;end
    index = index + 1;
end
disp(['Correct rate on training example is: ',num2str(correct/numberOfSamples)]);
 
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
    mark = zeros(height,width);
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
            v=[channel1(:);channel2(:);channel3(:)];
            dupli = repmat(v,1,numberOfSamples);
            temp = (dupli-vector).^2;
            temp = sum(temp);
            temp = exp(-temp/sigmaSquare);
            y2 = (temp.*y)*lambdaResult+w0;
            if(y2>0)
                mark(p,q) = 1;
                if(mask(p,q)==255)nonWaterAsWater = nonWaterAsWater+1;end
            else
                if(mask(p,q)~=255)waterAsNonWater = waterAsNonWater+1;end
            end
        end
    end
    for p = 1:height
        for q = 1:width
            if(p==1 || p==height || q==1 || q==width)
                if(mark(p,q)==1)pic(p,q,1)=0;pic(p,q,2)=0;pic(p,q,3)=0;end
            else
                if(mark(p,q)==1)
                    if(mark(p-1,q)==1&&mark(p+1,q)==1&&mark(p,q-1)==1&&mark(p,q+1)==1)pic(p,q,2)=0;pic(p,q,3)=0;
                    elseif(~(mark(p-1,q)==0&&mark(p+1,q)==0&&mark(p,q-1)==0&&mark(p,q+1)==0))pic(p,q,1)=0;pic(p,q,2)=0;pic(p,q,3)=0;end
                end
            end
        end
    end
    figure
    imshow(pic);
end
disp(['error rate for water pixel: ',num2str(waterAsNonWater/waterPixel)]);
disp(['error rate for non water pixel: ',num2str(nonWaterAsWater/nonWaterPixel)]);
disp(['over all error rate: ',num2str((nonWaterAsWater+waterAsNonWater)/(nonWaterPixel+waterPixel))]);
