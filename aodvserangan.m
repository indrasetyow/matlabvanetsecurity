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

A6 = 500; % Satuan Kbps 
B6 = 30;

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
    result.RREPSN = zeros(height(result), 1);
    result(result.t == 0, :) = [];

    
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
id_count = containers.Map('KeyType', 'char', 'ValueType', 'double');
for t = 1:max(result.t)
    % Mendapatkan ID yang muncul pada iterasi saat ini
    ids_current = unique(result.id(result.t == t));
    
    % Loop melalui setiap ID yang muncul pada iterasi saat ini
    for id_idx = 1:numel(ids_current)
        id = ids_current{id_idx};
        % Jika ID tidak ada dalam struktur id_count, tambahkan dan atur nilai awalnya menjadi 0
        if ~isKey(id_count, id)
            id_count(id) = 0;
        end
        % Mendapatkan jumlah kemunculan ID pada iterasi sebelumnya
        count_prev = id_count(id);
        
        % Mendapatkan indeks ID pada iterasi saat ini
        idx_current = find(strcmp(result.id, id) & result.t == t);
        
        % Memperbarui sequence untuk ID pada iterasi saat ini dengan indeks unik yang tepat
        for i = 1:numel(idx_current)
            % Mengubah tipe data SSN menjadi integer dan memulai pengurutan dari time 1
            result.SSN(idx_current(i)) = count_prev + i;
        end
        
        % Mengupdate jumlah kemunculan ID
        id_count(id) = count_prev + numel(idx_current);
    end
end

% Inisialisasi variabel
numNodes = height(unique(result));
validDValues = zeros(numNodes, numNodes);

% Tentukan jumlah baris yang ingin digunakan
jumlah_baris = 313; 

% Ambil sejumlah baris tertentu dari tabel result
data_terbatas = result(1:jumlah_baris, :);

% Mengambil jumlah unik dari kolom 'id' dalam tabel 'data_terbatas' untuk mendapatkan jumlah node
numNodes = numel(unique(data_terbatas.sequence));

% Menginisialisasi matriks validDValues dengan jarak antar node
for i = 1:numNodes
    for j = 1:numNodes
        % Perhitungan jarak antar node i dan j
        validDValues(i, j) = sqrt((data_terbatas.x(i) - data_terbatas.x(j))^2 + (data_terbatas.y(i) - data_terbatas.y(j))^2);
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
        dist(i) = data_terbatas.d(i);
        next(i) = 1;
    end
end

% Inisialisasi variabel lainnya
flag = 0;
temp = 0;

% Set goalNode
goalNode = 20; % Sesuaikan dengan node tujuan

% Initialize variables to store ping information
pingResults = cell(numNodes, numNodes);
rrepsn = zeros(max(result.t), numel(unique(result.id)));
threshold_lower = -14;
threshold_upper = 14;
result.Status = repmat("Connected", height(result), 1);

% Main loop
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

            % Simulasi RREQ hanya jika tidak dalam keadaan Timeout
            if validDValues(vert, i) < 300
                pingResults{vert, i} = 'Ping: Reply 100%';

                % Log RREQ
                disp(['Node ' num2str(vert) ' sends RREQ message to node ' num2str(i)]);
                % Simulasikan penerimaan RREQ dan kirimkan RREP
                % Update RREPSN values
                rrepsn(i) = rrepsn(i) + 1; % Tingkatkan nilai rrepsn untuk node yang membalas
                % Update tableSSN with RREPSN values
                result.RREPSN(i) = rrepsn(i); % Update nilai RREPSN untuk node yang membalas
                disp(['Node ' num2str(i) ' sends RREP message (RREPSN=' num2str(rrepsn(i)) ') to node ' num2str(vert)]);

                if i == goalNode
                    flag = 1;
                    break;
                end
                
                
            else
                % Jika mencapai Timeout, set hasil ping menjadi Timeout
                pingResults{vert, i} = 'Timeout';
                pingResults{vert, i} = ['Node ' num2str(vert) ' timeout to Node ' num2str(i)];
                disp(pingResults{vert, i});
                result.Status(vert) = "Timeout";


            end

            % Tambahkan kondisi untuk keluar dari loop jika goalNode tercapai
            if i == goalNode
                flag = 1;
                break;
            end
        end
    end
    result.Difference = result.RREPSN - result.SSN;
    result.Status(result.Difference < threshold_lower | result.Difference > threshold_upper) = "Disconnected";
    result.Status(contains(result.Status, 'Timeout')) = "Timeout";

    if all(status == '!')
        flag = 1;
        break;
    end
