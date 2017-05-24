function importVideo( name, ID )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

pic = {};
workingDir = pwd;
folder = ['Data/',num2str(ID),'/images/origin'];

shuttleVideo = VideoReader(name);

ii = 1;
while hasFrame(shuttleVideo)
   img = readFrame(shuttleVideo);
   pic{end+1,1} = img;
   filename = [sprintf('%d',ii) '.jpg'];
   fullname = fullfile(workingDir,folder,filename);
   imwrite(img,fullname)
   ii = ii+1;
end

file = [folder,'/img_seq.mat'];
save(file,'pic')

end

