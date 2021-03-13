clearvars -except A

mat_files=dir(fullfile(pwd,'ROI_mini.mat'));

mkdir('train_images');
delete('train_images/*')
mkdir('val_images');
delete('val_images/*')
mkdir('ROIs')
delete('ROIs/*')
mkdir('train_labels');
delete('train_labels/*')
mkdir('val_labels');
delete('val_labels/*')
mkdir('checker');
delete('checker/*')

if exist('A','var') == 1
    disp('ROIs have already been loaded into ram')
else
    A = load(fullfile(mat_files(1).folder,mat_files(1).name));
end

only_xmls = 0;
create_val = 0;

num_roi_imgs = length(A.ref_img);

k = 1;
for i = 1:num_roi_imgs
    
    disp([num2str(i) '/' num2str(num_roi_imgs)])
    
    this_img = A.ref_img{i};
    this_roi = A.ROI{i};
    
    % first image, normal 
    [k]=write_imgs(this_img,this_roi,k,only_xmls);
    
    % second image, flipped
    temp_img = flipud(this_img);
    temp_roi = flipud(this_roi);
    
    [k]=write_imgs(temp_img,temp_roi,k,only_xmls);
    
    % third image, contrast adjusted
    temp_img = imadjust(this_img);
    temp_roi = this_roi;
    
    [k]=write_imgs(temp_img,temp_roi,k,only_xmls);
    
    % fourth rotate +1
    temp_img = imrotate(this_img,1,'crop');
    temp_roi = imrotate(this_roi,1,'crop');
    
    [k]=write_imgs(temp_img,temp_roi,k,only_xmls);
        
    % fifth rotate -1
    temp_img = imrotate(this_img,-1,'crop');
    temp_roi = imrotate(this_roi,-1,'crop');
    
    [k]=write_imgs(temp_img,temp_roi,k,only_xmls);
    
    
end

if create_val
    txt_files=dir(fullfile(pwd,'train_labels','*.txt'));
    jpg_files=dir(fullfile(pwd,'train_images','*.jpg'));
    
    val_nums = unique(randi(length(txt_files),1,25));
    
    for i = val_nums
        
        disp(['moving ' txt_files(i).name ' to val_labels'])
        movefile(fullfile(pwd,'train_labels',txt_files(i).name),...
            fullfile(pwd,'val_labels',txt_files(i).name));
        
        disp(['moving ' jpg_files(i).name ' to val_labels'])
        movefile(fullfile(pwd,'train_images',jpg_files(i).name),...
            fullfile(pwd,'val_images',jpg_files(i).name));
    end
end


function [k]=write_imgs(temp_img,temp_roi,k,only_xmls)

    temp_roi_bw = temp_roi>0;
    
    if only_xmls
    else
        imwrite(temp_img,fullfile(pwd,'train_images',[num2str(k) '.jpg']));
        imwrite(temp_roi,fullfile(pwd,'ROIs',[num2str(k) '.jpg']));
    end
    
    imwrite(temp_img.*uint8(temp_roi_bw),fullfile(pwd,'checker',[num2str(k) '.jpg']));
    
    s_centroid = regionprops(temp_roi_bw,'Centroid');
    s_box = regionprops(temp_roi_bw,'BoundingBox');
    
    write_to_yolo_txt(s_centroid,s_box,k,temp_roi)
    k=k+1;
end

function write_to_yolo_txt(s_centroid,s_box,k,this_roi)
fileID = fopen(fullfile(pwd,'train_labels',[num2str(k) '.txt']),'w');

show_imgs = 1;

[image_w,image_h] = size(this_roi);

if show_imgs
    figure;
    imshow(this_roi,[])
    hold on
end

for i = 1:length(s_centroid)
    
    this_centroid = s_centroid(i).Centroid;
    
    cen_test = s_centroid(i).Centroid;
    
    this_centroid(1) = this_centroid(1)/image_h;
    this_centroid(2) = this_centroid(2)/image_w;
    
    if this_centroid(1) >1 || this_centroid(2)>1
        disp('asdf')
    end
    
    this_wh = s_box(i).BoundingBox;
    this_wh = this_wh(3:4);
    
    % the image w and h might be swapped?
    this_w = this_wh(1)/image_w;
    this_h = this_wh(2)/image_h;
    
    coords = [this_centroid(1),this_centroid(2),this_w,this_h];
    if show_imgs
        plot(coords(1)*image_h,coords(2)*image_w,'r*')
    end
    if i == 1
        fprintf(fileID,'%s',string([num2str(0) ' ']));
        fprintf(fileID,'%s',sprintf('%.6f ' , coords));
    else
        fprintf(fileID,'\n%s',string([num2str(0) ' ']));
        fprintf(fileID,'%s',sprintf('%.6f ' , coords));
    end
    
end
if show_imgs
    hold off
end

fclose('all');

end
