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
tableSSN = [];

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
            if validDValues(vert, i) 
                % Log RREQ
                disp(['Node ' num2str(vert) ' sends RREQ message to node ' num2str(i)]);
                % Simulasikan penerimaan RREQ dan kirimkan RREP
                % Jika node tujuan tercapai, set flag menjadi 1
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
            end

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


result.Difference = result.RREPSN - result.SSN;
% Set the threshold for disconnect status
threshold_lower = -14;
threshold_upper = 14;

% Initialize the 'Status' column as 'Connected'
result.Status = repmat("Connected", height(result), 1);

% Update 'Status' to 'Disconnected' if the difference is beyond the thresholds
result.Status(result.Difference < threshold_lower | result.Difference > threshold_upper) = "Disconnected";

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
    
    % Menyimpan indeks baris dengan status "Disconnected" dan mengubah warna menjadi merah
    disconnectedIdx = find(strcmp(resultTableTime.Status, 'Disconnected'));
    if ~isempty(disconnectedIdx)
        resultTableTime.color(disconnectedIdx) = {'red'}; % Corrected assignment using comma-separated list
    end

    % Check if the status is "Disconnected" and update SSN accordingly
    % Check if the status is "Disconnected" and update RREPSN accordingly
    disconnectedIdx = find(result.Status == "Disconnected");
    for idx = 1:numel(disconnectedIdx)
        % Generate a random RREPSN for disconnected nodes
        result.RREPSN(disconnectedIdx(idx)) = randi([0, 1000000000]); % Assuming the range for RREPSN
    end

    
    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.Result{t} = resultTableTime;

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

% Membuat plot untuk setiap nilai t dari 1 hingga 100
for t_idx = 1:20
    % Mengambil tabel dari dalam cell array
    resultTableTime = group.Result{t_idx};

    % Membuat plot (digunakan 'hold on' hanya pada iterasi pertama)
    if t_idx == 1
        hold on;
    else
        % Membersihkan figur sebelum memplot iterasi berikutnya
        clf;
        hold on;
    end

    % Hitung delay_avg
    delay_avg = zeros(size(resultTableTime, 1), 1);

    % Plot data pada subplot pertama
    subplot(3, 1, 1);
    xlabel('Data x');
    ylabel('Data y');
    grid on;
    hold on;

    for i = 1:size(resultTableTime, 1)
        if strcmp(resultTableTime.color{i}, 'Head Cluster')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'X', 'Color', 'green', 'MarkerSize', 15, 'MarkerFaceColor', 'green', 'LineWidth', 1.5);
        elseif strcmp(resultTableTime.color{i}, 'blue')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 8, 'MarkerFaceColor', 'blue', 'LineWidth', 1);
        end
    end  

    title(['Plot Data untuk t = ' num2str(t_idx)]);

    % Plot garis antar node berdasarkan nilai d pada t saat ini
    for i = 1:size(resultTableTime, 1)-1
        d = sqrt((resultTableTime.x(i) - resultTableTime.x(i+1))^2 + (resultTableTime.y(i) - resultTableTime.y(i+1))^2);
        plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
    end

    % Menambahkan legenda untuk subplot pertama
    legend('Head Cluster (X Hijau)', 'Blue (Kendaraan)', 'Location', 'northwest');

    % Plot data pada subplot kedua
    subplot(3, 1, 2);
    xlabel('Data x');
    ylabel('Data y');
    grid on;
    hold on;

