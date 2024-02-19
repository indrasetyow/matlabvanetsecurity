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


% Maksimum iterasi yang diinginkan
maxIterations = height(data); 

% Inisialisasi tabel untuk menyimpan hasil
result = table('Size', [80, 5], ...
    'VariableTypes', {'double', 'double', 'string', 'double', 'double'}, ...
    'VariableNames', {'t', 'd', 'id', 'x', 'y'});

% Inisialisasi matriks untuk menyimpan jarak antar titik
jarakAntarTitik = zeros(maxIterations, maxIterations);

% while t <= 80 
% while t + 1 <= maxIterations && t <= 80
while t + 1 <= maxIterations 
    % Increment t
    t = t + 1;

    % Kalkulasi nilai d hanya untuk titik tertentu
    d = sqrt((data.x(t) - data.x(t- 1)).^2 + (data.y(t) - data.y(t- 1)).^2);

    % Menyimpan nilai t, d, id, x, dan y ke dalam result
    result.t(t) = data.time(t);
    result.d(t) = d;
    result.id{t} = data.id{t};
    result.x(t) = data.x(t);
    result.y(t) = data.y(t);

    % Menyimpan jarak antar titik ke dalam matriks
    jarakAntarTitik(t-1, t) = d;
    jarakAntarTitik(t, t-1) = d;

%     % Tambahkan kondisi untuk keluar dari loop
%     if t >= height(data)
%         break; 
%     end
end

% Inisialisasi variabel baru untuk menyimpan data
group = table('Size', [100, 1], ...
    'VariableTypes', {'cell'}, ...
    'VariableNames', {'Result'});
% Menggabungkan data t dan id menjadi data baru 'sequence' di tabel result
result.sequence = strcat(string(result.id), '_', string(result.t));

% Inisialisasi struktur untuk menyimpan jumlah kemunculan setiap ID pada setiap iterasi
id_counts = containers.Map('KeyType', 'char', 'ValueType', 'double');

% Membuat loop untuk mengecek setiap nilai t
for t = 1:max(result.t)
    % Mendapatkan ID yang muncul pada iterasi saat ini
    ids_current = unique(result.id(result.t == t));
    
    % Loop melalui setiap ID yang muncul pada iterasi saat ini
    for id_idx = 1:numel(ids_current)
        id = ids_current{id_idx};
        % Jika ID tidak ada dalam struktur id_counts, tambahkan dan atur nilai awalnya menjadi 0
        if ~isKey(id_counts, id)
            id_counts(id) = 0;
        end
        % Mendapatkan jumlah kemunculan ID pada iterasi sebelumnya
        count_prev = id_counts(id);
        
        % Mendapatkan indeks ID pada iterasi saat ini
        idx_current = find(strcmp(result.id, id) & result.t == t);
        
        % Memperbarui sequence untuk ID pada iterasi saat ini dengan indeks unik yang tepat
        for i = 1:numel(idx_current)
            result.sequence{idx_current(i)} = [id, '_', num2str(count_prev + i)];
        end
        
        % Mengupdate jumlah kemunculan ID
        id_counts(id) = count_prev + numel(idx_current);
    end
end
% Iterasi untuk t = 1 hingga 100
for t = 1:100
    % Mengambil data dengan nilai 't' sesuai iterasi
    resultTime = result(result.t == t, :);

    % Perhitungan nilai d
    if t > 1
        d = sqrt((data.x(t) - data.x(t-1)).^2 + (data.y(t) - data.y(t-1)).^2);
    else
        d = 0; 
    end
    
    % Jika data tidak mencapai 80 baris, tambahkan baris dengan nilai 0
    if size(resultTime, 1) < 80
        rowsTotal = 80 - size(resultTime, 1);
        rowsZero = array2table(zeros(rowsTotal, width(resultTime)), 'VariableNames', resultTime.Properties.VariableNames);
        resultTime = [resultTime; rowsZero];
    end

    % Simpan resultTime ke dalam group
    group.Result{t} = resultTime;

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx rowsTotal rowsZero;
end

