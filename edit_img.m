function edit_img( ID, img, L, range )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


workingDir = pwd;
folder = ['Data/',num2str(ID),'/images/edited'];

img_seq = cell(length(L),1);
count = 1;
for i = L
    image = img{i,1};
    image = image(range(1,1):range(1,2),range(2,1):range(2,2),:);
    filename = [sprintf('%d',count) '.jpg'];
    fullname = fullfile(workingDir,folder,filename);
    imwrite(image,fullname)
    img_seq{count,1} = image;
    count = count + 1;
end

file = [folder,'/img_seq.mat'];
save(file,'img_seq')

end

