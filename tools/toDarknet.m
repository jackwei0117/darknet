clc;
close all;
clear all;


%red_category=["p1","p10","p11","p12","p13","p14","p15","p16","p17","p18","p19","p2","p20","p21","p22","p23","p24","p25","p26","p27","p28","p3","p4","p5","p6","p7","p8","p9","pa10","pa12","pa13","pa14","pa8","pb","pc","pg","ph15","ph2","ph21","ph22","ph24","ph25","ph28","ph29","ph3","ph32","ph35","ph38","ph4","ph42","ph43","ph45","ph48","ph5","ph53","ph55","pl10","pl100","pl110","pl120","pl15","pl20","pl25","pl30","pl35","pl40","pl5","pl50","pl60","pl65","pl70","pl80","pl90","pm10","pm13","pm15","pm2","pm20","pm25","pm30","pm35","pm40","pm46","pm5","pm50","pm55","pm8","pn","pne","po","pr10","pr100","pr20","pr30","pr40","pr45","pr50","pr60","pr70","pr80","ps","pw2","pw25","pw3","pw32","pw35","pw4","pw42","pw45","p29","pax","pd","pe","phx","plx","pmx","pnl","prx","pwx","pl0","pl4","pl3","ph44","pn40","ph33","ph26"];
%blue_category=["i1","i10","i11","i12","i13","i14","i15","i2","i3","i4","i5","il100","il110","il50","il60","il70","il80","il90","io","ip","i6","i7","i8","i9","ilx"];
%yellow_category=["w1","w10","w12","w13","w16","w18","w20","w21","w22","w24","w28","w3","w30","w31","w32","w34","w35","w37","w38","w41","w42","w43","w44","w45","w46","w47","w48","w49","w5","w50","w55","w56","w57","w58","w59","w60","w62","w63","w66","w8","wo","w29","w33","w36","w39","w4","w40","w51","w52","w53","w54","w6","w61","w64","w65","w67","w7","w9","w11","w14","w15","w17","w19","w2","w23","w25","w26","w27"];

%90 red signs
red_category=["p13","p14","p19","p2","p20","p21","p23","p24","p26","p28","p3","p5","p7","p8","pa10","pa12","pa13","pa14","pa8","ph15","ph2","ph21","ph22","ph24","ph25","ph28","ph29","ph3","ph32","ph35","ph38","ph4","ph42","ph43","ph45","ph48","ph5","ph53","ph55","pl10","pl100","pl110","pl120","pl15","pl20","pl25","pl30","pl35","pl40","pl5","pl50","pl60","pl65","pl70","pl80","pl90","pm10","pm13","pm15","pm2","pm20","pm25","pm30","pm35","pm40","pm46","pm5","pm50","pm55","pm8","pr10","pr100","pr20","pr30","pr40","pr45","pr50","pr60","pr70","pr80","pw2","pw25","pw3","pw32","pw35","pw4","pw42","pw45","pax","phx","plx","pmx","prx","pwx","pl4","pl3","ph44","pn40","ph33","ph26"];
blue_category=["none"];
yellow_category=["none"];



location='C:\Users\Jack\Desktop\darknet-master-for-train\build\darknet\x64\data\obj\';
location_train='C:\Users\Jack\Desktop\darknet-master-for-train\build\darknet\x64\data\train.txt';
location_test='C:\Users\Jack\Desktop\darknet-master-for-train\build\darknet\x64\data\test.txt';
location_other='C:\Users\Jack\Desktop\darknet-master-for-train\build\darknet\x64\data\other.txt';
location_classname='C:\Users\Jack\Desktop\darknet-master-for-train\build\darknet\x64\data\obj.names';

% fname = 'annotations.json';
% data = loadjson(fname,'ShowProgress',1);




dict=[red_category,blue_category,yellow_category]';

fid = fopen(location_classname,'wt');
fprintf(fid,'%s\n', dict{:});
fclose(fid);




load('matlab_format.mat');


imgs=struct2cell(data.imgs);


train_data={};
test_data={};
other_data={};
anno=[];

%extract from .json
for i=1:length(imgs)
    filename=strcat(num2str(imgs{i}.id),'.txt');
    picname=strcat(num2str(imgs{i}.id),'.jpg');
    if isempty(strfind(imgs{i}.path,'other'))
        objects=imgs{i}.objects;
        
        if ~isempty(objects)
            anno=[];
            for j=1:length(objects)
                
                object=objects{j};
                category=strrep(object.category,'.','');
                xmin=object.bbox.xmin;
                ymin=object.bbox.ymin;
                xmax=object.bbox.xmax;
                ymax=object.bbox.ymax;
                
                cx=(xmax+xmin)/2;
                cy=(ymax+ymin)/2;
                width=xmax-xmin;
                height=ymax-ymin;
                coor=[cx,cy,width,height]/2048;
                
%                 if (sum(strcmp(red_category,category))+sum(strcmp(blue_category,category))+sum(strcmp(yellow_category,category))~=1)
%                     error('wtf1');
%                 end
                
                if  sum(strcmp(red_category,category))==1
                    class=find(strcmp(red_category,category));
                elseif  sum(strcmp(blue_category,category))==1
                    class=find(strcmp(blue_category,category))+length(red_category);
                elseif  sum(strcmp(yellow_category,category))==1
                    class=find(strcmp(yellow_category,category))+length(red_category)+length(blue_category);
                else
                    continue;
                end
                if class-1<0
                    error('wtf4');
                end
                coor=[class-1,coor];
                anno=[anno;coor];
                
            end
        else
            error('wtf2');
        end
        file_path=strcat(location,filename);
        dlmwrite(file_path,anno,'delimiter',' ','newline','pc');
    end
    
    
    
    
    %     if ~isempty(anno)
    %         if ~isempty(strfind(imgs{i}.path,'train'))
    %             train_data=[train_data;strcat('data/obj/',picname)];
    %         elseif ~isempty(strfind(imgs{i}.path,'test'))
    %             test_data=[test_data;strcat('data/obj/',picname)];
    %         end
    %     else
    %         other_data=[other_data;strcat('data/obj/',picname)];
    %     end
    
    if ~isempty(strfind(imgs{i}.path,'train'))
        train_data=[train_data;strcat('data/obj/',picname)];
    elseif ~isempty(strfind(imgs{i}.path,'test'))
        test_data=[test_data;strcat('data/obj/',picname)];
        
    else
        other_data=[other_data;strcat('data/obj/',picname)];
    end
    
    
end


fid = fopen(location_train,'wt');
fprintf(fid,'%s\n', train_data{:});
fclose(fid);

fid = fopen(location_test,'wt');
fprintf(fid,'%s\n', test_data{:});
fclose(fid);

fid = fopen(location_other,'wt');
fprintf(fid,'%s\n', other_data{:});
fclose(fid);

