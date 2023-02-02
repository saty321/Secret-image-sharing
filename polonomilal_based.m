clear all
close all

s="enter the value n for making maximum share from image  ";
n=input(s);
s="enter the vlaue k for construction of image  ";
k = input(s);

img_mat = imread("C:\Users\ajsat\OneDrive\Desktop\image_processing\Cammeraman.png");
[rows,cols] = size(img_mat);  %size     of image
num_of_img_mat_ele = rows*cols;      %total number of element in matrix

subshare = zeros(rows,cols/2,n);

P = 65537; % prime number
temp1 = zeros(rows,cols/2);

 % Sharing Phase start
count=0;
for i=1:rows
j=1;
while j <= cols
    
    pixel1bin=dec2bin( img_mat(i,j),8);
    pixel2bin=dec2bin( img_mat(i,j+1),8);
    pixelbin=strcat(pixel1bin,pixel2bin);
    newpixel=bin2dec(pixelbin);
    temp1(i,(j+1)/2)=newpixel;

    random = zeros(1,k-1);
    for ii=1:k-1
        random(ii) = randi([0,255]);
    end

    for snum=1:n
     
        val = mod( newpixel + find_poly_val(snum,k,random) , P );

        if val == P-1 % P-1 = 65536
        % s="yes" 
        count=count+1;
          break
        end

        subshare(i,(j+1)/2,snum) = val;

    end

    if val ~= P-1
        j = j + 2;
    end

end
end

% Sharing Phase has done 




% Reconstruction Phase start:

temp2 = zeros(rows,cols/2);
for ri=1:256
    for rj=1:128
        sum = 0;
        for si=1:k
             sum = sum + get_val_of_langrange(si,k,subshare(ri,rj,si));
        end
         sum = mod(sum,P);
         if sum < 0  
             sum = sum + P;
         end

        temp2(ri,rj)=sum;
    end
end



res_img=zeros(rows,cols);

for ri=1:rows
    rj=1;
   while rj <= 256
     pixel_temp2 = temp2(ri,(rj+1)/2);
     binstr = dec2bin(pixel_temp2,16);
     pixel1str = extractBefore(binstr,9);
     pixel2str = extractAfter(binstr,8);
     first_pixel = bin2dec(pixel1str);
     second_pixel = bin2dec(pixel2str);

     res_img(ri,rj)=first_pixel;
     res_img(ri,rj+1)=second_pixel;

     rj=rj+2;
    end
end

% Reconstruction Phase has done

% original input image
figure(1)
imshow(img_mat)


% N Share image
figure(2)
for j=1:n
    subplot(1,n,j);imshow(mat2gray(subshare(:,:,j)))
end

% reconstruction image
figure, imshow(mat2gray(res_img))

% function for finding a1(x) + a2(x^2) + ......... + a(k-1)(x^(k-1));

function [res] = find_poly_val(xval,k,random)
x=xval;
res=0;
for i=1:k-1
    res=res + random(i)*x;
    x=x*xval;
end
end

% function for finding langrange value(secret pixel)  using  y1, y2, ......, yn so that we can find ao ;
function [res] = get_val_of_langrange(pi,k,y)
     u=1;
     d=1;

   for ii=1:k
    if(ii ~= pi)
        u=u*(-ii);
        d=d*(pi-ii);
    end
   end
       res=floor((y*u)/d);
end

