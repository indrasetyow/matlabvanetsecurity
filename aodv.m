filename = 'Hsimulasi.xlsx';
sheet = 'Sheet2';
data = readtable(filename, 'Sheet', sheet);

t = data.time;
x = data.x;
y = data.y;
l = data.lane;
p = data.type;
a = data.angle;
s = data.speed;
r = data.id;

K = 30; % Konstanta berbeda setiap lingkungan

start1 = 1;

%figure; % Membuat figure baru

Data_t = unique(t);
Data_p = unique(p);
Data_l = unique(l); 

% Memasukkan data ke dalam variabel xi, yi, id, dan t
xi = x; 
yi = y;
id = r;
ti = t;

% Menggabungkan data ke dalam satu tabel
data_table = table(ti, id, xi, yi, 'VariableNames', {'t', 'id', 'xi', 'yi'});

% Sel untuk menyimpan data pada setiap waktu
selectedDataCell = cell(0, 100); % Sesuaikan dengan jumlah waktu yang diinginkan, misalnya, 100

% Iterasi untuk setiap nilai t dari 0 hingga 100
for t = 0:100
    % Mencari data yang sesuai dengan nilai t pada tabel
    data_t = data_table(data_table.t == t, :);

%     % Inisialisasi matriks zeros dengan ukuran sesuai jumlah baris di data
%     selectedData = zeros(height(data_table), 3);

    % Inisialisasi matriks zeros dengan ukuran sesuai jumlah baris di data
    selectedData = zeros(1, 3);

    % Mengisi matriks dengan nilai dari kolom id, xi, dan yi ketika t = 0 atau t = 1
    if ~isempty(data_t)
        % Jika t bukan 0, pindahkan data ke baris pertama
        if t > 0
            selectedData(1:size(data_t, 1), :) = [str2double(strrep(data_t.id, 'f_', '')), data_t.xi, data_t.yi];
        else
            selectedData(data_table.t == t, :) = [str2double(strrep(data_t.id, 'f_', '')), data_t.xi, data_t.yi];
        end
    end
    
    % Menetapkan nilai 0 untuk baris berikutnya setelah t sekian
    selectedData(data_table.t > t, :) = 0;

    % Menyimpan hasil pada sel yang sesuai dengan nilai t
    selectedDataCell = selectedData;
end

% Menghitung d polinomial
d =  t .* (t - 1) / 2;

% Menghitung min_d1
min_d1 = zeros(size(selectedData, 1), 1);
for i = 2:size(selectedData, 1)
    min_d1(i) = sqrt((selectedData(i, 2) - selectedData(i-1, 2))^2 + (selectedData(i, 3) - selectedData(i-1, 3))^2);
end


% % Menggabungkan data ke dalam satu tabel
% data_table = table(ti, id, xi, yi, 'VariableNames', {'t', 'id', 'xi', 'yi'});
% 
% % Sel untuk menyimpan data pada setiap waktu
% selectedDataCell = cell(0, 100); % Sesuaikan dengan jumlah waktu yang diinginkan, misalnya, 100
% 
% % Iterasi untuk setiap nilai t dari 0 hingga 100
% for t = 0:100
%     % Mencari data yang sesuai dengan nilai t pada tabel
%     data_t = data_table(data_table.t == t, :);
% 
%     % Inisialisasi matriks zeros dengan ukuran sesuai jumlah baris di data
%     selectedData = zeros(height(data_table), 3);
% 
%     % Mengisi matriks dengan nilai dari kolom id, xi, dan yi ketika t = 0 atau t = 1
%     if ~isempty(data_t)
%         % Jika t bukan 0, pindahkan data ke baris pertama
%         if t > 0
%             selectedData(1:size(data_t, 1), :) = [str2double(strrep(data_t.id, 'f_', '')), data_t.xi, data_t.yi];
%         else
%             selectedData(data_table.t == t, :) = [str2double(strrep(data_t.id, 'f_', '')), data_t.xi, data_t.yi];
%         end
%     end
% 
%     % Menetapkan nilai 0 untuk baris berikutnya setelah t sekian
%     selectedData(data_table.t > t, :) = 0;
% 
%     % Menyimpan hasil pada sel yang sesuai dengan nilai t
%     selectedDataCell{t + 1} = selectedData;
% end



% %Code : AODV Routing.
% x=1:20;
% s1=x(1);
% d1=x(20);
% clc;
% A=rand(20);
% % Making matrix all diagonals=0 and A(i,j)=A(j,i),i.e. A(1,4)=a(4,1),
% % A(6,7)=A(7,6)
% for i=1:20
%         for j=1:20
%                 if i==j
%                     A(i,j)=0;
%                 else
%                     A(j,i)=A(i,j);
%                 end
%         end
% end
% disp(A);
% t=1:20;
% disp(t);
%  
%  disp(A);
%  status(1)='!';
% % dist(1)=0;
% dist(2)=0;
%  next(1)=0;
%  
%  for i=2:20
%     
%      status(i)='?';
%      dist(i)=A(i,1);
%      next(i)=1;
%    disp(['i== ' num2str(i) ' A(i,1)=' num2str(A(i,1)) ' status:=' status(i) ' dist(i)=' num2str(dist(i))]);
%  end
%  
%  flag=0;
%  for i=2:20
%         if A(1,i)==1
%             disp([' node 1 sends RREQ to node ' num2str(i)])
%                 if i==20 && A(1,i)==1
%                        flag=1;
%                 end
%         end
%  end
%  disp(['Flag= ' num2str(flag)]);
%  while(1)
%      
%     if flag==1
%             break;
%     end
%     
%     temp=0;
%     for i=1:20
%         if status(i)=='?'
%             min=dist(i);
%             vert=i;
%             break;
%         end
%     end
%     
%     for i=1:20
%         if min>dist(i) && status(i)=='?'
%             min=dist(i);
%             vert=i;
%         end
%     end
%     status(vert)='!';
%     
%     for i=1:20
%         if status()=='!'
%             temp=temp+1;
%         end
%     end
%     
%     if temp==20
%         break;
%     end
%  end
%   
%  i=20;
%  count=1;
%  route(count)=20;
%  
%  while next(i) ~=1
%      disp([' Node ' num2str(i) 'sends RREP message to node ' num2str(next(i))])
%      i=next(i);
%      %disp(i);
%      count=count+1;
%      route(count)=i;
%      route(count)=i;
%  end
%  
%  disp([ ' Node ' num2str(i) 'sends RREP to node 1'])
%  disp(' Node 1 ')
%  for i=count: -1:1
%      disp([ ' Sends message to node ' num2str(route(i))])
%  end
%