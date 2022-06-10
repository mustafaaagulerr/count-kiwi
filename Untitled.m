clc;    % Komut penceresini temizleyin.
close all;  % Tüm rakamları kapatın (imtool'unkiler hariç.)
clearvars;
workspace;  % Çalışma alanı panelinin gösterildiğinden emin olun.
format long g;
format compact;
fontSize = 16;
fprintf('Beginning to run %s.m ...\n', mfilename);
 
% Görseli okumak
folder = [];
baseFileName = 'kiwi.jpg';
fullFileName = fullfile(folder, baseFileName);
 
 % Dosyanın var olup olmadığını kontrol edin.
if ~exist(fullFileName, 'file')
    fullFileNameOnSearchPath = baseFileName; % No path this time.
    if ~exist(fullFileNameOnSearchPath, 'file')
        % hata bulundu.
        errorMessage = sprintf('Hata: %s arama yolu klasöründe yok.', fullFileName);
        uiwait(warndlg(errorMessage));
        return;
    end
end
rgbImage = imread(fullFileName);
[rows, columns, numberOfColorChannels] = size(rgbImage)
 
 
% Test görüntüsünü tam boyutta görüntüleyin.
subplot(2, 2, 1);
imshow(rgbImage, []);
axis('on', 'image');
caption = sprintf('Orjinal Resim : "%s"', baseFileName);
title(caption);
drawnow;
 
[mask, maskedRGBImage] = createMask(rgbImage);
 
% Maske görüntüsünü göster
subplot(2, 2, 2);
imshow(mask, []);
axis('on', 'image');
title('İlk Renk Segmentasyon Maskesi');
drawnow;
hold on;
 
% Kivi maskeli görüntüsünü göster
subplot(2, 2, 3);
imshow(maskedRGBImage, []);
axis('on', 'image');
title('İlk Renk Segmentasyon Maskesi');
drawnow;
hold on;
 
% Yaprakların ve gökyüzünün maskelenmiş görüntüsünü göster
leaves = bsxfun(@times, rgbImage, cast(~mask, 'like', rgbImage));
subplot(2, 2, 4);
imshow(leaves, []);
axis('on', 'image');
title('Yapraklar ve Gökyüzü');
drawnow;
hold on;
fprintf('Done running %s.m\n', mfilename);
 
%sayım
RGB2 = imread('kiwi.jpg');
cform = makecform('srgb2lab');
lab_he = applycform(RGB2,cform);
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx, cluster_center]=kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);
imshow(pixel_labels,[]);
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
for k = 1:nColors
 color = RGB2;
 color(rgb_label ~= k) = 0;
 segmented_images{k} = color;
end
imshow(segmented_images{2}), title('objects in cluster 2');
sekil = segmented_images{2};
hy=fspecial('sobel');
hx=hy;
Iy=imfilter(double(sekil),hy,'replicate');
Ix=imfilter(double(sekil),hx,'replicate');
gradmag=sqrt(Ix.^6+Iy.^6);
figure, imshow(gradmag);
imwrite(gradmag,'sekil.jpg');
sekil1 = imread("sekil.jpg");
se=strel('ball',17,6);
Io=imopen(sekil1,se);
figure, imshow(Io);
r = Io(:, :, 1);
g = Io(:, :, 2);
b = Io(:, :, 3);
justGreen = g;
bw = justGreen > 50;
imagesc(bw);
colormap(gray);
% bw = justGreen > 10;
% imagesc(bw);
% colormap(gray);
bw = imfill(bw,'holes');
SE =strel('disk', 20);   
bw2 = imerode(bw,SE);
[L,num] = bwlabel(bw2); 
display(num)

function [BW,maskedRGBImage] = createMask(RGB)
% RGB görüntüsünü seçilen renk uzayına dönüştürme
I = rgb2lab(RGB);
% Histogram ayarlarına bağlı olarak kanal bir için eşik tanımlama
channel1Min = 1.176;
channel1Max = 79.447;
% Histogram ayarlarına bağlı olarak kanal iki için eşik tanımlama
channel2Min = -4.567;
channel2Max = 31.611;
% Histogram ayarlarına bağlı olarak kanal üç için eşik tanımlama
channel3Min = -5.773;
channel3Max = 70.934;
% Seçilen histogram eşiklerine göre maske oluşturmak
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;
% girdi görüntüsüne göre çıkıyı başlama.
maskedRGBImage = RGB;
% bw'nin yanlış olduğu arka plan piksellerini sıfırlamak
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;
end