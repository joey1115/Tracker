%% Initialization
clear; close; clc;
global ID;
ID = 3;
workingDir = pwd;
folder = ['\Data\',num2str(ID)];
mkdir(workingDir,folder)
folder = ['\Data\',num2str(ID),'\images'];
mkdir(workingDir,folder)
folder = ['\Data\',num2str(ID),'\images\edited'];
mkdir(workingDir,folder)
folder = ['\Data\',num2str(ID),'\images\origin'];
mkdir(workingDir,folder)
folder = ['\Data\',num2str(ID),'\images\edited\mark'];
mkdir(workingDir,folder)
folder = ['\Data\',num2str(ID),'\images\edited\track'];
mkdir(workingDir,folder)
folder = ['\Data\',num2str(ID),'\images\edited\five_track'];
mkdir(workingDir,folder)
%% Edit image sequence
clear; close; clc;
ID = 3;
name = 'Source/Ram spermatozoa - Sample 3 Field 2.mp4';
importVideo( name, ID );
origin = [pwd,'/Data/',num2str(ID),'/images/origin/img_seq.mat'];
data = load(origin,'pic');
origin_img = data.pic;
L = 400:499;
range = [1,100;1,100] + repmat([180;100],1,2);
edit_img( ID, origin_img, L, range );
%% Image processing
clear; clc; close;
ID = 3;
% Original image
valid = false;
V = {};
Center_edited = {};
last_area = {};
index = 1;
stop = false;
Greater = true;
centroid_final = {};
path = [pwd,'\Data\',num2str(ID),'\images\edited\'];
% User input first threshold
gui2();
waitfor(gui2());
threshold = str2double(threshold);

% Process into the next step when user make sure the threshold value
while (~stop)
    fileName = strcat(num2str(index), '.jpg');
    A = imread(fullfile(path,fileName));
    gray_image = rgb2gray(A);
    medfilt_image = medfilt2(gray_image,[3,3]);
    intentsity_image = uint8(medfilt_image);
    Im2 = (intentsity_image < threshold);
    Im3 = double(Im2);
    
    % Objective_Area
    num = 1;
    for i = 1:size(Im3,1)
        for j = 1:size(Im3,2)
            if Im3(i,j) == 1
                num = num + 1;
                Im3 = region(Im3, i, j, num);
            end
        end
    end
    
    Area_index = (2:num)';
    Area_zero = zeros(length(Area_index),1);
    Area = [Area_index, Area_zero];
    for i = 1:size(Im3,1)
        for j = 1:size(Im3,2)
            if Im3(i, j) > 0
                Area(Im3(i,j)-1, 2) = Area(Im3(i,j)-1, 2) + 1;
            end
        end
    end
    
    
    % All objectives' positions
    objective_position = [];
    for k = 1:size(Area_index,1)
        for i = 1:size(Im3,1)
            for j = 1:size(Im3,2)
                if Im3(i,j) == Area_index(k)
                    temp = [i,j]';
                    objective_position = [objective_position temp];
                end
            end
        end
    end
    
    % Centroid
    objective_centroid = [];
    for i = 1:size(Area_index,1)
        objective_centroid = [objective_centroid centroid(Im3,i+1)'];
    end
    All_objective_centroid = [];
    All_objective_centroid(index:index+1,:) = objective_centroid;
    Center_edited{index,1} = objective_centroid';
    
    % objective_eccentricity
    objective_boundries = boundries(Im3);
    boundries_each_index = [];
    objective_eccentricity = [];
    for k =1:size(Area_index)
        boundries_each_index = [];
        for i = 1:size(objective_boundries,1)
            for j = 1:size(objective_boundries,2)
                if objective_boundries(i,j) == k+1
                    boundries_each_index =[boundries_each_index [i,j]'];
                end
            end
        end
        objective_eccentricity = [objective_eccentricity eccentricity(...
            boundries_each_index,objective_centroid(:,k))];
    end
    V{index,1} = Area;
    V{index,2} = objective_centroid;
    V{index,3} = objective_eccentricity;
    objective_centroid_matrix = double(objective_centroid);
    objective_centroid_matrix = [objective_centroid_matrix(2,:);...
        objective_centroid_matrix(1,:)];
    centroid_final{index,1} = objective_centroid_matrix';
    % characterstic of sperms
    if index > 1
        last_area = area_sum(V{index-1,1}(:,2));
        current_area = area_sum(V{index,1}(:,2));
        last_num = size(V{index-1,1},1);
        current_num = size(V{index,1},1);
        if abs((current_area - last_area)/last_area) > 1
            if (current_area - last_area) > 0 && Greater
                Greater = true;
                threshold = threshold - 1;
            elseif (current_area - last_area) < 0
                Greater = false;
                threshold = threshold + 1;
            else
                disp(strcat('Deviation Problem with Image',...
                num2str(index)));
                Greater = true;
                index = index + 1;
            end
        elseif (abs(current_num - last_num)) > 3
            disp(strcat('Number problem with Image',num2str(index)));
            Greater = true;
            index = index + 1;
        else
            Greater = true;
            index = index + 1;
        end
    else
        index = index + 1;
    end
    
    % logic to next while loop for image processing
    if (index > 100)
        stop = true;
    end
end
save(fullfile(pwd,'Data',num2str(ID),'Centriod'),'centroid_final');
%% Mark sperms
clear; clc; close;
ID = 3;
workingDir = [pwd, '\Data\', num2str(ID),...
    '\images\edited'];
outputVideo = VideoWriter(fullfile(workingDir,'mark','shuttle_out.avi'));
outputVideo.FrameRate = 1;
open(outputVideo)
for i = 1:100
    imageNames{i,1} = [num2str(i),'.jpg'];
end

for ii = 1:length(imageNames)
    img = imread(fullfile(workingDir,imageNames{ii}));
    x = getData(ID,ii);
    if ~isempty(x)
        img = insertMarker(img,x,'x','color','red','size',3);
    end
    imwrite(img,fullfile(workingDir,'mark',imageNames{ii}))
    writeVideo(outputVideo,img)
end
close(outputVideo)
%% Tracking
clear ;close ; clc;
ID = 3;
f = 24;
lim = [2,8];
err = [-1,8];
res = [100,100];
alpha = 0.8;
cof = [alpha,2*(2-alpha)-4*sqrt(1-alpha)];
file = 1:100;
skip = 2;

track = spermTrack( ID, file, res, f, lim, err, cof, skip );
track = trackFill(track);
save(['Data/',num2str(ID),'/track.mat'],'track')
%% Display tracks
clear; close; clc;
ID = 3;
load([pwd,'/Data/',num2str(ID),'/data.mat'])
load([pwd,'Data/',num2str(ID),'/track.mat'])
workingDir = [pwd,'\Data\',num2str(ID),...
    '\images\edited\track'];
outputVideo = VideoWriter(fullfile(workingDir,'shuttle_out.avi'));
outputVideo.FrameRate = 1;
open(outputVideo)
spot = [];
lin = [];
for i = 1:size(data,1)
    disp(i)
    for j = 1:size(track,1)
        frame = track{j,6};
        idx = find(frame == i);
        img = imread(['Data/',num2str(ID),'/images/edited/',...
            num2str(i),'.jpg']);
        if ~isempty(spot)
            img = insertMarker(img,spot,'x','color','red','size',3);
        end
        for k = 1:size(lin,1)
            img = insertShape(img,'Line',lin(k,:),...
                'LineWidth',1,'Color','blue');
        end
        if ~isempty(idx)
            if idx == 1
                spot = [spot;[track{j,1}(1,1),track{j,2}(1,1)]];
                img = insertMarker(img,...
                    [track{j,1}(1,1),track{j,2}(1,1)],...
                    'x','color','red','size',3);
            else
                x1 = track{j,1}(1,idx-1);
                x2 = track{j,1}(1,idx);
                y1 = track{j,2}(1,idx-1);
                y2 = track{j,2}(1,idx);
                lin = [lin;x1,y1,x2,y2];
                img = insertShape(img,'Line',[x1,y1,x2,y2],...
                    'LineWidth',1,'Color','blue');
            end
            imwrite(img,...
                ['Data/',num2str(ID),'/images/edited/track/',...
                num2str(i),'.jpg']);
        end
    end
    writeVideo(outputVideo,img)
end
close(outputVideo)
%% Five-point track
clear; close; clc;
ID = 3;
len = 10;
load([pwd,'/Data/',num2str(ID),'/track.mat'])
load([pwd,'/Data/',num2str(ID),'/data.mat'])
workingDir = [pwd,'\Data\',num2str(ID),...
    '\images\edited\five_track'];
outputVideo = VideoWriter(fullfile(workingDir,'shuttle_out.avi'));
outputVideo.FrameRate = 1;
open(outputVideo)
for i = 1:size(data,1)
    disp(i)
    img = imread(['Data/',num2str(ID),'/images/edited/',num2str(i),...
        '.jpg']);
    for j = 1:size(track,1)
        idx = find(track{j,6} == i);
        if ~isempty(idx)
            pos = [track{j,1}(idx),track{j,2}(idx)];
            img = insertMarker(img,pos,'x','color','red','size',3);
            for k = (idx - len + 2):idx
                if k > 1
                    x1 = track{j,1}(k-1);
                    y1 = track{j,2}(k-1);
                    x2 = track{j,1}(k);
                    y2 = track{j,2}(k);
                    img = insertShape(img,'Line',[x1,y1,x2,y2],...
                        'LineWidth',1,'Color','blue');
                end
            end
        end
    end
    imwrite(img,['Data/',num2str(ID),'/images/edited/five_track/',...
        num2str(i),'.jpg']);
    writeVideo(outputVideo,img)
end
close(outputVideo)
%% Number of marked sperms
clear; close; clc;
ID = 3;
load([pwd,'/Data/',num2str(ID),'/track.mat'])
load([pwd,'/Data/',num2str(ID),'/data.mat'])
num_mark = zeros(1,size(data,1));
for i = 1:size(data,1)
    num_mark(i) = size(data{i,1},1);
end
plot(1:size(data,1),num_mark)
title('Number of marked sperms')
xlabel('Frame')
ylabel('Number')
save(fullfile(pwd,'Data',num2str(ID),'number_mark.mat'),'num_mark');
%% Number of moving sperms
clear; close; clc;
ID = 3;
load([pwd,'/Data/',num2str(ID),'/track.mat'])
load([pwd,'/Data/',num2str(ID),'/data.mat'])
num_move = zeros(1,size(data,1));
for i = 1:size(data,1)
    for j = 1:size(track,1)
        avg_speed = sum(sqrt(track{j,3}.^2+track{j,4}.^2))/...
            length(track{j,1});
        if any(track{j,6}==i) && avg_speed > 0
            num_move(i) = num_move(i) + 1;
        end
    end
end
plot(1:size(data,1),num_move)
title('Number of moving sperms')
xlabel('Frame')
ylabel('Number')
save(fullfile(pwd,'Data',num2str(ID),'number_move.mat'),'num_move');
%% Number of sperms have no movement
clear; close; clc;
ID = 3;
load([pwd,'/Data/',num2str(ID),'/track.mat'])
load([pwd,'/Data/',num2str(ID),'/data.mat'])
load([pwd,'/Data/',num2str(ID),'/number_mark.mat'])
load([pwd,'/Data/',num2str(ID),'/number_move.mat'])
num_no = num_mark - num_move;
num_no(num_no<0) = 0;
plot(1:size(data,1),num_no)
title('Number of sperms have no movement')
xlabel('Frame')
ylabel('Number')
save(fullfile(pwd,'Data',num2str(ID),'number_no_move.mat'),'num_no');
%% Number of high motility sperms
clear; close; clc;
ID = 3;
load([pwd,'/Data/',num2str(ID),'/track.mat'])
load([pwd,'/Data/',num2str(ID),'/data.mat'])
speed_lim = [20,60,100];
num_speed = zeros(size(data,1),size(speed_lim,2));
for i = 1:size(data,1)
    for j = 1:size(track,1)
        if any(track{j,6}==i)
            idx = find(track{j,6}==i);
            speed = sqrt(track{j,3}(idx)^2 + track{j,4}(idx)^2);
            num_speed(i,:) = num_speed(i,:) + (speed_lim < speed);
        end
    end
end
figure;
hold on
for i = 1:size(speed_lim,2)
    plot(1:size(data,1),num_speed(:,i))
end
%ylim([0,10])
xlabel('frame')
ylabel('number')
legend('Speed > 20', 'Speed > 60', 'Speed > 100')
title('Number of high motility sperms')
%% Number of sperms with linear movement
clear; close; clc;
ID = 3;
load([pwd,'/Data/',num2str(ID),'/track.mat'])
load([pwd,'/Data/',num2str(ID),'/data.mat'])
num_linear = 0;
for i = 1:size(track,1)
    num_linear = num_linear + (length(track{i,1}) > 20);
end
fprintf('Number of sperms with linear movement in data set No.%d is %d\n'...
    , ID, num_linear)