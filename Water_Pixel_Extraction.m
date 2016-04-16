% Matlab script for water pixel extraction:


clear;
close all;
colorspace = input('Whater colorspace would you like to choose?\nPress r for RGB and h for HSV:   ','s');
if(colorspace=='r')
    disp(['You have chosen the RGB colorspace']);
elseif(colorspace=='h')
    disp(['You ahve chosen the HSV colorspace']);
else
    disp(['Your input is invalid']);
    return;
end
pathOfImage = '.\Project1\Water';
pathOfMask = '.\Project1\WaterMask';
listOfImage = dir('.\Project1\Water\*.jpg');
numberOfImage = size(listOfImage,1);
numberOfTrainingExample = ceil(numberOfImage/3);
waterDistribution = zeros(256,256,256);
nonWaterDistribution = zeros(256,256,256);
numberOfWaterPixel = 0;
numberOfNonWaterPixel = 0;
for m = 1:numberOfTrainingExample
    nameOfImage = listOfImage(m).name;
    pic = imread([pathOfImage,'\',nameOfImage]);
    pichsv = rgb2hsv(pic);
    mask = imread([pathOfMask,'\',nameOfImage]);
    mask = mask(:,:,1);
    for n = 1:size(pic,1)
        for l = 1:size(pic,2)
            index1 = pic(n,l,1)+1;
            index2 = pic(n,l,2)+1;
            index3 = pic(n,l,3)+1;
            
            index4 = ceil(pichsv(n,l,1)*256);if(index4==0)index4=1;end
            index5 = ceil(pichsv(n,l,2)*256);if(index5==0)index5=1;end
            index6 = ceil(pichsv(n,l,3)*256);if(index6==0)index6=1;end
            
            if(colorspace=='r')
                idx1 = index1; idx2 = index2; idx3 = index3; 
            else
                idx1 = index4; idx2 = index5; idx3 = index6; 
            end
            maskValue = mask(n,l);
            if(maskValue == 255)
                numberOfNonWaterPixel = numberOfNonWaterPixel + 1;
                nonWaterDistribution(idx1,idx2,idx3) = nonWaterDistribution(idx1,idx2,idx3) + 1;
            else
                numberOfWaterPixel = numberOfWaterPixel + 1;
                waterDistribution(idx1,idx2,idx3) = waterDistribution(idx1,idx2,idx3) + 1;
            end
        end
    end
end 
pWater = (numberOfWaterPixel)/(numberOfWaterPixel+numberOfNonWaterPixel);
pNonWater = (numberOfNonWaterPixel)/(numberOfWaterPixel+numberOfNonWaterPixel);
 
numberOfWaterPixel = 0;
nonWaterAsWater = 0;
waterAsNonWater = 0;
numberOfNonWaterPixel = 0;
for m = (numberOfTrainingExample+1):numberOfImage
    nameOfImage = listOfImage(m).name;
    pic = imread([pathOfImage,'\',nameOfImage]);
    pichsv = rgb2hsv(pic);
    mask = imread([pathOfMask,'\',nameOfImage]);
    for n = 1:size(pic,1)
        for l = 1:size(pic,2)
            index1 = pic(n,l,1)+1;
            index2 = pic(n,l,2)+1;
            index3 = pic(n,l,3)+1;
            
            index4 = ceil(pichsv(n,l,1)*256);if(index4==0)index4=1;end
            index5 = ceil(pichsv(n,l,2)*256);if(index5==0)index5=1;end
            index6 = ceil(pichsv(n,l,3)*256);if(index6==0)index6=1;end
            if(colorspace=='r')
                idx1 = index1; idx2 = index2; idx3 = index3; 
            else
                idx1 = index4; idx2 = index5; idx3 = index6; 
            end
            probabilityNonWater = nonWaterDistribution(idx1,idx2,idx3);
            probabilityWater = waterDistribution(idx1,idx2,idx3);
            maskValue = mask(n,l);
            if(maskValue==255)
                numberOfNonWaterPixel=numberOfNonWaterPixel+1;
                if(pNonWater*probabilityNonWater < pWater*probabilityWater)
                    nonWaterAsWater = nonWaterAsWater +1;
                    pic(n,l,2) = 0; pic(n,l,3) = 0;
                end
            else
                numberOfWaterPixel =numberOfWaterPixel+1;
                if(pNonWater*probabilityNonWater < pWater*probabilityWater)
                    pic(n,l,2) = 0; pic(n,l,3) = 0;
                else
                    waterAsNonWater =  waterAsNonWater + 1;
                end
            end
        end
    end
    figure
    imshow(pic);
end
disp(['Number of water pixels is: ',num2str(numberOfWaterPixel)]);
disp(['Number of non-water pixels is: ',num2str(numberOfNonWaterPixel)]);
disp(['Number of miss-classification for water pixels is: ',num2str(waterAsNonWater)]);
disp(['Number of miss-classification for non-water pixels is: ',num2str(nonWaterAsWater)]);
disp(['error rate for non-water pixel: ',num2str(nonWaterAsWater/numberOfNonWaterPixel)]);
disp(['error rate for water pixel: ',num2str(waterAsNonWater/numberOfWaterPixel)]);
disp(['global error rate: ',num2str((waterAsNonWater+nonWaterAsWater)/(numberOfWaterPixel+numberOfNonWaterPixel))]);

