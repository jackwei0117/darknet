% red_category=["p13","p14","p19","p2","p20","p21","p23","p24","p26","p28","p3","p5","p7","p8","pa10","pa12","pa13","pa14","pa8","ph15","ph2","ph21","ph22","ph24","ph25","ph28","ph29","ph3","ph32","ph35","ph38","ph4","ph42","ph43","ph45","ph48","ph5","ph53","ph55","pl10","pl100","pl110","pl120","pl15","pl20","pl25","pl30","pl35","pl40","pl5","pl50","pl60","pl65","pl70","pl80","pl90","pm10","pm13","pm15","pm2","pm20","pm25","pm30","pm35","pm40","pm46","pm5","pm50","pm55","pm8","pr10","pr100","pr20","pr30","pr40","pr45","pr50","pr60","pr70","pr80","pw2","pw25","pw3","pw32","pw35","pw4","pw42","pw45","pax","phx","plx","pmx","prx","pwx","pl4","pl3","ph44","pn40","ph33","ph26"];
% %              0     1       2    3    4     5     6     7     8     9    10   11   12   13   14     15      16     17    18     19     20    21      22     23    24     25     26     27     28    29     30     31     32    33      34    35    36     37    38      39     40      41       42     43     44     45     46    47      48    49      50    51     52     53      54     55     56    57     58    59     60     61     62     63    64      65    66     67      68    69    70     71      72     73      74    75     76     77     78     79     80     81    82     83    84     85     86     87    88    89    90    91    92    93    94    95    96     97      98    99

red_category=["p1","p10","p11","p12","p13","p14","p15","p16","p17","p18","p19","p2","p20","p21","p22","p23","p24","p25","p26","p27","p28","p3","p4","p5","p6","p7","p8","p9","pa10","pa12","pa13","pa14","pa8","pb","pc","pg","ph15","ph2","ph21","ph22","ph24","ph25","ph28","ph29","ph3","ph32","ph35","ph38","ph4","ph42","ph43","ph45","ph48","ph5","ph53","ph55","pl10","pl100","pl110","pl120","pl15","pl20","pl25","pl30","pl35","pl40","pl5","pl50","pl60","pl65","pl70","pl80","pl90","pm10","pm13","pm15","pm2","pm20","pm25","pm30","pm35","pm40","pm46","pm5","pm50","pm55","pm8","pn","pne","po","pr10","pr100","pr20","pr30","pr40","pr45","pr50","pr60","pr70","pr80","ps","pw2","pw25","pw3","pw32","pw35","pw4","pw42","pw45","p29","pax","pd","pe","phx","plx","pmx","pnl","prx","pwx","pl0","pl4","pl3","ph44","pn40","ph33","ph26"];
blue_category=["i1","i10","i11","i12","i13","i14","i15","i2","i3","i4","i5","il100","il110","il50","il60","il70","il80","il90","io","ip","i6","i7","i8","i9","ilx"];
yellow_category=["w1","w10","w12","w13","w16","w18","w20","w21","w22","w24","w28","w3","w30","w31","w32","w34","w35","w37","w38","w41","w42","w43","w44","w45","w46","w47","w48","w49","w5","w50","w55","w56","w57","w58","w59","w60","w62","w63","w66","w8","wo","w29","w33","w36","w39","w4","w40","w51","w52","w53","w54","w6","w61","w64","w65","w67","w7","w9","w11","w14","w15","w17","w19","w2","w23","w25","w26","w27"];


gt_class=[  "a_no_left",...
    "a_no_left_truck",...
    "a_no_left_truck_tractor",...
    "b_no_right",...
    "b_no_right_truck",...
    "b_no_right_truck_tractor",...
    "c_no_straight",...
    "c_no_straight_truck_tractor",...
    "d_no_turn",...
    "d_no_turn_truck_tractor",...
    "e_right_only",...
    "e_right_only_truck_tractor",...
    "f_left_only",...
    "f_left_only_truck_tractor",...
    "g_height_clearance",...
    "g_width_clearance",...
    "g_weight_clearance",...
    "g_axle_load_clearance",...
    "h_truck_prohibited",...
    "h_truck_tractor_prohibited",...
    "h_truck_weight_prohibited",...
    "h_truck_time_prohibited",...
    "h_bus_prohibited",...
    "h_trailer_prohibited",...
    "i_speed_limit",...
    "i_advisory_speed_limit",...
    "i_minimum_speed_limit",...
    "i_no_speed_limit",...
    "j_no_u_turn",...
    "Unclassified"];

total_classes=[red_category,blue_category,yellow_category]';
count_table=[total_classes,num2str(zeros(size(total_classes)))];
gt_class=gt_class';
our_class_count=[gt_class,num2str(zeros(size(gt_class)))];

