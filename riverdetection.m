clear all;
close all;
clc;
tic
I=imread('data229.tif');
GT=im2bw(imread('GT229.jpg'));
if size(I,3)==3
I=rgb2gray(I);
else
    I=I;

end
%figure,imshow(I)
%% acquire ground truth,when run the algorithm,comment this part
% figure,imshow(I,[])
% h = drawfreehand;
% Mask1 = createMask(h);
% figure,imshow(I,[])
% h = drawfreehand;
% Mask2 = createMask(h);
% % figure,imshow(I,[])
% % h = drawfreehand;
% % Mask3 = createMask(h);
% % Mask=Mask1-Mask2+Mask3;
% GT = activecontour(I,Mask1,80);
% figure,imshow(GT)
% imwrite(GT,'GT435.jpg');
%%

I1=double(I).^0.67;
% I1=I;
% figure,imshow(I1,[],'border','tight')
I1=imfilter(I1,fspecial('gaussian',12,2),'replicate');
% figure,imshow(I1,[],'border','tight')
% tic
temp=FrangiFilter2D(double(I1));%river enhancement
% figure,imshow(temp,[],'border','tight')
shearletSystem = SLgetShearletSystem2D(0, size(temp,1), size(temp,2), 2);
 coeffs = SLsheardec2D(temp, shearletSystem );
 %%
 for i=1:16
%      for i=1:8
coeffs(:,:,i)=(coeffs(:,:,i)-(min(min(coeffs(:,:,i)))))./(max(max(coeffs(:,:,i)))-min(min(coeffs(:,:,i))));%normalization
 end

 for i=1:5
     cc(:,:,i)=coeffs(:,:,i);
 end
 for i=1:3
     cc(:,:,i+5)=coeffs(:,:,i+10);
 end
 for i=1:5
     cc(:,:,i+8)=coeffs(:,:,i+5);
 end
 for i=1:3
     cc(:,:,i+13)=coeffs(:,:,i+13);
 end
% for i=1:3
%     cc(:,:,i)=coeffs(:,:,i);
% end
% cc(:,:,4)=coeffs(:,:,7);
% for i=1:3
%     cc(:,:,i+4)=coeffs(:,:,i+3);
% end
% cc(:,:,8)=coeffs(:,:,8);
 %%
for i=1:16
    d(i)=std(std(cc(:,:,i)));
end
[temp idx1]=sort(d(1:8),'descend');
[temp idx2]=sort(d(9:16),'descend');
for i=1:8
    idx2(i)=idx2(i)+8;
end
for i=1:4
    num(i)=idx1(i);
end
for i=1:4
    num(i+4)=idx2(i);
end
% for i=1:8
%     d(i)=std(std(cc(:,:,i)));
% end
% 
% [temp idx]=sort(d,'descend');
% re=cc(:,:,2)+cc(:,:,3)+cc(:,:,4);+cc(:,:,7);
 %%
 re=zeros();
 for i=1:length(num)
     j=num(i);
     re=re+cc(:,:,j);
 end
% re=coeffs(:,:,1)+coeffs(:,:,2)+coeffs(:,:,3)+coeffs(:,:,13)+coeffs(:,:,6)+coeffs(:,:,7)+coeffs(:,:,8)+coeffs(:,:,16);

% out=re+abs(min(min(re)));
out=(re-min(min(re)))./(max(max(re))-min(min(re)));
%  figure,imshow(out,[],'border','tight')
 
%  Th=0.5:0.01:0.9;
 
%  T=mean(mean(out))+Th(j)*std(std(out));
% T=Th(j);
% for j=1:length(Th)
a=activecontour(I,im2bw(out,0.55));
% a=im2bw(out,T);

    result0=a;

%  figure,imshow(a,[],'border','tight')
 result1=bwareaopen(result0,150);
%  figure,imshow(result1,'border','tight')
% % result1=a;
[L,num] = bwlabel(result1);
long=regionprops(L,'MajorAxisLength');
short=regionprops(L,'MinorAxisLength');
for i=1:num
  longv=long(i).MajorAxisLength;
  shortv=short(i).MinorAxisLength;
    ratio(i)=longv/shortv;
end   

ac=zeros(size(result1,1),size(result1,2));
for i=1:length(ratio)
    if ((ratio(i))>2) 
        
        [row ,col]=find(L==i);
       ac(min(row):max(row),min(col):max(col))=result1(min(row):max(row),min(col):max(col));
       
    else
        [row ,col]=find(L==i);
        ac(min(row):max(row),min(col):max(col))=0;
    end
end
toc
% figure,imshow(ac,'border','tight')
f2=ac;
%%
%  T2=im2bw(out,0.5*max(max(out)));
% T=mean(mean(out))+10*std(std(out));
%  T2=im2bw(out,T);
% % mask=bwareaopen(T2,35);
% mask=T2;
%  result0=activecontour(I1,mask);
%  
% %  figure,imshow(result0)
%  result1=bwareaopen(result0,50);
%  toc
%  figure,imshow(result1)
% [L,num] = bwlabel(result1);
% toc
% figure,
% for i=1:num
%     imshow(L==i)
%     pause
% end
% %%
% result2=(L==1)+(L==4);
%  figure,imshow(result2,'border','tight')
% %  lr=bwlabel(result);% A32二值化图
% % rgb=label2rgb(lr,'lines','k');% 二值化图染色
% % figure,imshow(rgb)
% % Argb(:,:,1)=I1;Argb(:,:,2)=I1;Argb(:,:,3)=I1;% 灰度图转换成彩色图，不改变灰度图
% % figure,imshow(uint8(Argb)+rgb)
%% evaluation
% [m n]=size(GT);
% tp=sum(sum(GT.*f2));
% fn=sum(sum(GT))-tp;
% fp=sum(sum(f2))-tp;
% tn=m*n-tp-fn-fp;
% acc=(tp+tn)/(m*n);
% recall=tp/(tp+fn);
% pre=tp/(tp+fp);
% fpr=fp/(tn+fp);
% po=acc;
% pe=((tp+fn)*(tp+fp)+(fp+tn)*(fn+tn))/((m*n).^2);
% k=(po-pe)/(1-pe);
% FPR(j)=fpr;
% TPR(j)=recall;
% PRE(j)=pre;
% REC(j)=recall;
% K(j)=k;
% end
%  FPR=(FPR-min(FPR))./(max(FPR)-min(FPR));
%   TPR=(TPR-min(TPR))./(max(TPR)-min(TPR));
%    PRE=(PRE-min(PRE))./(max(PRE)-min(PRE));
%    
%  AUC=trapz(FPR,TPR);
% AUCPR=trapz(REC,PRE);
% figure,plot(FPR,TPR)
% % figure,plot(PRE,REC)
% mean(K)