end


% Check for nodes that initiated RREQ but did not receive RREP (Timeout)
% disp('Timeout Results:');
for i = 1:numNodes
    initiatedRREQ = find(~cellfun('isempty', pingResults(i, :)));
    
    % Initialize receivedRREP as an empty array
    receivedRREP = [];
    
    % Loop through each node's ping result at time t
    for j = 1:numNodes
        % Check if there's a ping result for the current node at time t
        if ~isempty(pingResults{i, j})
            % Check if the ping result indicates a successful reply at time t
            if contains(pingResults{i, j}, 'Ping: Reply 100%')
                receivedRREP = [receivedRREP j];
            end
        end
    end
    
    % Check if there are nodes that initiated RREQ but did not receive RREP
%     if isempty(receivedRREP)
%         % Node initiated RREQ but did not receive RREP (Timeout)
%         disp(['Node ' num2str(i) ' tidak RREP Ping : Timeout']);
%     end
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


% result.Difference = result.RREPSN - result.SSN;
% % Set the threshold for disconnect status
% threshold_lower = -14;
% threshold_upper = 14;
% 
% % Initialize the 'Status' column as 'Connected'
% result.Status = repmat("Connected", height(result), 1);
% 
% % Update 'Status' to 'Disconnected' if the difference is beyond the thresholds
% result.Status(result.Difference < threshold_lower | result.Difference > threshold_upper) = "Disconnected";
% result.Status(contains(result.Status, 'Timeout')) = "Timeout";

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
for t = 1:50
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
for t = 1:50
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
    
    % Berikan warna merah untuk nilai d terbesar jika d > 0
    if ~isempty(maxD)
        resultTableTime.color(maxD)= {'magenta'};
        % Ubah status menjadi 'Timeout'
        resultTableTime.Status(maxD) = {'Timeout'};
    end
    
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

    % Menghasilkan nilai pt dalam rentang [200, 300] berdasarkan t
    pt = 50 + (t - 1) * 10; % Pertambahan 10 setiap iterasi t
    
    % Pastikan pt tidak melebihi 300
    if pt > 100
        pt = 100;
    end
    
    % Membuat kolom pt untuk setiap baris
    resultTableTime.pt = repmat(pt, height(resultTableTime), 1);
    
    % Mengatur semua nilai dalam rt menjadi 40
    rt = repmat(20, height(resultTableTime), 1);

    resultTableTime.rt = rt;


    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.Result{t} = resultTableTime;

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx zeroDIdx;
    clear headClusterIdx maxD minD;
end

% Inisialisasi variabel baru untuk warna pada result
result.color = cell(height(result), 1);


