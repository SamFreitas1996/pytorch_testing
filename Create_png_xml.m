
mat_files=dir(fullfile(pwd,'ROI_mini.mat'));

mkdir('images');
mkdir('ROIs')
mkdir('annotations');

% A = load(fullfile(mat_files(1).folder,mat_files(1).name));

j = 1;
for i = 1:length(A.ref_img)
    
    this_img = A.ref_img{i};
    this_roi = A.ROI{1};
    
    imwrite(this_img,fullfile(pwd,'images',[num2str(j) '.jpg']));
    imwrite(this_roi,fullfile(pwd,'ROIs',[num2str(j) '.jpg']));
    
    s = regionprops(this_roi>0,'BoundingBox');
    
    write_to_xml(s,j,this_roi)
    j=j+1;
    
    imwrite(flipud(this_img),fullfile(pwd,'images',[num2str(j) '.jpg']));
    imwrite(flipud(this_roi),fullfile(pwd,'ROIs',[num2str(j) '.jpg']));
    
    s = regionprops(flipud(this_roi)>0,'BoundingBox');

    write_to_xml(s,j,this_roi)
    j=j+1;
    
    this_img_adj = imadjust(this_img);
    
    imwrite(this_img_adj,fullfile(pwd,'images',[num2str(j) '.jpg']));
    imwrite(this_roi,fullfile(pwd,'ROIs',[num2str(j) '.jpg']));
    
    s = regionprops(this_roi>0,'BoundingBox');

    write_to_xml(s,j,this_roi)
    j=j+1;
    
    
end


function write_to_xml(s,j,this_roi)
fileID = fopen(fullfile(pwd,'annotations',[num2str(j) '.txt']),'w');
fprintf(fileID,'%s',"<annotation>");
fprintf(fileID,'\n\t%s',"<folder>images</folder>");

f_name = string(['<filename>' num2str(j) '.jpg</filename>']);
fprintf(fileID,'\n\t%s',f_name);

f_path = string(['<path>' fullfile(pwd,'images',[num2str(j) '.jpg']) '</path>']);
fprintf(fileID,'\n\t%s',f_path);

fprintf(fileID,'\n\t%s',"<source>");
fprintf(fileID,'\n\t\t%s',"<database>Unknown</database>");
fprintf(fileID,'\n\t%s',"</source>");

fprintf(fileID,'\n\t%s',"<size>");
[h,w] = size(this_roi);
f_width = string(['<width>' num2str(w) '</width>']);
f_height = string(['<height>' num2str(h) '</height>']);
fprintf(fileID,'\n\t\t%s',f_width);
fprintf(fileID,'\n\t\t%s',f_height);
fprintf(fileID,'\n\t\t%s',"<depth>1</depth>");
fprintf(fileID,'\n\t%s',"</size>");

fprintf(fileID,'\n\t%s',"<segmented>0</segmented>");

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

movefile(fullfile(pwd,'annotations',[num2str(j) '.txt']),fullfile(pwd,'annotations',[num2str(j) '.xml']));

end
