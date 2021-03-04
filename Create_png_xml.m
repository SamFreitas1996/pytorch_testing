
mat_files=dir(fullfile(pwd,'ROI_mini.mat'));

mkdir('images');
mkdir('ROIs')
mkdir('train_labels');
mkdir('val_labels');

% A = load(fullfile(mat_files(1).folder,mat_files(1).name));

only_xmls = 0;

num_roi_imgs = length(A.ref_img);

k = 1;
for i = 1:num_roi_imgs
    
    disp([num2str(i) '/' num2str(num_roi_imgs)])
    
    this_img = A.ref_img{i};
    this_roi = A.ROI{1};
    
    roi_nums = randi(240,1,25);
    
    this_roi2 = zeros(size(this_roi));
    for j = roi_nums
        this_roi2 = this_roi2 + j*double(this_roi==j);
    end
    
    if only_xmls
    else
    imwrite(this_img,fullfile(pwd,'images',[num2str(k) '.jpg']));
    imwrite(this_roi2,fullfile(pwd,'ROIs',[num2str(k) '.jpg']));
    end
    
    s = regionprops(this_roi2>0,'BoundingBox');
    
    write_to_xml(s,k,this_roi2)
    k=k+1;
    
    if only_xmls
    else
    imwrite(flipud(this_img),fullfile(pwd,'images',[num2str(k) '.jpg']));
    imwrite(flipud(this_roi2),fullfile(pwd,'ROIs',[num2str(k) '.jpg']));
    end
    
    s = regionprops(flipud(this_roi2)>0,'BoundingBox');

    write_to_xml(s,k,this_roi2)
    k=k+1;
    
    this_img_adj = imadjust(this_img);
    
    if only_xmls
    else
    imwrite(this_img_adj,fullfile(pwd,'images',[num2str(k) '.jpg']));
    imwrite(this_roi2,fullfile(pwd,'ROIs',[num2str(k) '.jpg']));
    end
    
    s = regionprops(this_roi2>0,'BoundingBox');

    write_to_xml(s,k,this_roi2)
    k=k+1;
    
    
end


xml_files=dir(fullfile(pwd,'train_labels','*.xml'));

val_nums = unique(randi(length(xml_files),1,25));

for i = val_nums
    
    disp(['moving ' xml_files(i).name ' to val_labels'])
    movefile(fullfile(pwd,'train_labels',xml_files(i).name),...
        fullfile(pwd,'val_labels',xml_files(i).name));
end

function write_to_xml(s,j,this_roi)
fileID = fopen(fullfile(pwd,'train_labels',[num2str(j) '.txt']),'w');
fprintf(fileID,'%s',"<annotation>");
fprintf(fileID,'\n\t%s',"<folder>images</folder>");

f_name = string(['<filename>' num2str(j) '.jpg</filename>']);
fprintf(fileID,'\n\t%s',f_name);

f_path = string(['<path>' fullfile(pwd,'images',[num2str(j) '.jpg']) '</path>']);
% fprintf(fileID,'\n\t%s',f_path);

fprintf(fileID,'\n\t%s',"<source>");
fprintf(fileID,'\n\t\t%s',"<database>Unknown</database>");
fprintf(fileID,'\n\t%s',"</source>");

fprintf(fileID,'\n\t%s',"<size>");
[h,w] = size(this_roi);
f_width = string(['<width>' num2str(w) '</width>']);
f_height = string(['<height>' num2str(h) '</height>']);
fprintf(fileID,'\n\t\t%s',f_width);
fprintf(fileID,'\n\t\t%s',f_height);
fprintf(fileID,'\n\t\t%s',"<depth>3</depth>");
fprintf(fileID,'\n\t%s',"</size>");

fprintf(fileID,'\n\t%s',"<segment>0</segment>");

for i = 1:length(s)
    
    fprintf(fileID,'\n\t%s',"<object>");
    
    fprintf(fileID,'\n\t\t%s',"<name>WM_well</name>");
    fprintf(fileID,'\n\t\t%s',"<pose>Unspecified</pose>");
    fprintf(fileID,'\n\t\t%s',"<truncated>0</truncated>");
    fprintf(fileID,'\n\t\t%s',"<difficult>0</difficult>");
    
    fprintf(fileID,'\n\t\t%s',"<bndbox>");
        
    coords = round(s(i).BoundingBox);
    
    xmin = coords(1);
    f_xmin = string(['<xmin>' num2str(xmin) '</xmin>']);
    fprintf(fileID,'\n\t\t\t%s',f_xmin);
    
    ymin = coords(2);
    f_ymin = string(['<ymin>' num2str(ymin) '</ymin>']);
    fprintf(fileID,'\n\t\t\t%s',f_ymin);
    
    xmax = coords(1) + 204;
    f_xmax = string(['<xmax>' num2str(xmax) '</xmax>']);
    fprintf(fileID,'\n\t\t\t%s',f_xmax);
    
    ymax = coords(2) + 204;
    f_ymax = string(['<ymax>' num2str(ymax) '</ymax>']);
    fprintf(fileID,'\n\t\t\t%s',f_ymax);
    
    fprintf(fileID,'\n\t\t%s',"</bndbox>");
    
    fprintf(fileID,'\n\t%s',"</object>");
    
end

fprintf(fileID,'\n%s',"</annotation>");

fclose('all');

movefile(fullfile(pwd,'train_labels',[num2str(j) '.txt']),fullfile(pwd,'train_labels',[num2str(j) '.xml']));

end