% Iterasi untuk t = 1 hingga 50
for t = 1:50
    % Mengambil tabel dari dalam cell array
    resultTableTimeSerangan = group.Result{t};

    % Menambahkan kolom warna ke dalam tabel hanya jika d > 0
    resultTableTimeSerangan.color = cell(height(resultTableTimeSerangan), 1);

    % Temukan indeks baris dengan nilai d terkecil dan terbesar
    minD = find(resultTableTimeSerangan.d == min(resultTableTimeSerangan.d(resultTableTimeSerangan.d > 0)), 1, 'first');
    maxD = find(resultTableTimeSerangan.d >= 300);

    % Berikan warna hijau untuk nilai d terkecil jika d > 0
    if ~isempty(minD)
        resultTableTimeSerangan.color{minD} = 'green';
    end
    
    % Berikan warna merah untuk nilai d terbesar jika d > 0
    if ~isempty(maxD)
        resultTableTimeSerangan.color(maxD)= {'magenta'};
        % Ubah status menjadi 'Timeout'
        resultTableTimeSerangan.Status(maxD) = {'Timeout'};
    end
    
    % Isi nilai biru hanya untuk baris dengan nilai d sama dengan 0
    zeroDIdx = find(resultTableTimeSerangan.d == 0);
    
    % Hapus node biru dengan nilai d = 0 dari hasil plot
    resultTableTimeSerangan(zeroDIdx, :) = [];
    
    % Isi nilai biru untuk baris dengan nilai d tidak sama dengan 0 dan tidak memiliki warna
    nonZeroDIdx = find(resultTableTimeSerangan.d > 0 & cellfun('isempty', resultTableTimeSerangan.color));
    resultTableTimeSerangan.color(nonZeroDIdx) = {'blue'};
    
    % Menyimpan indeks baris dengan nilai d terkecil sebagai Head Cluster (warna hijau)
    headClusterIdx = find(strcmp(resultTableTimeSerangan.color, 'green'));
    if ~isempty(headClusterIdx)
        resultTableTimeSerangan.color{headClusterIdx} = 'Head Cluster';
    end
    
    % Menyimpan indeks baris dengan status "Disconnected" dan mengubah warna menjadi merah
    disconnectedIdx = find(strcmp(resultTableTimeSerangan.Status, 'Disconnected'));
    if ~isempty(disconnectedIdx)
        resultTableTimeSerangan.color(disconnectedIdx) = {'red'}; % Corrected assignment using comma-separated list
    end

    % Check if the status is "Disconnected" and update SSN accordingly
    % Check if the status is "Disconnected" and update RREPSN accordingly
    disconnectedIdx = find(result.Status == "Disconnected");
    for idx = 1:numel(disconnectedIdx)
        % Generate a random RREPSN for disconnected nodes
        result.RREPSN(disconnectedIdx(idx)) = randi([0, 1000000000]); % Assuming the range for RREPSN
    end

    % Inisialisasi matriks koneksi
    resultTableTimeSerangan.koneksi = zeros(size(resultTableTimeSerangan, 1), size(resultTableTimeSerangan, 1));
    
    % Mendapatkan indeks node yang belum terkoneksi
    unconnectedNodesIdx = find(sum(resultTableTimeSerangan.koneksi, 2) == 0);
    
    % Urutkan node yang belum terkoneksi berdasarkan nilai d dari terkecil hingga terbesar
    [~, sortedIdx] = sort(resultTableTimeSerangan.d(unconnectedNodesIdx));
    sortedUnconnectedNodesIdx = unconnectedNodesIdx(sortedIdx);
    
    % Membuat koneksi ulang berdasarkan node yang tidak terkoneksi yang sudah diurutkan
    for i = 1:length(sortedUnconnectedNodesIdx)
        currentNode = sortedUnconnectedNodesIdx(i);
        for j = (i+1):length(sortedUnconnectedNodesIdx)
            nextNode = sortedUnconnectedNodesIdx(j);
            if resultTableTimeSerangan.d(nextNode) < 300 % Jika jarak antara node saat ini dengan node berikutnya kurang dari 300
                resultTableTimeSerangan.koneksi(currentNode, nextNode) = 1;
                resultTableTimeSerangan.koneksi(nextNode, currentNode) = 1;
                break; % Hanya satu koneksi yang perlu ditambahkan
            end
        end
    end
    
    % Nonaktifkan koneksi ke dan dari node-node merah
    redNodesIdx = find(strcmp(resultTableTimeSerangan.color, 'red'));
    if ~isempty(redNodesIdx)
        for i = 1:length(redNodesIdx)
            redNode = redNodesIdx(i);
            resultTableTimeSerangan.koneksi(redNode, :) = 0; % Nonaktifkan koneksi ke node lain
            resultTableTimeSerangan.koneksi(:, redNode) = 0; % Nonaktifkan koneksi dari node lain
        end
    end
    
    % Membuat koneksi ulang berdasarkan node yang tidak terkoneksi dan bukan berwarna merah
    for i = 1:size(resultTableTimeSerangan.koneksi, 1)
        if sum(resultTableTimeSerangan.koneksi(i, :)) == 0 && ~strcmp(resultTableTimeSerangan.color(i), 'red') % Jika node belum terkoneksi dengan siapa pun dan bukan berwarna merah
            for j = 1:size(resultTableTimeSerangan.koneksi, 2)
                if i ~= j && sum(resultTableTimeSerangan.koneksi(j, :)) < 2 && resultTableTimeSerangan.d(i) < 300 && resultTableTimeSerangan.d(j) < 300
                    resultTableTimeSerangan.koneksi(i, j) = 1;
                    resultTableTimeSerangan.koneksi(j, i) = 1;
                    break; % Hanya satu koneksi yang perlu ditambahkan
                end
            end
        end
    end

     % Menghasilkan nilai pt dalam rentang [200, 300] berdasarkan t
    pt = 50 + (t - 1) * 10; % Pertambahan 10 setiap iterasi t
    
    % Pastikan pt tidak melebihi 300
    if pt > 100
        pt = 100;
    end
    
    % Membuat kolom pt untuk setiap baris
    resultTableTimeSerangan.pt = repmat(pt, height(resultTableTimeSerangan), 1);
  
    % Mengatur semua nilai dalam rt menjadi 40
    rt = repmat(15, height(resultTableTimeSerangan), 1);

    resultTableTimeSerangan.rt = rt;

    % Set pt dan rt menjadi 0 untuk node yang memiliki warna merah
    if ~isempty(redNodesIdx)
        for i = 1:length(redNodesIdx)
            redNode = redNodesIdx(i);
            resultTableTimeSerangan.pt(redNode, :) = -0.5;
            resultTableTimeSerangan.rt(redNode, :) = -0.5;
        end
    end
    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.ResultTime{t} = resultTableTimeSerangan;

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx zeroDIdx;
    clear headClusterIdx maxD minD;
