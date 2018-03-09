clc;
close all;
clear all;


data=load('table_backup\tt100k_table_train.mat');
data1=load('table_backup\tt100k_table_test.mat');


red_category=["path","p1","p10","p11","p12","p13","p14","p15","p16","p17","p18","p19","p2","p20","p21","p22","p23","p24","p25","p26","p27","p28","p3","p4","p5","p6","p7","p8","p9","pa10","pa12","pa13","pa14","pa8","pb","pc","pg","ph15","ph2","ph21","ph22","ph24","ph25","ph28","ph29","ph3","ph32","ph35","ph38","ph4","ph42","ph43","ph45","ph48","ph5","ph53","ph55","pl10","pl100","pl110","pl120","pl15","pl20","pl25","pl30","pl35","pl40","pl5","pl50","pl60","pl65","pl70","pl80","pl90","pm10","pm13","pm15","pm15","pm2","pm20","pm25","pm30","pm35","pm40","pm46","pm5","pm50","pm55","pm8","pn","pne","po","pr10","pr100","pr20","pr30","pr40","pr45","pr50","pr60","pr70","pr80","ps","pw2","pw25","pw3","pw32","pw35","pw4","pw42","pw45","p29","pax","pd","pe","phx","plx","pmx","pnl","prx","pwx","pl0","pl4","pl3","pm25","ph44","pn40","ph33","ph26"];
blue_category=["i1","i10","i11","i12","i13","i14","i15","i2","i3","i4","i5","il100","il110","il50","il60","il70","il80","il90","io","ip","i6","i7","i8","i9","ilx"];
yellow_category=["w1","w10","w12","w13","w16","w18","w20","w21","w22","w24","w28","w3","w30","w31","w32","w34","w35","w37","w38","w41","w42","w43","w44","w45","w46","w47","w48","w49","w5","w50","w55","w56","w57","w58","w59","w60","w62","w63","w66","w8","wo","w29","w33","w36","w39","w4","w40","w51","w52","w53","w54","w6","w61","w64","w65","w67","w7","w9","w11","w14","w15","w17","w19","w2","w23","w25","w26","w27"];

train_table=data.train_table;
train_table_red=tt100kEmptyTableRed(size(train_table,1));

test_table=data1.test_table;
test_table_red=tt100kEmptyTableRed(size(test_table,1));


%extract from .json
for i=1:length(red_category)

    try
  eval(strcat('train_table_red.',red_category(i),'=train_table.',red_category(i),';'));
  eval(strcat('test_table_red.',red_category(i),'=test_table.',red_category(i),';'));
    catch
    end
end


idx=all(cellfun(@isempty,train_table_red{:,:}),1);
train_table_red(:,idx)=[];


idy=all(cellfun(@isempty,train_table_red{:,[2:end]}),2);
train_table_red(idy,:)=[];


idx1=all(cellfun(@isempty,test_table_red{:,:}),1);
test_table_red(:,idx1)=[];


idy1=all(cellfun(@isempty,test_table_red{:,[2:end]}),2);
test_table_red(idy1,:)=[];


save('tt100k_table_train_red.mat', 'train_table_red');
save('tt100k_test_train_red.mat', 'test_table_red');


path={};
signs_coor={};
for i=1:size(train_table_red,1)
        coor=[];
        for j= 1:size(train_table_red,2)
            if j==1
                path=[path;train_table_red{i,j}];   
            else                                          
                coor=[coor;cell2mat(train_table_red{i,j})];
            end    
        end
        signs_coor=[signs_coor;coor];

        
        
end

path1={};
signs_coor1={};
for i=1:size(test_table_red,1)
        coor1=[];
        for j= 1:size(test_table_red,2)
            if j==1
                path1=[path1;test_table_red{i,j}];   
            else                                          
                coor1=[coor1;cell2mat(test_table_red{i,j})];
            end    
        end
        signs_coor1=[signs_coor1;coor1];

        
        
end


train_table_red_merged=table(path,signs_coor);
save('tt100k_train_table_red_merged.mat', 'train_table_red_merged');




test_table_red_merged=table(path1,signs_coor1);
save('tt100k_test_table_red_merged.mat', 'test_table_red_merged');