%     % Tentukan indeks head cluster di grafik pertama
%     originalHeadClusterIndex = find(strcmp(group.Result{1}.color, 'Head Cluster'));
%     
%     % Tentukan indeks head cluster di grafik kedua
%     newHeadClusterIndex = mod(originalHeadClusterIndex + t_idx - 1, size(resultTableTime, 1)) + 1;
%     
%     % Tentukan node yang ditinggalkan oleh head cluster
%     nodesDitinggalkan = originalHeadClusterIndex(originalHeadClusterIndex ~= newHeadClusterIndex);

    for i = 1:size(resultTableTime, 1)
        if strcmp(resultTableTime.color{i}, 'Head Cluster')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'X', 'Color', 'green', 'MarkerSize', 15, 'MarkerFaceColor', 'green', 'LineWidth', 1.5);
        elseif strcmp(resultTableTime.color{i}, 'blue')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 8, 'MarkerFaceColor', 'blue', 'LineWidth', 1);
        elseif strcmp(resultTableTime.color{i}, 'red') || strcmp(resultTableTime.Status{i}, 'Disconnected')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'red', 'MarkerSize', 8, 'MarkerFaceColor', 'red', 'LineWidth', 1);
            text(resultTableTime.x(i), resultTableTime.y(i), 'Discard Route', 'Color', 'red', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
        else
            plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', warna{mod(i, length(warna)) + 1}, 'MarkerSize', 8, 'MarkerFaceColor', warna{mod(i, length(warna)) + 1}, 'LineWidth', 1);
        end
    end
    
    title(['Plot 2 Data untuk Serangan ']);
    
    % Plot garis antar node berdasarkan nilai d pada t saat ini
    for i = 1:size(resultTableTime, 1)-1
        % Periksa apakah node saat ini atau node berikutnya berstatus "Disconnected"
        if strcmp(resultTableTime.color{i}, 'red') || strcmp(resultTableTime.color{i+1}, 'red')
            % Hitung titik terputus yang ditarik ke sumbu y dengan perbedaan -100
            disconnected_y = resultTableTime.y(i) - 100;
            
            % Plot garis terputus dari titik sebelumnya ke titik terputus dengan warna hitam
            plot([resultTableTime.x(i), resultTableTime.x(i)], [resultTableTime.y(i), disconnected_y], 'k--', 'LineWidth', 1);
            
            % Plot garis dari titik terputus ke titik berikutnya dengan warna hitam
            plot([resultTableTime.x(i), resultTableTime.x(i+1)], [disconnected_y, resultTableTime.y(i+1)], 'k--', 'LineWidth', 1);
            
            % Tambahkan teks "Disconnected" pada titik yang disconnected
            text(resultTableTime.x(i), disconnected_y, 'Disconnected', 'Color', 'k', 'HorizontalAlignment', 'center');
        else
            % Plot garis antar node jika keduanya terhubung
            plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
        end
    end

    % Menambahkan legenda untuk subplot kedua 
    legend('Head Cluster (X Hijau)', 'Blue (Kendaraan)', 'Red', 'Location', 'northwest');
    
    % Inisialisasi array untuk menyimpan throughput
    throughputdata = zeros(1, 20); % Anda perlu menyesuaikan ukurannya dengan jumlah iterasi yang diinginkan
    throughputserangan = zeros(1, 20); % Anda perlu menyesuaikan ukurannya dengan jumlah iterasi yang diinginkan
    
    % Loop untuk menghitung throughput pada setiap iterasi
    for t_idx = 1:20
        % Mengambil tabel dari dalam cell array
        resultTableTime = group.Result{t_idx};
    
        % Hitung jumlah node yang masih aktif (x dan y positif) berdasarkan posisi x dan y
        active_nodes = sum(resultTableTime.x > 0 & resultTableTime.y > 0);
    
        % Hitung throughput sebagai jumlah node yang masih aktif dibagi jumlah total node
        throughputdata(t_idx) = active_nodes / size(resultTableTime, 1);
    end
    
    % Menghitung throughput dari data yang tersedia
    % Menghitung throughput dari data yang tersedia
    for t_idx = 1:20
        resultTableTime = group.Result{t_idx};
        
        % Hitung jumlah node yang masih terhubung (tidak disconnected)
        connected_nodes = sum(strcmp(resultTableTime.Status, 'Connected'));
        
        % Hitung throughput sebagai jumlah node yang masih terhubung dibagi jumlah total node
        throughputserangan(t_idx) = connected_nodes / size(resultTableTime, 1);
    end
    
    % Plot throughput dalam subplot baru (subplot 3, 1, 3)
    subplot(3, 1, 3);
    % Memplot throughput data dengan warna biru dan memberikan label 'Data Throughput'
    plot(1:20, throughputdata, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Data Throughput');
    hold on;
    
    % Memplot throughput serangan dengan warna merah dan memberikan label 'Attack Throughput'
    plot(1:20, throughputserangan, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Attack Throughput');
    
    xlabel('Jumlah Titik');
    ylabel('Throughput');
    title('Throughput over time');
    grid on;
    
    % Menambahkan legenda
    legend('throughput non serangan', 'throughput serangan', 'Location', 'northwest');

    

    % Menambahkan legenda untuk subplot keempat
%     legend('Throughput', 'Location', 'northeast');

    % Tunggu sejenak agar plot dapat diperbarui
    drawnow;
    pause(0.5);

end

hold off;
    

% Tampilkan hasil rute
disp('AODV Route:');
disp(route);