end

% Inisialisasi variabel baru untuk warna pada result
result.color = cell(height(result), 1);

% Iterasi untuk menyalin warna dari resultTableTime ke result
for t = 1:50
    resultTime = group.Result{t};
    idxResult = find(result.t == t);

    % Pastikan indeks tidak melebihi ukuran result
    if isempty(idxResult)
        break;
    end

    
    % Salin warna dari resultTableTime ke result
    result.color(idxResult) = resultTime.color;
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 




% Inisialisasi warna untuk plotting
warna = {'blue', 'red', 'green', 'black', 'cyan', 'magenta', 'yellow', 'white'};

% Inisialisasi delay dan throughput
delay1 = zeros(1, 100);
throughput1 = zeros(1, 100);

% Inisialisasi delay dan throughput
delay2 = zeros(1, 100);
throughput2 = zeros(1, 100);

% Membuat plot untuk setiap nilai t dari 1 hingga 100
for t_idx = 1:20
    % Mengambil tabel dari dalam cell array untuk plot kedua
    resultTableTimeSerangan = group.Result{t};

    % Hitung jumlah node merah
    redNodeCount = sum(strcmp(resultTableTimeSerangan.color, 'red'));

    % Membersihkan figur pertama sebelum memplot iterasi berikutnya
    figure(1);
    clf;
    axis([-50 350 -40 120]);
%     title('Jalur PKU - Node Kendaraan & Head Cluster');
    title(['Simulasi 1 Tanpa Serangan - Iterasi ', num2str(t_idx)]);
    xlabel('Data x');
    ylabel('Data y');
    grid on;
    hold on;

    % Membersihkan figur kedua sebelum memplot iterasi berikutnya
    figure(2);
    clf;
    axis([-50 350 -40 120]);
%     title(['Jalur PKU - Node Kendaraan & Malicious - Iterasi ', num2str(t_idx)]);
    title(['Simulasi 2 Serangan - Iterasi ', num2str(t_idx), ' - Malicious Nodes: ', num2str(redNodeCount)]);
    xlabel('Data x');
    ylabel('Data y');
    grid on;
    hold on;

    % Membersihkan figur delay sebelum memplot iterasi berikutnya
    figure(3);
    axis('auto');
%     title('Delay');
    xlabel('Jumlah Kendaraan (s)');
    ylabel('Delay (ms)');
    grid on;
    hold on;

    % Membersihkan figur throughput sebelum memplot iterasi berikutnya
    figure(4);
    axis('auto');
%     title('Throughput');
    xlabel('Jumlah Kendaraan (s)');
    ylabel('Throughput (kbps)');
    grid on;
    hold on;

    % Mengambil tabel dari dalam cell array untuk plot pertama
    resultTableTime = group.Result{t_idx};

    % Urutkan berdasarkan nilai d
    [~, idxSorted] = sort(resultTableTime.d);
    resultTableTime = resultTableTime(idxSorted, :);


    for i = 1:size(resultTableTime, 1)        
        if strcmp(resultTableTime.color{i}, 'Head Cluster')
            figure(1);
            scatter(resultTableTime.x(i), resultTableTime.y(i), 100, 'green', 'X', 'LineWidth', 1.5); % Simbol X untuk Head Cluster
        elseif strcmp(resultTableTime.color{i}, 'blue')
            figure(1);
            scatter(resultTableTime.x(i), resultTableTime.y(i), 64, 'blue', 'o', 'filled'); % Titik-titik biru
        end
        
        % Plot garis antar node
        if i < size(resultTableTime, 1)
            figure(1);
            plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
        end
    end


