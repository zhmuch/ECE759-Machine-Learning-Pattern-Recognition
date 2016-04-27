clear;
close all
numberOfClusters = 2;
 
pathOfWaterImage = '.\Water';
pathOfMask = '.\WaterMask';
 
listOfWaterImage = dir([pathOfWaterImage,'\*.jpg']);
numberOfWaterImage = size(listOfWaterImage,1);
halfWindow = 1;
winSize = halfWindow*2+1;
numberOfFeatures = winSize*winSize*3;
 
idx = 1;
for m = 1:numberOfWaterImage
    nameOfImage = listOfWaterImage(m).name;
    pictemp = imread([pathOfWaterImage,'\',nameOfImage]);
    pic = double(pictemp);
    mask = imread([pathOfMask,'\',nameOfImage]);
    mask = double(mask(:,:,1));
    height = size(pic,1);
    width = size(pic,2);
    vector = zeros(numberOfFeatures,height*width);
    picMargin = zeros(height+halfWindow*2,width+halfWindow*2,3);
    picMargin((halfWindow+1):(end-halfWindow),(halfWindow+1):(end-halfWindow),:) = pic;
    index = 1;
    for p = 1:1:height
        for q = 1:1:width
            win = picMargin(p:(p+2*halfWindow),q:(q+2*halfWindow),:);
            channel1 = win(:,:,1);
            channel2 = win(:,:,2);
            channel3 = win(:,:,3);
            vector(:,index)=[channel1(:);channel2(:);channel3(:)];
            index = index +1;
        end
    end
    numberOfVectors = height*width;
    group = zeros(1,numberOfVectors);
    newCenters = zeros(numberOfFeatures,numberOfClusters);
    centers = vector(:,randperm(numberOfVectors,numberOfClusters));
    disp(['start initialization']);
    for m = 1:numberOfVectors
        v = vector(:,m);
        for n = 1:numberOfClusters
            distance(n) = norm(v - centers(:,n));
        end
        temp = find(distance==min(distance));
        group(m)=temp(1);
    end
    change = 0;
    for m = 1:numberOfClusters
        wow = vector(:,find(group==m));
        newCenters(:,m) = mean(wow')';
        change = max(change,norm(centers(:,m)-newCenters(:,m))/norm(centers(:,m)));
    end
    disp(['Initialization finished']);
    index = 1;
    while(change>1e-5)
        disp(['change is: ',num2str(change)]);
        disp(['start iteration ',num2str(index)]);
        centers = newCenters;
        for m = 1:numberOfVectors
            v = vector(:,m);
            for n = 1:numberOfClusters
                distance(n) = norm(v - centers(:,n));
            end
            temp = find(distance==min(distance));
            group(m)=temp(1);
        end
        change = 0;
        for m = 1:numberOfClusters
            wow = vector(:,find(group==m));
            newCenters(:,m) = mean(wow')';
            change = max(change,norm(centers(:,m)-newCenters(:,m))/norm(centers(:,m)));
        end
        disp(['iteration ',num2str(index),' finished']);
        index = index + 1;
    end
    groups = zeros(height,width);
    for m=1:height
        for n =1:width
            groups(m,n) = group((m-1)*width+n);
        end
    end
    figure
    imshow(pictemp)
    mark1 = zeros(height,width);
    mark2 = zeros(height,width);
    for m = 1:height
        for n = 1:width
            if(mask(m,n)==255)
                mark2(m,n) = 1;
            else
                mark2(m,n) = -1;
            end
            if(groups(m,n)==1)
                mark1(m,n) = 1;
                pictemp(m,n,2)=0;
                pictemp(m,n,3)=0;
            elseif(groups(m,n)==2)
                mark1(m,n) = -1;
                pictemp(m,n,1)=0;
                pictemp(m,n,2)=0;
            end
        end
    end
    figure
    imshow(pictemp);
    CS(idx) = abs(sum(sum(mark1.*mark2)))/(height*width);
    idx = idx + 1;
end
