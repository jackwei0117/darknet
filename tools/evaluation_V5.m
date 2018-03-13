clc;
clear all;
%% set file
annotator='2018-01-26_10-44-55-445.xml';
json=     '2018-01-26_10-44-55-445.json';

%% set parameters
iou=0.5;
class=['red'];
result=zeros(size(class,1),5); % tp,fp,fn,precision,recall
fn=0;
fp=0;
tp=0;
json_cnt=1;
max_signid=0;

%% read json and xml data
% json
test = fileread(json);
test_json=jsondecode(test);
prdct_frames=test_json.optput.frames;
% xml
xml_file=xml2struct(annotator);
gt_xml=xml_file.Entries.SignEntry;

%% do the job
for frm_cnt=1:size(gt_xml,2)
    json_cnt=frm_cnt;
    json_frm_str=strsplit(prdct_frames(json_cnt).frame_number,'.');
    json_frm=str2num(json_frm_str{1});

        if strcmp(gt_xml{frm_cnt}.ContainsSign.Text,'true')
            if isfield(gt_xml{frm_cnt}.DetectedSigns,'DetectedSign')
                
                %% grab info. from xml
                gt_str=[];
                
                % if more than one xml_bbox
                if size(gt_xml{frm_cnt}.DetectedSigns.DetectedSign,2)>1
                    for bbxs_cnt=1:size(gt_xml{frm_cnt}.DetectedSigns.DetectedSign,2)
                        xml_c=1;
                        xml_x=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.X.Text));
                        xml_y=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.Y.Text));
                        xml_w=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.Width.Text));
                        xml_h=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.Height.Text));
                        xml_s=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.SignID.Text));
                        gt_str=strcat(gt_str,num2str(xml_c),',',int2str(xml_x),',',int2str(xml_y),',',int2str(xml_w),',',int2str(xml_h),',',int2str(xml_s),';');
                        if xml_s>max_signid
                            max_signid=xml_s;
                        end
                    end
                    
                    % if only one xml_bbox
                else
                    xml_c=1;
                    xml_x=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.X.Text));
                    xml_y=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.Y.Text));
                    xml_w=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.Width.Text));
                    xml_h=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.Height.Text));
                    xml_s=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).SignID.Text));
                    gt_str=strcat(gt_str,num2str(xml_c),',',int2str(xml_x),',',int2str(xml_y),',',int2str(xml_w),',',int2str(xml_h),',',int2str(xml_s),';');
                    if xml_s>max_signid
                        max_signid=xml_s;
                    end
                end
                % save rois
                crrnt_gt_rois=str2num(gt_str);
                if isempty(prdct_frames(json_cnt).RoIs)
                    continue;
                end
                
                crrnt_prdct_rois= str2num(prdct_frames(json_cnt).RoIs);
                % make flags
                gt_bbx_unusd_flg=ones(size(crrnt_gt_rois,1));
                prdct_bbx_unusd_flg=ones(size(crrnt_prdct_rois,1));
                
                %% == check fn
                for i=1:size(crrnt_gt_rois,1)
                    for j=1:size(crrnt_prdct_rois,1)
                        test_iou=bboxOverlapRatio(crrnt_gt_rois(i,2:5),crrnt_prdct_rois(j,2:5),'min');
                        
                        if (test_iou>=iou && prdct_bbx_unusd_flg(j)==1 && gt_bbx_unusd_flg(i)==1)
                            gt_bbx_unusd_flg(i)=0;
                            prdct_bbx_unusd_flg(j)=0;
                            tp=[tp;crrnt_gt_rois(i,6)];
                        end
                    end
                end
                %fn=fn+sum(gt_bbx_unusd_flg);
                %==end of 'check fn'
            end
            
        elseif strcmp(gt_xml{frm_cnt}.ContainsSign.Text,'false')
            fp=fp+1;
        end

end

% finalize fp fn
complete_signid=[];
k_stack=[];
for frm_cnt=1:size(gt_xml,2)
    if isfield(gt_xml{frm_cnt}.DetectedSigns,'DetectedSign')
        if size(gt_xml{frm_cnt}.DetectedSigns.DetectedSign,2)>1
            for bbxs_cnt=1:size(gt_xml{frm_cnt}.DetectedSigns.DetectedSign,2)
                SignClass=gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.SignClass.Text;
                signid=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.SignID.Text));
                
                complete_signid=[complete_signid,signid];
                if strcmp(SignClass(1:2),'k_')||strcmp(SignClass(1:2),'Un')
                    k_stack=[k_stack,signid];
                end
                
            end
        else
            SignClass=gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).SignClass.Text;
            signid=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).SignID.Text));
            complete_signid=[complete_signid,signid];
            if strcmp(SignClass(1:2),'k_')||strcmp(SignClass(1:2),'Un')
                k_stack=[k_stack,signid];
            end
        end
    end
end
complete_signid=unique(complete_signid);

%signs start from 'k' or 'Un'
k_stack=unique(k_stack);

fn_list=complete_signid;

%delete signs in k_stack from targets to be checked for fn
for i=1:length(k_stack)
    fn_list=fn_list(fn_list~=k_stack(i));
end


fn_signid=[];
tp=unique(tp);
%if a sign in signs to be checked is not in tp, consider it as fn
for i=1:length(fn_list)
    if ~sum(ismember(fn_list(i),tp))
        fn=fn+1;
        fn_signid=[fn_signid,fn_list(i)];
    end
end


fp=fp/size(gt_xml,2);
filename=annotator(1:end-4);
fileID = fopen(strcat(filename,'.txt'),'wt');
fprintf(fileID,'FP:%d\r\n',fp);
fprintf(fileID,'FN:%d\r\n',fn);

%for output info. of fn
output_info=[];
for frm_cnt=1:size(gt_xml,2)
    if isfield(gt_xml{frm_cnt}.DetectedSigns,'DetectedSign')
        if size(gt_xml{frm_cnt}.DetectedSigns.DetectedSign,2)>1
            for bbxs_cnt=1:size(gt_xml{frm_cnt}.DetectedSigns.DetectedSign,2)
                signid=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.SignID.Text));
                if ismember(signid,fn_signid)
                    frame_num=gt_xml{frm_cnt}.File.Text;
                    x=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.X.Text));
                    y=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.Y.Text));
                    w=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.Width.Text));
                    h=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.BoundingRectangle.Height.Text));
                    sid=gt_xml{frm_cnt}.DetectedSigns.DetectedSign{bbxs_cnt}.SignID.Text;                    
                    fprintf(fileID,'#frame:%s\tx:%d\ty:%d\tw:%d\th:%d\tsign_id:%s\n',frame_num,x,y,w,h,sid);
                end               
            end
        else
            signid=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).SignID.Text));
            if ismember(signid,fn_signid)
                frame_num=gt_xml{frm_cnt}.File.Text;
                x=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.X.Text));
                y=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.Y.Text));
                w=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.Width.Text));
                h=round(str2num(gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).BoundingRectangle.Height.Text));
                sid=gt_xml{frm_cnt}.DetectedSigns.DetectedSign(1).SignID.Text;
                fprintf(fileID,'#frame:%s\tx:%d\ty:%d\tw:%d\th:%d\tsign_id:%s\n',frame_num,x,y,w,h,sid);
            end
        end
    end
end

fclose(fileID);