% Iterasi untuk t = 1 hingga 100
for t = 1:100
    % Mengambil tabel dari dalam cell array
    resultTableTime = group.Result{t};

    % Menambahkan kolom warna ke dalam tabel hanya jika d > 0
    resultTableTime.color = cell(height(resultTableTime), 1);

    % Temukan indeks baris dengan nilai d terkecil dan terbesar
    minD = find(resultTableTime.d == min(resultTableTime.d(resultTableTime.d > 0)), 1, 'first');
    maxD = find(resultTableTime.d >= 300);

    % Berikan warna hijau untuk nilai d terkecil jika d > 0
    if ~isempty(minD)
        resultTableTime.color{minD} = 'green';
    end
    
%     % Berikan warna merah untuk nilai d terbesar jika d > 0
%     if ~isempty(maxD)
%         resultTableTime.color(maxD)= {'red'};
%     end
    
    % Isi nilai biru hanya untuk baris dengan nilai d sama dengan 0
    zeroDIdx = find(resultTableTime.d == 0);
    
    % Hapus node biru dengan nilai d = 0 dari hasil plot
    resultTableTime(zeroDIdx, :) = [];
    
    % Isi nilai biru untuk baris dengan nilai d tidak sama dengan 0 dan tidak memiliki warna
    nonZeroDIdx = find(resultTableTime.d > 0 & cellfun('isempty', resultTableTime.color));
    resultTableTime.color(nonZeroDIdx) = {'blue'};

    % Menyimpan indeks baris dengan nilai d terkecil sebagai Head Cluster (warna hijau)
    headClusterIdx = find(strcmp(resultTableTime.color, 'green'));
    if ~isempty(headClusterIdx)
        resultTableTime.color{headClusterIdx} = 'Head Cluster';
    end

    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.Result{t} = resultTableTime;

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx zeroDIdx;
    clear headClusterIdx maxD minD;
end

% Inisialisasi warna untuk plotting
% Inisialisasi warna untuk plotting
warna = {'blue', 'red', 'green', 'black', 'cyan', 'magenta', 'yellow', 'white'};

% Membuat satu figur
figure;

% Membuat plot untuk setiap nilai t dari 1 hingga 20
for t = 1:20
    % Mengambil tabel dari dalam cell array
    resultTableTime = group.Result{t};
    
    % Membuat plot (digunakan 'hold on' hanya pada iterasi pertama)
    if t == 1
        hold on;
    else
        % Membersihkan figur sebelum memplot iterasi berikutnya
        clf;
        hold on;
    end

    % Plot data dengan warna sesuai dengan kolom 'color'
    for i = 1:size(resultTableTime, 1)
        if strcmp(resultTableTime.color{i}, 'Head Cluster')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'X', 'Color', 'green', 'MarkerSize', 15, 'MarkerFaceColor', 'green', 'LineWidth', 1.5);
        elseif strcmp(resultTableTime.color{i}, 'blue')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 8, 'MarkerFaceColor', 'blue', 'LineWidth', 1);
%         elseif strcmp(resultTableTime.color{i}, 'red')
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'red', 'MarkerSize', 8, 'MarkerFaceColor', 'red', 'LineWidth', 1);
        else
            plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', warna{mod(i, length(warna)) + 1}, 'MarkerSize', 8, 'MarkerFaceColor', warna{mod(i, length(warna)) + 1}, 'LineWidth', 1);
        end
    end  

%     % Menambahkan garis yang menghubungkan node berdasarkan nilai d pada t saat ini
%     for i = 1:height(resultTableTime)-1
%         d = resultTableTime.d(i);
%         
%         % Hanya gambar garis jika nilai d kurang dari atau sama dengan 300
%         if d <= 300 && ~strcmp(resultTableTime.color{i}, 'red') && ~strcmp(resultTableTime.color{i+1}, 'red')
%             fprintf('Node %d to Node %d, d=%.2f\n', i, i+1, d);
%             % Tambahkan teks jarak jika diperlukan
% %             text((resultTableTime.x(i) + resultTableTime.x(i+1)) / 2, (resultTableTime.y(i) + resultTableTime.y(i+1)) / 2, sprintf('d=%.2f', d), 'Color', 'k', 'FontSize', 8);
%             plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'k--', 'LineWidth', 1);
%         end
%     end
    
    % Menambahkan garis yang menghubungkan node berdasarkan nilai d pada t saat ini
    for i = 1:size(resultTableTime, 1)-1
        d = resultTableTime.d(i);
        
        % Hanya gambar garis jika nilai d kurang dari atau sama dengan 300
        if d <= 300 
            plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
        else
            plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'r--', 'LineWidth', 1);
        end
    end
    
    % Menambahkan judul dan label pada plot
    title(['Plot Data untuk t = ' num2str(t)]);
    xlabel('X');
    ylabel('Y');
    grid on;
    axis([-50 350 -40 120]);

    % Scatter plot
