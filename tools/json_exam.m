iou=0.5;
class=['red'];
result=zeros(length(class),5); % tp,fp,fn,precision,recall

test = fileread('output.json');
test_json=jsondecode(test);
[gt_num,gt_txt,gt_raw]=xlsread('Annotator.xlsx');
anno_str='';
temp=0;


%transform Annotator into json like format
for anno_num=2:size(gt_num,1)+1
    
	name=cellstr(gt_txt(anno_num,1));
	frame_num=strsplit(name{1},'.');
	frame_num=frame_num{1}; 
    
    gt_class=gt_raw(anno_num,2);     
    gt_class=gt_class{1};
	if  ~isnan(gt_class)
        if temp~=str2num(frame_num) || temp==0
            anno_str=strcat(anno_str,'*',frame_num ,'#');
            anno_str=strcat(anno_str,num2str(gt_class),',',int2str(round(gt_num(anno_num-1,4))),',',int2str(round(gt_num(anno_num-1,5))),',',int2str(round(gt_num(anno_num-1,6))),',',int2str(round(gt_num(anno_num-1,7))),';');      
        else
            anno_str=strcat(anno_str,num2str(gt_class),',',int2str(round(gt_num(anno_num-1,4))),',',int2str(round(gt_num(anno_num-1,5))),',',int2str(round(gt_num(anno_num-1,6))),',',int2str(round(gt_num(anno_num-1,7))),';');
        end
            temp=str2num(frame_num);      
    end
end



gt_frames=strsplit(anno_str,'*')';
gt_frames=gt_frames(2:end);
gt_last_frm_nmbr=getFrameNum(gt_frames(end));
prdct_last_frm_nmbr=str2num(test_json.optput.frames(end).frame_number);

prdct_frm_tbl_cnt=1;
gt_frm_tbl_cnt=1;

for class=1:size(class,2)
    
    %check every frame
    for frm_cnt=1:max(gt_last_frm_nmbr,prdct_last_frm_nmbr)
        
        %if find frame number matches gt_frm_num
        if getFrameNum(gt_frames(gt_frm_tbl_cnt))==frm_cnt
            
            %while frame number is larger than/equal to prdct_frm_nmbr at n-th prdct data
            crrnt_prdct_frm=test_json.optput.frames(prdct_frm_tbl_cnt).frame_number;
            crrnt_prdct_rois=test_json.optput.frames(prdct_frm_tbl_cnt).RoIs;
            while(frm_cnt>=crrnt_prdct_frm)
                
                if frm_cnt>crrnt_prdct_frm
                    %handle FP here
                    crrnt_prdct_rois=crrnt_prdct_rois(find(crrnt_prdct_rois(:,1)==class),:);
                    if isempty(crrnt_prdct_rois)
                        prdct_frm_tbl_cnt=prdct_frm_tbl_cnt+1;
                        continue;
                    else
                        result(class,2)=result(class,2)+1;
                    end
                 else       
                %====================same frame num==========================================
                    crrnt_gt_rois=getFrameRois(gt_frames(gt_frm_tbl_cnt));
                    
                   %crrent rois with same class
                    crrnt_gt_rois=crrnt_gt_rois(find(crrnt_gt_rois(:,1)==class),:);
                    crrnt_prdct_rois=crrnt_prdct_rois(find(crrnt_prdct_rois(:,1)==class),:);
                    if isempty(crrnt_gt_rois) && isempty(crrnt_prdct_rois)
                        prdct_frm_tbl_cnt=prdct_frm_tbl_cnt+1;
                        continue;
                    %fp    
                    elseif  isempty(crrnt_gt_rois) && ~isempty(crrnt_prdct_rois)
                        result(class,2)=result(class,2)+size(crrnt_prdct_rois,1);
                    %fn    
                    elseif ~isempty(crrnt_gt_rois) &&  isempty(crrnt_prdct_rois)
                        result(class,3)=result(class,3)+size(crrnt_gt_rois,1);
                    else
                        %use flags to check if bbxs are matched  
                        gt_bbx_unusd_flg=oness(size(crrnt_gt_rois,1));
                        prdct_bbx_unusd_flg=ones(size(crrnt_prdct_rois,1));
 
                        % check tp
                        for i=1:size(crrnt_gt_rois,1)
                            for j=1:size(crrnt_prdct_rois,1)
                                if (bboxOverlapRatio(crrnt_gt_rois(2:5),crrnt_prdct_rois(2:5))>iou &&...
                                   prdct_bbx_usd_flg(j)==1 &&...
                                   gt_bbx_unusd_flg(i)==1)
                            
                                   %tp of the class +1
                                   result(class,1)=result(class,1)+1;    
                                   gt_bbx_unusd_flg(i)=0;
                                   prdct_bbx_unusd_flg(j)=0;
                                                             
                                end
                            end
                        end          
                        result(class,2)=result(class,2)+sum(prdct_bbx_unusd_flg);
                        result(class,3)=result(class,3)+sum(gt_bbx_unusd_flg);
                    end
                %================================================================      
                end      
                prdct_frm_tbl_cnt=prdct_frm_tbl_cnt+1;
            end            
        end     
    end
end

function out=getFrameNum(input)
    gt_last_frm_nmbr_cell=input{1};
    gt_last_frm_nmbr_str=strsplit(gt_last_frm_nmbr_cell,'#');
    out=gt_last_frm_nmbr_str{1};
end

function out=getFrameRois(input)
    gt_last_frm_nmbr_cell=input{1};
    gt_last_frm_nmbr_str=strsplit(gt_last_frm_nmbr_cell,'#');
    out=gt_last_frm_nmbr_str{2};
end