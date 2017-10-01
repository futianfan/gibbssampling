randn('seed',3); % 2

% begin generate data.
d = 10; % dimension
N = 3000;
K = 3; % 2,3
scale = 100;
scale2 = 1;
centroid = randn(d,K);
centroid = centroid ./ (ones(d,1) * sqrt(sum(centroid.^2,1))); % 10 * 4   with unit norm.
centroid = centroid * scale;
prob_record = [];
X = scale2 * randn(d,N);
for i = 1:K
    X(:,(N/4)*(i-1)+1:(N/4)*i) = X(:,(N/4)*(i-1)+1:(N/4)*i) + centroid(:,i) * ones(1,N/4);        
end

% outliers
outlier_num = 3;
X(:,1:outlier_num) = randn(d,outlier_num) * scale2;

% end generate data.

Z = zeros(N); % assignment
C = ones(1,K) * 1/K;
mu = randn(d,K);
Sigma = zeros(K,d,d);
for i = 1:K
   Sigma(i,:,:) = eye(d); 
end
iter = 30;
tmp = zeros(1,K); 

for ii = 1:iter
    iter_count = ii   
    % update Z
    if (ii == 1)
       % random assignment 
       for i = 1:N
            Z(i) = unidrnd(K); 
       end 
    else
       prob = 0 ;     % compute sum of log-probability
       for i = 1:N
            for j = 1:K
               tmp(j) = C(j) * det(reshape(Sigma(j,:,:),d,d))^(-1/2) ...
                   * exp(-1/2 * (X(:,i) - mu(:,j))' * inv(reshape(Sigma(j,:,:),d,d)) * (X(:,i) - mu(:,j)));
            end
            prob = prob + log(sum(tmp));
            tmp = tmp ./ sum(tmp);
            z = randsample(1:K,1,true,tmp); % dirichlet
            Z(i) = z;
       end     
       prob       % compute sum of log-probability
       prob_record = [prob_record, prob];
    end
 
    
    % update C, mu, Sigma
    for i = 1:K
        c_i = find(Z == i);
        C(i) = length(c_i);    % update C
        mu(:,i) = mean(X(:,c_i),2);    % update mu
        Sigma(i,:,:) = (X(:,c_i) - mu(:,i) * ones(1,C(i))) * (X(:,c_i) - mu(:,i) * ones(1,C(i)))' / C(i);
%         a = svd(reshape(Sigma(i,:,:),d,d));
%         a(1)/a(d)
    end
    C = C ./ sum(C);
    
    

end
plot(prob_record)
% for i = 1:K
%    a =  svd(reshape(Sigma(i,:,:),d,d));
%    a(1)/a(d)
% end
