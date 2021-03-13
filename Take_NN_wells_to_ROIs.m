csv_path = "C:\Users\Lab PC\Documents\pytorch_testing\results";
csv_dir = dir(fullfile(csv_path,'*.csv'));

imgs_path = "C:\Users\Lab PC\Documents\pytorch_testing\testing_img";
imgs_dir = dir(fullfile(imgs_path,'*.png'));

se = strel('disk',5);
for i = 1:length(imgs_dir)
    
    this_img = imread(fullfile(imgs_dir(i).folder,imgs_dir(i).name));
    
    figure;
    imshow(this_img)
    
    this_result = table2array(readtable(fullfile(csv_dir(i).folder,csv_dir(i).name)));
    this_data = this_result(:,1:4);
    
    hold on 
    plot(this_data(:,1),this_data(:,2),'r*')
    for j = 1:length(this_data)
        
        rect_coords = [this_data(j,1)-(this_data(j,3)/2), this_data(j,2)-(this_data(j,4)/2), 205, 205];
        
        rectangle('Position', rect_coords,...
            'EdgeColor', 'b', 'FaceColor', 'none', 'LineWidth', 2);
    end
    hold off
    
end

