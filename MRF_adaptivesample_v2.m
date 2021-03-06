m = 100;
n = 100;
radius = 40;
center = [50, 50];
true_X = ones(m,n) * -1;  % true value
for i = 1:m
   for j = 1:n
      if ( (i - center(1))^2 + (j - center(2))^2 < radius^2 ) 
          true_X(i,j) = 1;
      end 
   end    
end
% generate the picture
sigma = 1;
Y = true_X;
Y(2:m-1,2:n-1) = Y(2:m-1,2:n-1) + sigma * randn(m-2,n-2); % noise-corrupted observations;
X = randn(m,n) * sigma; % initial
X = sign(Y); % initial
J = 1e-0;
error_record = [];
weight = zeros((m-2)*(n-2),1);

%%%%% first scan is sequential scan. its target is to traverse all sampling variables to obtain a rough estimation about sampling probability.
for j = 2:m-1
    for k = 2:n-1 
         prev_X = X(i,k);
         neighbor_sum = X(j-1,k) + X(j+1,k) + X(j,k-1) + X(j,k+1);  % core: sum of its neighbors.
         X(j,k) = Y(j,k) + J * neighbor_sum + sigma * randn();  % core: sampling X_{jk} from conditional distribution.
         %weight( (j-2)*(n-2) + k-1 ) = abs(X(j,k) - prev_X); % || X_{new} - X_{old} ||
         X(j,k) = sign(X(j,k));  % core: binarization
         weight( (j-2)*(n-2) + k-1 ) = abs(X(j,k) - prev_X);
    end
    err = (norm(X-true_X,'fro'))/norm(true_X,'fro');
    error_record = [error_record,err];
end
%%%%% first scan is sequential scan.




lambda = 0.5;
weight1 = weight + lambda ; %  avoid zero division
weight_normal = (weight1) / sum(weight1);
iter = 4;
for i = 1:iter
    weight1 = weight + lambda ; %  update weight every m*n updates
    weight_normal = (weight1) / sum(weight1);
   for jj = 2:m-1
       p = randsample(1:(m-2)*(n-2),n-2,true,weight_normal); % importance sampling
       for kk = 1:n-2
          index = p(kk);
          j = floor((index-1) / (n-2)) + 2;
          k = index - (j-2) * (n-2) + 1;
          prev_X = X(j,k);
          neighbor_sum = X(j-1,k) + X(j+1,k) + X(j,k-1) + X(j,k+1);
          X(j,k) = Y(j,k) + J * neighbor_sum + sigma * randn();
          X(j,k) = sign(X(j,k));
          weight(index) = abs(X(j,k) - prev_X);  % re-estimate the weight
       end
       err = (norm(X-true_X,'fro'))/norm(true_X,'fro');
       error_record = [error_record,err];
   end   
    
end
 plot(error_record);


