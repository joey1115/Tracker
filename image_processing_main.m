%% Image process
clear; clc; close;
ID = 2;
% Original image 
valid = false;
V = {};
Center_edited = {};
last_area = {};
index = 1;
stop = false;
Greater = true;
path = [pwd,'\Data\',num2str(ID),'\images\edited\'];
% User input first threshold
while (~valid)
prompt = 'What is the threshold value?\n';
UserInput = input(prompt,'s');
threshold_UserInput = str2double(UserInput);
valid = ~isnan(threshold_UserInput);

if (~valid)
    disp('The value you entered is not valid, please dont be a jerk \n');
    continue;
end

% load the image information
A = imread(fullfile(path,'1.jpg'));
gray_image = rgb2gray(A);
medfilt_image = medfilt2(gray_image,[3,3]);
intentsity_image = uint8(medfilt_image);
Im2 = (intentsity_image < threshold_UserInput);
subplot(1,2,1);
imshow(A);
subplot(1,2,2);
imshow(Im2);

correct_input = false; 

while (~correct_input)
prompt1 = 'Are you satisfied with this threshold?\n';
UserInput1 = input(prompt1,'s');
if (strcmp(UserInput1, 'yes'))
    threshold = threshold_UserInput;
    correct_input = true; 
    valid = true;
    figure1 = figure;
elseif (strcmp(UserInput1, 'no'))
     correct_input = true; 
     valid = false;
end
end

end


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
centroid_final = {};
objective_centroid_matrix = double(objective_centroid);
objective_centroid_matrix = [objective_centroid_matrix(2,:); objective_centroid_matrix(1,:)];
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
           disp(strcat('Deviation Problem with Image',num2str(index)));
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