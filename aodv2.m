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
% r = str2double(strrep(data.id, 'f_', ''));

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
    selectedDataCell = cell(1, 100); % Sesuaikan dengan jumlah waktu yang diinginkan, misalnya, 100
    selectedData = zeros(size(data, 1), 3);

    % Iterasi untuk setiap nilai t dari 0 hingga 100
    for t = 0:100
        % Mencari data yang sesuai dengan nilai t pada tabel
        data_t = data_table(data_table.t == t, :);
    
    %     % Inisialisasi matriks zeros dengan ukuran sesuai jumlah baris di data
    %     selectedData = zeros(height(data_table), 3);
    
        % Inisialisasi matriks zeros dengan ukuran sesuai jumlah baris di data
    
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
        selectedDataCell{1, t + 1} = selectedData;

    end
    
    % Menghitung d polinomial
    d =  t .* (t - 1) / 2;
    
    % Menghitung min_d1
    min_d1 = zeros(size(selectedData, 1), 1);
    for i = 2:size(selectedData, 1)
        min_d1(i) = sqrt((selectedData(i, 2) - selectedData(i-1, 2))^2 + (selectedData(i, 3) - selectedData(i-1, 3))^2);
    end
