filedir = 'forPCA/';
filename1 = 'PCA_neutral_clean.ply';
filename2 = 'PCA_frown.ply';
filename3 = 'PCA_3.ply';
filename4 = 'PCA_4.ply';
filename5 = 'PCA_5.ply';
filename6 = 'PCA_6.ply';


pc1 = pcread(strcat(filedir, filename1));
pc2 = pcread(strcat(filedir, filename2));
pc3 = pcread(strcat(filedir, filename3));
pc4 = pcread(strcat(filedir, filename4));
pc5 = pcread(strcat(filedir, filename5));
pc6 = pcread(strcat(filedir, filename6));


tform2 = pcregistericp(pc2,pc1);
tform3 = pcregistericp(pc3,pc1);
tform4 = pcregistericp(pc4,pc1);
tform5 = pcregistericp(pc5,pc1);
tform6 = pcregistericp(pc6,pc1);

pca2 = pctransform(pc2,tform2);
pca3 = pctransform(pc3,tform3);
pca4 = pctransform(pc4,tform4);
pca5 = pctransform(pc5,tform5);
pca6 = pctransform(pc6,tform6);


pcwrite(pca2, strcat(filedir, 'pca2.ply'))
pcwrite(pca3, strcat(filedir, 'pca3.ply'))
pcwrite(pca4, strcat(filedir, 'pca4.ply'))
pcwrite(pca5, strcat(filedir, 'pca5.ply'))
pcwrite(pca6, strcat(filedir, 'pca6.ply'))


