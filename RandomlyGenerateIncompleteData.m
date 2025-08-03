%% �ο�CVPR2022-IMVC-CBG ���ɲ���������ͼ���ݣ�ÿ����ͼ�������������������1��ʾ���ڣ�0��ʾȱ��
%% ������ͼ���������� data( d*N������������ͼ����ΪNan) ��  ������ͼȱ���������� folds��ʾȱ�����ʾ����� N*v ��1��ʾ���ڣ�0��ʾȱ��
%% ȱ��ȼ��㷽����  ����1����ͼ�ǲ��������������� /  ������������  �����ּ��㷽����PIMVC�ǲ�һ���ģ��÷���Ҫ��ÿ����ͼ��ȱ������ͬ�� 

%% code by xinxin 10/01/2024
%% data: dv*n (NaN for missing column);   index: nv* n_view (index of exist instances for each view)


clc;
close all;
clear;
currentFolder = pwd;
addpath(genpath(currentFolder));
resultdir = '/home/viplab/Desktop/MyIncompleteData/';
datadir='/home/viplab/Desktop/MyIncompleteData/';
dataname = {'Caltech101-7','BDGP_fea','handwritten-5view','bbcsport4vbigRnSp','YoutubeFace_sel_fea','Animal','3Sources','NGs'};
n_dataset = length(dataname); % number of the datasets

for idata = 2
    % read dataset
    dataset_file = [datadir, cell2mat(dataname(idata)),'.mat'];
    load(dataset_file);
%    X = fea;
 %   Y = truth;     % for bbcsport4vbigRnSp
    V = length(X);  % the number of views
    oriData = cell(V,1);
    oriTruelabel = cell(V,1);

    for v = 1:V
        oriData{v} = X{v}';      % for Caltech7, Caltech20, BDGP, 
        %oriData{v} = X{v};      % for handwritten-5view;  bbcsport4vbigRnSp
        oriTruelabel{v} = Y;
    end

    clear X gt;
    N = size(oriData{1},2); % the number of instances
    n_view = length(oriData);
    perGrid = [0.1:0.1:0.9]; %  the percentage of paired instances  ��ͼ���������������ı���
    
    misingExampleVector = randperm(N);  %% �����������
    MissingStatus = zeros(N, n_view); % indicate the missing status of instance in each view (�������ȱ�������Ҫ��ÿ���������ٴ���1����ͼ������ȫ��ȱ�𣩣���Ҫ��֤��ͼ�ǲ������ģ������������ģ�)
    for id = 1:N
        missingViewVector = randi([0, 1], n_view, 1, 'int8');
        while(0 == sum(missingViewVector) || n_view == sum(missingViewVector))
            % in case of all views mising
            missingViewVector = randi([0,1], n_view,1, 'int8');
        end
        MissingStatus(id, :) = missingViewVector;
    end
    
    for per_iter = 1:length(perGrid)   %% ���� ��ͼȱ����������0.1-0.9�������������
        per = perGrid(per_iter); % partial example ratio  ��ͼ���������������ı���
        miss_n = fix((per)*N); % the number of missing instances
        
        perMisingExampleVector = misingExampleVector(1: miss_n);
        data = oriData;
        full_index = cell(1,n_view);
        for v = 1:n_view
            full_index{v} = zeros(N,1); %% ��ʼ��Ϊȫ0
        end
        for id = 1: miss_n
            for j = 1 : n_view
                if 0 == MissingStatus(misingExampleVector(id), j)
                    data{j}(:,misingExampleVector(id)) = nan;    %% ��ȱ���������Ϊ Nan
                    full_index{j}(misingExampleVector(id)) = 1;  %%  random ��ÿ����ͼ��ȱ���������1
                end
            end
        end
        index = cell(1, n_view);
        for v = 1:n_view
            index{v} = find(full_index{v}==0);  %% �ҵ�ÿ����ͼ�д��ڵ������� ����
        end
        truelabel = oriTruelabel; 
        
        folds= zeros(N,n_view); %% ����ÿ����ͼ��������״̬��1��ʾ���ڣ�0��ʾȱ��
        for v = 1: n_view
           folds(index{v},v) = 1;    %% ���������������ڵ�������1
        end
        
        save([resultdir,char(dataname(idata)),'_Per',num2str(per),'.mat'],'data','truelabel','index','MissingStatus','folds');
        fprintf('%s finished_%f \n',cell2mat(dataname(idata)), per);
        clear data truelabel index;
    end
end