%     scatter(resultTableTime.x, resultTableTime.y, 'MarkerEdgeColor', 'blue', 'Marker', 'o', 'MarkerFaceColor', 'none', 'LineWidth', 1.5);
    
    % Text plot
%     text(resultTableTime.x, resultTableTime.y, cellfun(@num2str, resultTableTime.color, 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

    % Menunggu sebentar agar perubahan posisi terlihat
    pause(1.0);
    
    hold off;
end
    


    % Inisialisasi variabel
numNodes = 500;
validDValues = zeros(numNodes, numNodes);

for i = 1:numNodes
    for j = 1:numNodes
        % Perhitungan jarak antar node i dan j
        validDValues(i, j) = sqrt((result.x(i) - result.x(j))^2 + (result.y(i) - result.y(j))^2);
    end
end

% Inisialisasi AODV
status = '!';
dist = inf(1, numNodes);
next = zeros(1, numNodes);

% Inisialisasi status, dist, dan next
for i = 1:numNodes
    if i == 1
        status(i) = '!';
        dist(i) = 0;
        next(i) = 0;
    else
        status(i) = '?';
        % Gunakan hasil perhitungan jarak dari tabel result
        dist(i) = result.d(i);
        next(i) = 1;
    end
end

% Inisialisasi variabel lainnya
flag = 0;
temp = 0;

% Set goalNode
goalNode = 1; % Sesuaikan dengan node tujuan

% Initialize variables to store ping information
pingResults = cell(numNodes, numNodes);

while flag ~= 1 && temp < numNodes
    temp = temp + 1; % Tambahkan iterasi

    % Pilih node dengan dist terkecil dan status '?'
    [minDist, vert] = min(dist(status == '?'));

    % Perbarui status
    status(vert) = '!';

    % Perbarui dist dan next untuk node tetangga
    for i = 1:numNodes
        if status(i) == '?' && dist(i) > dist(vert) + validDValues(vert, i)
            dist(i) = dist(vert) + validDValues(vert, i);
            next(i) = vert;

            % Log RREQ
            disp(['Node ' num2str(vert) ' sends RREQ message to node ' num2str(i)]);

            % Simulate reply or timeout based on distance
            if validDValues(vert, i) < 300
                pingResults{vert, i} = 'Ping: Reply 100%';
            else
                pingResults{vert, i} = 'Timeout';
                % Tambahkan kondisi untuk keluar dari loop jika goalNode tercapai
                if i == goalNode
                    flag = 1;
                    break;
                end
            end

            % Log RREP
            disp(['Node ' num2str(i) ' sends RREP message to node ' num2str(vert)]);

            % Tambahkan kondisi untuk keluar dari loop jika goalNode tercapai
            if i == goalNode
                flag = 1;
                break;
            end
        end
    end

    if all(status == '!')
        flag = 1;
        break;
    end

    % pause(2.0);  % Add a pause to slow down the animation
end

% Display ping results
disp('Ping Results:');
for i = 1:numNodes
    for j = 1:numNodes
        if ~isempty(pingResults{i, j})
            disp(['Node ' num2str(i) ' to Node ' num2str(j) ': ' pingResults{i, j}]);
        end
    end
end

% Check for nodes that initiated RREQ but did not receive RREP (Timeout)
disp('Timeout Results:');
for i = 1:numNodes
    initiatedRREQ = find(~cellfun('isempty', pingResults(i, :)));
    receivedRREP = find(cellfun(@(x) strcmp(x, 'Ping: Reply 100%'), pingResults(i, :)));
    
    if isempty(receivedRREP)
        % Node initiated RREQ but did not receive RREP (Timeout)
        disp(['Node ' num2str(i) ' tidak RREP Ping : Timeout']);
    end
end

% Inisialisasi variabel untuk menyimpan rute
i = goalNode; % Ganti dengan goalNode
count = 1;
route(count) = goalNode;

% Bangun rute dari node terakhir ke node pertama
while next(i) ~= 0 % Ganti dengan node awal
    count = count + 1;
    route(count) = next(i);
    i = next(i);
end

% Tampilkan hasil rute
disp('AODV Route:');
disp(route);