%     

    % Menambahkan legenda untuk subplot pertama
    figure(1);
    hold on; 
    h1 = scatter(NaN, NaN, 100, 'green', 'X', 'LineWidth', 1.5); 
    h2 = scatter(NaN, NaN, 64, 'blue', 'o', 'filled'); 
    leg1 = legend([h1, h2], 'Head Cluster', 'Node Kendaraan', 'Location', 'northeast');
    set(leg1, 'Box', 'on');
    hold off;

    
    
    

    

    % Plot data pada subplot pertama
    figure(2);
    xlabel('Data x');
    ylabel('Data y');
    clf;
    grid on;
    hold on;

    % Mengambil tabel dari dalam cell array untuk plot kedua
    resultTableTimeSerangan = group.ResultTime{t_idx};

    % Menentukan newHeadCluster berdasarkan nilai d terkecil yang tidak 'red'
    minD = min(resultTableTimeSerangan.d(~strcmp(resultTableTimeSerangan.color, 'red')));
    newHeadClusterIndex = find(resultTableTimeSerangan.d == minD, 1);

%     for i = 1:size(resultTableTimeSerangan, 1)
%         if i == newHeadClusterIndex
%             figure(2);
%             scatter(resultTableTimeSerangan.x(i), resultTableTimeSerangan.y(i), 100, 'g', 'X', 'LineWidth', 1.5);
%         elseif strcmp(resultTableTimeSerangan.color{i}, 'red') || strcmp(resultTableTimeSerangan.color{i}, 'Malicious')
%             figure(2);
%             scatter(resultTableTimeSerangan.x(i), resultTableTimeSerangan.y(i), 64, 'r', 'filled'); 
%         else
%             figure(2);
%             scatter(resultTableTimeSerangan.x(i), resultTableTimeSerangan.y(i), 64, 'b', 'filled');
% %         else
% %             figure(2);
% %             scatter(resulttime.x(i), resulttime.y(i), 64, 'b', 'filled');
%         end
%         % Menggambar koneksi antar node
%         for j = i + 1:size(resulttime.koneksi, 2)
%             if resulttime.koneksi(i, j) == 1 && ~strcmp(resulttime.color{i}, 'red') && ~strcmp(resulttime.color{j}, 'red')
%                 plot([resulttime.x(i), resulttime.x(j)], [resulttime.y(i), resulttime.y(j)], 'b--', 'LineWidth', 1);
%             end
%         end
%     end
%      
    
    % Iterate over all nodes to plot them based on their properties
    for i = 1:size(resultTableTimeSerangan, 1)
        if i == newHeadClusterIndex
            figure(2);
            scatter(resultTableTimeSerangan.x(i), resultTableTimeSerangan.y(i), 100, 'g', 'X', 'LineWidth', 1.5);
        elseif strcmp(resultTableTimeSerangan.color{i}, 'red') || strcmp(resultTableTimeSerangan.color{i}, 'Malicious')
            figure(2);
            scatter(resultTableTimeSerangan.x(i), resultTableTimeSerangan.y(i), 64, 'r', 'filled'); 
        else
            figure(2);
            scatter(resultTableTimeSerangan.x(i), resultTableTimeSerangan.y(i), 64, 'b', 'filled');
        end
        
        % Plot connections between nodes
        for j = i + 1:size(resultTableTimeSerangan.koneksi, 2)
            if resultTableTimeSerangan.koneksi(i, j) == 1
                if strcmp(resultTableTimeSerangan.color{i}, 'red') || strcmp(resultTableTimeSerangan.color{j}, 'red')
                    % Draw connections involving red nodes with a different style
                    plot([resultTableTimeSerangan.x(i), resultTableTimeSerangan.x(j)], [resultTableTimeSerangan.y(i), resultTableTimeSerangan.y(j)], 'r--', 'LineWidth', 1.5);
                else
                    % Draw connections between non-red nodes
                    plot([resultTableTimeSerangan.x(i), resultTableTimeSerangan.x(j)], [resultTableTimeSerangan.y(i), resultTableTimeSerangan.y(j)], 'b--', 'LineWidth', 1);
                end
            end
        end
    end



   

