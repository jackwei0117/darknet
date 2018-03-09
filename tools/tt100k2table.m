clc;
close all;

% fname = 'annotations.json'; 
% data = loadjson(fname,'ShowProgress',1);
load('matlab_format.mat');
path={};




imgs=struct2cell(data.imgs);



for i=1:length(imgs)    
    
    path{i,1}=strcat('data/',imgs{i}.path);
    objects=imgs{i}.objects;
    coor_set=[];
    if length(objects)~=0        
        for j=1:length(objects)
            xmin=objects{j}.bbox.xmin;
            ymin=objects{j}.bbox.ymin;
            xmax=objects{j}.bbox.xmax;
            ymax=objects{j}.bbox.ymax;            
            coor=[xmin,ymin,xmax-xmin,ymax-ymin];
            coor_set(j,:)=coor;            
        end        
    end
    
    signs_coor{i,1}=coor_set;
    
    
end

t=table(path,signs_coor);
save('tt100k_table.mat', 't');
%Index = find(contains(path,'test/32773.jpg'));

