%% to form the uniform data
%% X: dv *n , Y: n*1 ;
%% coded by xinxin  23/01/2024
clc;
close all;
clear;
currentFolder = pwd;
addpath(genpath(currentFolder));
resultdir = '/home/viplab/Desktop/MyIncompleteData/';
datadir='/home/viplab/Desktop/MyIncompleteData/';

dataname = {'Caltech101-7','BDGP_fea','handwritten-5view','bbcsport4vbigRnSp'};
n_dataset = length(dataname); % number of the datasets
% for idata = 1:n_dataset-(n_dataset-1)
for idata = 4
    % read dataset
    dataset_file = [datadir, cell2mat(dataname(idata)),'.mat'];
    load(dataset_file);
%     X = fea;
    Y = truth;   % for bbcsport4vbigRnSp
    V = length(X); % the number of views

    oriData = X;
    X =cell(V,1);

    for v = 1:V
        %X{v} = oriData{v}';  % for Caltech7, Caltech20, BDGP, 
        X{v} = oriData{v};  % for handwritten-5view 
    end

    %save([resultdir,char(dataname(idata)),'.mat'],'categories','cateset','X','Y','feanames','lenSmp'); %for Caltech101-7
    %save([resultdir,char(dataname(idata)),'.mat'],'class_meaning','view_meaning','X','Y'); %for BDGP_fea
    save([resultdir,char(dataname(idata)),'.mat'],'X','Y'); % for handwritten-5view
    fprintf('%s finished \n',cell2mat(dataname(idata)));

end