load('matlab_format.mat');
imgs=struct2cell(data.imgs);

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
                
               
                
                
                
                for k=1:size(count_table,1)
                    if count_table(k,1)==category
                         to_our_class=map_signid_number(map_class(k));
                        our_class_count(to_our_class,2)=num2str(str2num(our_class_count{to_our_class,2})+1);
                    end
                end
                
                
                %                 xmin=object.bbox.xmin;
                %                 ymin=object.bbox.ymin;
                %                 xmax=object.bbox.xmax;
                %                 ymax=object.bbox.ymax;
                %
                %                 cx=(xmax+xmin)/2;
                %                 cy=(ymax+ymin)/2;
                %                 width=xmax-xmin;
                %                 height=ymax-ymin;
                %                 coor=[cx,cy,width,height]/2048;
                %
                % %                 if (sum(strcmp(red_category,category))+sum(strcmp(blue_category,category))+sum(strcmp(yellow_category,category))~=1)
                % %                     error('wtf1');
                % %                 end
                %
                %                 if  sum(strcmp(red_category,category))==1
                %                     class=find(strcmp(red_category,category));
                %                 elseif  sum(strcmp(blue_category,category))==1
                %                     class=find(strcmp(blue_category,category))+length(red_category);
                %                 elseif  sum(strcmp(yellow_category,category))==1
                %                     class=find(strcmp(yellow_category,category))+length(red_category)+length(blue_category);
                %                 else
                %                     continue;
                %                 end
                %                 if class-1<0
                %                     error('wtf4');
                %                 end
                %                 coor=[class-1,coor];
                %                 anno=[anno;coor];
                %
                %                 for k=1:size(count_table,1)
                %                     if count_table(k,1)==category
                %                         count_table(k,2)=num2str(str2num(count_table{k,2})+1);
                %                     end
                %                 end
                %
                %
            end
            %         else
            %             error('wtf2');
        end
        %         file_path=strcat(location,filename);
        %         dlmwrite(file_path,anno,'delimiter',' ','newline','pc');
    end
end


function output=map_class(input)
if input==0
    output="h_truck_tractor_prohibited";
elseif input==1
    output="c_no_straight";
elseif input==2
    output="b_no_right";
elseif input==3
    output="Unclassified";
elseif input==4
    output="d_no_turn";
elseif input==5
    output="f_left_only";
elseif input==6
    output="a_no_left";
elseif input==7
    output="Unclassified";
elseif input==8
    output="h_truck_prohibited";
elseif input==9
    output="e_right_only";
elseif input==10
    output="h_bus_prohibited";
elseif input==11
    output="j_no_u_turn";
elseif input==12
    output="a_no_left_truck";
elseif input==13
    output="h_trailer_prohibited";
elseif input>=14 && input<=18
    output="g_axle_load_clearance";
elseif input>=19 && input<=38
    output="g_height_clearance";
elseif input>=39 && input<=55
    output="i_speed_limit";
elseif input>=56 && input<=69
    output="g_weight_clearance";
elseif input>=70 && input<=79
    output="i_no_speed_limit";
elseif input>=80 && input<=87
    output="g_width_clearance";
elseif input==88
    output="g_axle_load_clearance";
elseif input==89
    output="g_height_clearance";
elseif input==90
    output="i_speed_limit";
elseif input==91
    output="g_weight_clearance";
elseif input==92
    output="i_no_speed_limit";
elseif input==93
    output="g_width_clearance";
elseif input>=94 && input<=95
    output="i_speed_limit";
elseif input==96
    output="g_height_clearance";
elseif input==97
    output="Unclassified";
elseif input>=98 && input<=99
    output="g_height_clearance";
else
    output="Unclassified";
end
end

function output=map_signid_number(input)
switch input
    
    case 'a_no_left'
        output=1;
    case 'a_no_left_truck'
        output=2;
    case 'a_no_left_truck_tractor'
        output=3;
    case 'b_no_right'
        output=4;
    case 'b_no_right_truck'
        output=5;
    case 'b_no_right_truck_tractor'
        output=6;
    case 'c_no_straight'
        output=7;
    case 'c_no_straight_truck_tractor'
        output=8;
    case 'd_no_turn'
        output=9;
    case 'd_no_turn_truck_tractor'
        output=10;
    case 'e_right_only'
        output=11;
    case 'e_right_only_truck_tractor'
        output=12;
    case 'f_left_only'
        output=13;
    case 'f_left_only_truck_tractor'
        output=14;
    case 'g_height_clearance'
        output=15;
    case 'g_width_clearance'
        output=16;
    case 'g_weight_clearance'
        output=17;
    case 'g_axle_load_clearance'
        output=18;
    case 'h_truck_prohibited'
        output=19;
    case 'h_truck_tractor_prohibited'
        output=20;
    case 'h_truck_weight_prohibited'
        output=21;
    case 'h_truck_time_prohibited'
        output=22;
    case 'h_bus_prohibited'
        output=23;
    case 'h_trailer_prohibited'
        output=24;
    case 'i_speed_limit'
        output=25;
    case 'i_advisory_speed_limit' %yellow
        output=26;
    case 'i_minimum_speed_limit' %blue
        output=27;
    case 'i_no_speed_limit' %black
        output=28;
    case 'j_no_u_turn'
        output=29;
    otherwise
        output=30;
end
end