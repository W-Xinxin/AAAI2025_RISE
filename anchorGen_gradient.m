function [ anchor, ind2, score ] = anchorGen_gradient(X, m )
% m : the number of anchors
% X ;  the input data n*dv
% coded by xinxin 2024/03/16   based on SFMC   xuelong Li , 
%% measure variation using gradient

[n,d] = size(X);
X1 = abs(gradient(X));  %% compute cosin similarity : a*b/|a|*|b|
score = sum(X1, 2);
score(:,1) = score/max(score);
[~,ind(1)] = max(score);
for i=2:m
   score(:,i) = score(:,i-1).*(ones(n,1)-score(:,i-1));
   score(:,i) = score(:,i)/max(score(:,i));
   [~,ind(i)] = max(score(:,i));
end
 ind2 = sort(ind,'ascend');
anchor = X(ind2,:);

% for i=1:4
% % idd=find(score(:,i)>0.98);
% % figure;
% % plot(X(:,1),X(:,2),'.b', 'MarkerSize', 10); hold on;
% % plot(X(idd,1),X(idd,2),'.r', 'MarkerSize', 10); hold on;
% figure; plot(score(:,i),'-o');
% % axis equal;
% set(gcf,'Position',[400,100,700,600],'color','w');
% set(gca,'fontsize',16);
% set(gca,'linewidth',0.8);
% % saveas(gcf,strcat('C:\Users\opt\Desktop\mydisk\ongoing\Fast multiview CLR\Latex_revised2\response\s',num2str(i),'.pdf'));
% end


% id=zeros(1,m);
% for i=1:m
%     if ind(i)<=200
%         id(i)=1;
%     elseif ind(i)<=400
%         id(i)=2;
%     else
%         id(i)=3;
%     end
% end
end
