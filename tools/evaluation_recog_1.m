clc;
% clear all;
%% set file
annotator='2017-08-08_19-33-07-233.xml';
json=     '2017-08-08_19-33-07-233.json';




%% set parameters
iou=0.5;

red_category=["p13","p14","p19","p2","p20","p21","p23","p24","p26","p28","p3","p5","p7","p8","pa10","pa12","pa13","pa14","pa8","ph15","ph2","ph21","ph22","ph24","ph25","ph28","ph29","ph3","ph32","ph35","ph38","ph4","ph42","ph43","ph45","ph48","ph5","ph53","ph55","pl10","pl100","pl110","pl120","pl15","pl20","pl25","pl30","pl35","pl40","pl5","pl50","pl60","pl65","pl70","pl80","pl90","pm10","pm13","pm15","pm2","pm20","pm25","pm30","pm35","pm40","pm46","pm5","pm50","pm55","pm8","pr10","pr100","pr20","pr30","pr40","pr45","pr50","pr60","pr70","pr80","pw2","pw25","pw3","pw32","pw35","pw4","pw42","pw45","pax","phx","plx","pmx","prx","pwx","pl4","pl3","ph44","pn40","ph33","ph26"];
%              0     1       2    3    4     5     6     7     8     9    10   11   12   13   14     15      16     17    18     19     20    21      22     23    24     25     26     27     28    29     30     31     32    33      34    35    36     37    38      39     40      41       42     43     44     45     46    47      48    49      50    51     52     53      54     55     56    57     58    59     60     61     62     63    64      65    66     67      68    69    70     71      72     73      74    75     76     77     78     79     80     81    82     83    84     85     86     87    88    89    90    91    92    93    94    95    96     97      98    99

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

result=strings(size(gt_class,2),5); % tp,fp,fn,precision,recall
result(:,2)='0';
fn=0;
fp=0;
tp=[];
json_cnt=1;
max_signid=0;

%% read json and xml data
% json
test = fileread(json);
test_json=jsondecode(test);
prdct_frames=test_json.optput.frames;
% xml
% xml_file=xml2struct(annotator);
gt_xml=xml_file.Entries.SignEntry;

%% do the job

for frm_cnt=1:size(gt_xml,2)
    json_frm_string=strsplit(prdct_frames(json_cnt).frame_number,'.');
    
    json_frm=str2num(json_frm_string{1});
    
    if frm_cnt==json_frm
        if strcmp(gt_xml{frm_cnt}.ContainsSign.Text,'true')
            if isfield(gt_xml{frm_cnt}.DetectedSigns,'DetectedSign')
                %% grab info. from xml
                gt_str=get_xml_data(gt_xml,frm_cnt);
                
                % save rois
                crrnt_gt_rois=str2num(gt_str);
                
                if isempty(prdct_frames(json_cnt).RoIs)
                    continue;
                end
                
                crrnt_prdct_rois= str2num(prdct_frames(json_cnt).RoIs);
                for i=1:size(crrnt_prdct_rois,1)
                    
                    crrnt_prdct_rois(i,1)=map_signid_number(map_class(crrnt_prdct_rois(i,1)));
                end
                % make flags
                gt_bbx_unusd_flg=ones(size(crrnt_gt_rois,1),1);
                prdct_bbx_unusd_flg=ones(size(crrnt_prdct_rois,1),1);
                
                %% == check fn
                for i=1:size(crrnt_gt_rois,1)
                    for j=1:size(crrnt_prdct_rois,1)
                        test_iou=bboxOverlapRatio(crrnt_gt_rois(i,2:5),crrnt_prdct_rois(j,2:5),'min');
                        if (test_iou>=iou && prdct_bbx_unusd_flg(j)==1 && gt_bbx_unusd_flg(i)==1 &&...
                                crrnt_gt_rois(i,1)==crrnt_prdct_rois(j,1))
                            gt_bbx_unusd_flg(i)=0;
                            prdct_bbx_unusd_flg(j)=0;
                            result(int8(crrnt_gt_rois(i,1)),1)=strcat(result(int8(crrnt_gt_rois(i,1)),1),num2str(crrnt_gt_rois(i,6)),',');
                        end
                    end
                end
                % check gt_bbx_unusd_flg. If one, append info. to class->fn
                for i=1:size(gt_bbx_unusd_flg,1)
                    if gt_bbx_unusd_flg(i)==1 && crrnt_gt_rois(i,1)~=26 &&  crrnt_gt_rois(i,1)~=27 &&  crrnt_gt_rois(i,1)~=30
                        result(int8(crrnt_gt_rois(i,1)),3)=strcat(result(int8(crrnt_gt_rois(i,1)),3),num2str(crrnt_gt_rois(i,6)),',');
                    end
                end
                % check prdct_bbx_unusd_flg. If one, append info. to class->fp
                for i=1:size(prdct_bbx_unusd_flg,1)
                    if prdct_bbx_unusd_flg(i)==1 && crrnt_prdct_rois(i,1)~=26 &&  crrnt_prdct_rois(i,1)~=27 && crrnt_prdct_rois(i,1)~=30
                        result(int8(crrnt_prdct_rois(i,1)),2)=num2str(str2num(char(result(int8(crrnt_prdct_rois(i,1)),2)))+1);
                    end
                end
                %==end of 'check fn'
            end
            
        elseif strcmp(gt_xml{frm_cnt}.ContainsSign.Text,'false')
            fp=fp+1;
            crrnt_prdct_rois= str2num(prdct_frames(json_cnt).RoIs);
            for i=1:size(crrnt_prdct_rois,1)
                crrnt_prdct_rois(i,1)=map_signid_number(map_class(crrnt_prdct_rois(i,1)));
            end
            for j=1:size(crrnt_prdct_rois,1)
                %result(int8(crrnt_prdct_rois(j,1)),2)=num2str(str2num(char(result(int8(crrnt_prdct_rois(j,1)),2)))+1);
                if  crrnt_prdct_rois(j,1)~=26 &&  crrnt_prdct_rois(j,1)~=27 &&  crrnt_prdct_rois(j,1)~=30
                    result(int8(crrnt_prdct_rois(j,1)),2)=num2str(str2num(char(result(int8(crrnt_prdct_rois(j,1)),2)))+1);
                end
            end
        end
        
        if json_cnt<size(prdct_frames,1)
            json_cnt=json_cnt+1;
        end
    end