%     % Plot garis antar node berdasarkan koneksi
%     for i = 1:size(resultTableTimeSerangan.koneksi, 1)
%         for j = i+1:size(resultTableTimeSerangan.koneksi, 2)
%             if resultTableTimeSerangan.koneksi(i, j) == 1 % Jika ada koneksi antara node i dan node j
%                 d = sqrt((resultTableTimeSerangan.x(i) - resultTableTimeSerangan.x(j))^2 + (resultTableTimeSerangan.y(i) - resultTableTimeSerangan.y(j))^2);
%                 if d <= 300
%                     plot([resultTableTimeSerangan.x(i), resultTableTimeSerangan.x(j)], [resultTableTimeSerangan.y(i), resultTableTimeSerangan.y(j)], 'b--', 'LineWidth', 1);
%                 else
%                     plot([resultTableTimeSerangan.x(i), resultTableTimeSerangan.x(j)], [resultTableTimeSerangan.y(i), resultTableTimeSerangan.y(j)], 'r--', 'LineWidth', 1);
%                 end
%             end
%         end
%     end

    figure(2);
    hold on; 
    h1 = scatter(NaN, NaN, 100, 'green', 'X', 'LineWidth', 1.5); 
    h2 = scatter(NaN, NaN, 64, 'blue', 'o', 'filled');
    h3 = scatter(NaN, NaN, 64, 'red', 'o', 'filled');
    leg2 = legend([h1, h2, h3], 'Head Cluster', 'Node Kendaraan', 'Malicious', 'Location', 'northeast');
    set(leg2, 'Box', 'on');
    hold off; 
   
    % Perhitungan delay dan throughput pada detik t_idx untuk group.Result
    total_pt_1 = sum(group.Result{t_idx}.pt);
    total_rt_1 = sum(group.Result{t_idx}.rt);
%     Delay1 = total_pt_1 / max(total_rt_1, 1);
    Delay1 = total_pt_1 / total_rt_1;
    
    % Perhitungan throughput pada detik t_idx untuk group.Result
    paket_diterima_1 = group.Result{t_idx}.rt; % paket data yang diterima dalam kb
    waktu_pengiriman_1 = group.Result{t_idx}.pt; % waktu pengiriman dalam detik
    Throughput1 = paket_diterima_1 ./ max(waktu_pengiriman_1, 1);
    
    % Perhitungan delay pada detik t_idx untuk group.ResultTime
    total_pt_2 = sum(group.ResultTime{t_idx}.pt);
    total_rt_2 = sum(group.ResultTime{t_idx}.rt);
%     Delay2 = total_pt_2 / max(total_rt_2, 1);
    Delay2 = total_pt_2 / total_rt_2;
    
    % Perhitungan throughput pada detik t_idx untuk group.ResultTime
    paket_diterima_2 = group.ResultTime{t_idx}.rt; % paket data yang diterima dalam kb
    waktu_pengiriman_2 = group.ResultTime{t_idx}.pt; % waktu pengiriman dalam detik
    Throughput2 = paket_diterima_2 ./ max(waktu_pengiriman_2, 1);
    
    % Menyimpan hasil perhitungan delay dan throughput
%     delay1(t_idx) = Delay1;
    delay1(t_idx) = mean(Delay1);
    throughput1(t_idx) = mean(Throughput1); % Menggunakan mean untuk mendapatkan nilai rata-rata jika ada beberapa elemen
    
%     delay2(t_idx) = Delay2;
    delay2(t_idx) = mean(Delay2);
    throughput2(t_idx) = mean(Throughput2); % Menggunakan mean untuk mendapatkan nilai rata-rata jika ada beberapa elemen

    % Plot delay
    figure(3);
    plot(1:t_idx, delay1(1:t_idx), 'g.-'); % Plot delay dari figure 1
    hold on;
    plot(1:t_idx, delay2(1:t_idx), 'r.-');
    h_delay = legend('Normal', 'Under Attack', 'Location', 'northeast');
    set(h_delay, 'Box', 'on');  % Menghilangkan kotak di sekitar legenda
    hold off;

    % Plot throughput
    figure(4);
    plot(1:t_idx, throughput1(1:t_idx), 'g.-'); % Plot throughput dari figure 1
    hold on;
    plot(1:t_idx, throughput2(1:t_idx), 'r.-');
    h_throughput = legend('Normal', 'Under Attack', 'Location', 'northeast');
    set(h_throughput, 'Box', 'on');  % Menghilangkan kotak di sekitar legenda
    hold off;

  
    
   
    pause(0.45);

end

hold off;
    

% Tampilkan hasil rute
disp('AODV Route:');
disp(route);