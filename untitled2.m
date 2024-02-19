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

% Inisialisasi variabel baru dengan zeros
selectedData = zeros(80, 3);

% Mengambil 80 baris pertama dari kolom x, y, dan id
selectedData(:, 1) = data.x(1:80);
selectedData(:, 2) = data.y(1:80);

% Mengambil angka setelah karakter 'f_'
id = str2double(extractAfter(data.id(1:80), 'f_'));

% Mengisi kolom ketiga dari newVariable dengan data numerik
selectedData(:, 3) = id;

% Inisialisasi indeks t
t = 1;

% Inisialisasi data
data.x = [1, 2, 4, 7]; % contoh data x
data.y = [3, 5, 1, 8]; % contoh data y

% Perhitungan jarak (d) menggunakan rumus yang diberikan
t = 2; % misalnya, kita ingin menghitung jarak pada waktu t=2
d = sqrt((data.x(t) - data.x(t-1))^2 + (data.y(t) - data.y(t-1))^2);

% Menampilkan hasil
fprintf('Jarak pada waktu t=%d adalah %.2f\n', t, d);