end

% calculate tp,fp,fn,precision,recall and mAP
precision_cnt=0;
precision_sum=0;
for i=1:size(result,1)
    result(i,4)=length(strsplit(result(i,1),','))-1;
    result(i,5)=length(strsplit(result(i,3),','))-1;
    tp_count=str2num(result{i,4});
    fn_count=str2num(result{i,5});
    fp_count=str2num(result{i,2});
    
    if (tp_count+fp_count)~=0
        precision=tp_count/(tp_count+fp_count);
        result(i,6)=num2str(precision);
        precision_cnt=precision_cnt+1;
        precision_sum=precision_sum+precision;
    end
    if (tp_count+fn_count)~=0
        recall=tp_count/(tp_count+fn_count);
        result(i,7)=num2str(recall);
    end
end
map=precision_sum/precision_cnt;

%save result to .xlsx
result=[["tp","fp_count","fn","tp_count","fn_count","precision","recall"];result];
result=[["class_name";gt_class'],result];
xlswrite(strcat('recognition_result_mAP=',num2str(map),'.xlsx'),result);



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

function gt_output=get_xml_data(gt_xml, frm_cnt)
gt_output=[];
if size(gt_xml{frm_cnt}.DetectedSigns.DetectedSign,2)>1
    for bbxs_cnt=1:size(gt_xml{frm_cnt}.DetectedSigns.DetectedSign,2)
        xml_c=gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.SignClass.Text;
        xml_x=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.X.Text));
        xml_y=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.Y.Text));
        xml_w=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.Width.Text));
        xml_h=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.Height.Text));
        xml_s=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.SignID.Text));
        gt_output=strcat(gt_output,int2str(map_signid_number(xml_c)),',',int2str(xml_x),',',int2str(xml_y),',',int2str(xml_w),',',int2str(xml_h),',',int2str(xml_s),';');
    end
    
    % if only one xml_bbox
else
    xml_c=gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).SignClass.Text;
    xml_x=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.X.Text));
    xml_y=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.Y.Text));
    xml_w=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.Width.Text));
    xml_h=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.Height.Text));
    xml_s=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).SignID.Text));
    gt_output=strcat(gt_output,int2str(map_signid_number(xml_c)),',',int2str(xml_x),',',int2str(xml_y),',',int2str(xml_w),',',int2str(xml_h),',',int2str(xml_s),';');
end

end
