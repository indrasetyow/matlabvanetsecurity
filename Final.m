filename = 'Hsimulasi.xlsx';
sheet = 'Sheet2';
data = readtable(filename, 'Sheet', sheet);

t = data.time;
x = data.x;
y = data.y;
l = data.lane;
p = data.type;
speed = data.speed;

f_5G = 5.9; % Standar VANET 802.11p (Ghz)
f_6G = 6; % Perkiraan frekuensi yang digunakan pada 6G

K = 30; % Konstanta berbeda setiap lingkungan

% Sistem 5G Nilai kisaran
A5 = 498; % Satuan Kbps
B5 = 30;

% Sistem 6G Nilai kisaran
A6 = 500; % Satuan Kbps 
B6 = 30;

%B5 = 40; % Bandwidth yang digunakan pada dalam satuan MHz
%B6 = 80; % Bandwidth yang digunakan pada dalam satuan MHz
start1 = 1;

figure; % Membuat figure baru

subplot(4, 1, 1);
axis([-50 350 -40 120]);
title('Jalur PKU');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

% subplot(7, 1, 2);
% axis([10 inf 18.671 inf]);
% title('Analisis Perbandingan 5G & 6G');
% xlabel('Jumlah kendaraan');
% ylabel('decibel (dB)');
% grid on;
% hold on;
% 
% subplot(7, 1, 3); % Subplot untuk menghitung delay
% %axis('auto');
% axis([10 inf 155.283 inf]);
% title('Delay Berdasarkan Jarak');
% xlabel('Jumlah Kendaraan');
% ylabel('Delay (ms)');
% grid on;
% hold on;
% 
% subplot(5, 1, 2); % Subplot untuk menghitung throughput
% %axis([10 inf 434 134]);
% axis('auto');
% title('Pengaruh Throughput');
% xlabel('Jumlah Kendaraan');
% ylabel('Throughput (Kbps)');
% grid on;
% hold on;

subplot(4, 1, 2); % Subplot untuk menghitung reachable
%axis('auto');
axis([10 inf 0 inf]);
title('TraceCount Reachable');
xlabel('Jumlah Kendaraan');
ylabel('Duration (s)');
grid on;
hold on;

subplot(4, 1, 3);
axis([-50 350 -40 120]);
title('Jalur PKU Reachable dan Unreachable');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

subplot(4, 1, 4);
axis([-50 350 -40 120]);
title('Jalur PKU Cluster');
xlabel('Data x');
ylabel('Data y');
zlabel('Normalized Angle');
grid on;
hold on;

Data_t = unique(t);
Data_p = unique(p);
Data_l = unique(l);
xy_array = [];
dB_avg6 = [];
dB_avg5 =[];
delay_avg5 = [];
delay_avg6 = [];
Throughput_avg5 = [];
Throughput_avg6 = [];
Throughput_avg = [];
delay_avg =[];
traceCount = [];
reachableDuration = [];

for i = 1:length(Data_t)
    subplot(4, 1, 1);
    cla;
    idx = t == Data_t(i);
    xy_array = [xy_array; x(idx) y(idx)];
    distance1 = sqrt((xy_array(:, 1).^2) + (xy_array(:, 2).^2));

%     % Menghitung path loss dB
%     dB5 = 20*log10(distance1/3600) + 20*log10(f_5G) + K;
%     dB6 = 20*log10(distance1/3600) + 20*log10(f_6G) + K;
%     dB_avg5 = [dB_avg5; mean(dB5)];
%     dB_avg6 = [dB_avg6; mean(dB6)];
% 
% 
%     % Menghitung delay berdasarkan jarak (delay itu kendaraan semakin banyak maka delay semakin besar)
%     delay5 = 4 + 10 * 3 * log(distance1); % Model log-distance path loss
%     delay6 = 2 + 10 * 3 * log(distance1);
%     delay_avg5 = [delay_avg5; mean(delay5)];
%     delay_avg6 = [delay_avg6; mean(delay6)];

    %K5 = 10.^(dB5/10); % Menentukan linier dengan menggunakan dB
    %K6 = 10.^(dB6/10);
    %delay5 = log10(distance1).*K5;
    %delay6 = log10(distance1).*K6;
    %delay_avg5 = [delay_avg5; mean(delay5)];
    %delay_avg6 = [delay_avg6; mean(delay6)];

%     % Menghitung throughput
%     Throughput5 = A5 - B5 * log10(distance1); % Model Log-Distance
%     Throughput_avg5 = [Throughput_avg5; mean(Throughput5)];
% 
%     Throughput6 = A6 - B6 * log10(distance1); % Model Log-Distance
%     Throughput_avg6 = [Throughput_avg6; mean(Throughput6)];


    %Throughput = A *log10(distance1)-B; % Model Log-Distance dlm linier
    %Throughput_avg = [Throughput_avg; mean(Throughput)];

    %Throughput = A - B * log10(distance1); % Model Log-Distance
    %Throughput_avg = [Throughput_avg; mean(Throughput)];

    %Throughput5 = B5 * log2(1 + K5); % Rumus Shannon Capacity Formula
    %Throughput6 = B6 * log2(1 + K6);
    %Throughput_avg5 = [Throughput_avg5; mean(Throughput5)];
    %Throughput_avg6 = [Throughput_avg6; mean(Throughput6)];

    % Memisahkan data berdasarkan jenis kendaraan
    idx_mobil = idx & strcmp(p, 'mobil');
    idx_taxi = idx & strcmp(p, 'taxi');
 
    % Plot titik koordinat mobil dengan warna hijau
    plot(x(idx_mobil), y(idx_mobil), 'o', 'MarkerFaceColor', 'Green');
    hold on;

% Plot titik koordinat taksi dengan warna merah
    plot(x(idx_taxi), y(idx_taxi), 'o', 'MarkerFaceColor', 'Red');
    hold on;

    % Plot titik koordinat RSU 
    rsu_x = 119.797421731123;
    rsu_y = 50.2803738317757;
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left')
    plot(rsu_x, rsu_y, 'o', 'MarkerFaceColor', 'cyan');
    hold on;

    % Menghubungkan dua titik koordinat dengan garis berdasarkan nilai unik pada Data_l
    for j = 1:length(Data_l)
        idx_l = idx & strcmp(l, Data_l(j));
        x_l = x(idx_l);
        y_l = y(idx_l);

        % Menggambar garis yang menghubungkan titik terdekat
        for k = 1:length(x_l)-1
            % Menghitung jarak antara dua titik
            distance2 = sqrt((x_l(k+1) - x_l(k))^2 + (y_l(k+1) - y_l(k))^2);

            % Memilih warna berdasarkan jarak
            if distance2 <= 30
                line_color = 'green'; % Warna hijau untuk jarak <= 30 meter
            elseif distance2 <= 50
                line_color = 'red'; % Warna merah untuk jarak <= 50 meter
            end

            % Menggambar garis dengan warna yang sesuai
            line1 = plot([x_l(k), x_l(k+1)], [y_l(k), y_l(k+1)], '--', 'Color', line_color);
        end

        % Menghitung jarak antara titik dengan RSU
        distance_to_rsu = sqrt((x_l - rsu_x).^2 + (y_l - rsu_y).^2);
        idx_rsu = distance_to_rsu <= 30;

        % Menggambar garis yang menghubungkan titik dengan RSU
        for k = 1:length(x_l(idx_rsu))
            line1 = plot([x_l(idx_rsu(k)), rsu_x], [y_l(idx_rsu(k)), rsu_y], '--', 'Color', 'cyan');
        end

        % Menambahkan kondisi "reachable" atau "unreachable"
        kondisi = cell(size(data, 1), 1); % 
        for k = 1:size(data, 1)
            if x(k) <= 300 
                 kondisi{k} = 'reachable';
            elseif y(k) <= 300 
                 kondisi{k} = 'unreachable';
            %else
                 %kondisi{k} = '';
            end
        end

        % Menghitung TraceCount Reachable/Second
        traceCount = zeros(size(xy_array, 1), 1);
        reachableDuration = zeros(size(xy_array, 1), 1);
        
        for k = 1:size(xy_array, 1) % ubah data x, y
            if k == 1
                if strcmp(kondisi{k}, 'reachable')
                    reachableDuration(k) = 1;
                else
                    reachableDuration(k) = 0;
                end
            else
                if strcmp(kondisi{k}, 'reachable')
                    reachableDuration(k) = reachableDuration(k-1) + 1;
                else
                    reachableDuration(k) = reachableDuration(k-1) - 1;
                end
            end
            traceCount(k) = k;
        end
    end
    legend('mobil','taxi', 'RSU', 'Location', 'northwest');

%     % Plot untuk dB
%     subplot(7, 1, 2);
%     plot(Data_t(start1:i), dB_avg5(start1:i), '-', 'Color', 'red');
%     hold on;
%     plot(Data_t(start1:i), dB_avg6(start1:i), '-', 'Color', 'green');
%     legend('5G','6G', 'Location', 'northwest');
% 
%     % Plot untuk Delay
%     subplot(7, 1, 3);
%     plot(Data_t(start1:i),delay_avg5(start1:i), '-', 'Color', 'red');
%     hold on;
%     plot(Data_t(start1:i),delay_avg6(start1:i), '-', 'Color', 'green');
%     legend('5G','6G', 'Location', 'northwest');
%     
%     % Plot untuk Throughput
%     subplot(5, 1, 2);
%     plot(Data_t(start1:i),Throughput_avg5(start1:i), '-', 'Color', 'red');
%     hold on;
%     plot(Data_t(start1:i),Throughput_avg6(start1:i), '-', 'Color', 'green');
%     legend('5G','6G','Location', 'northwest');


% Plot untuk Duration
    subplot(4, 1, 2);
    plot(traceCount(start1:i),reachableDuration(start1:i), '-', 'Color', 'red');
    hold on;
    legend('mobil&taxi', 'Location', 'northwest');
   
    % Plot untuk Reachable dan Unreachable
    subplot(4, 1, 3);
    cla;
    plot(x(idx_mobil), y(idx_mobil), 'o', 'MarkerFaceColor', 'Green');
    hold on;
    plot(x(idx_taxi), y(idx_taxi), 'o', 'MarkerFaceColor', 'Red');
    hold on;
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left')
    hold on;
    plot(rsu_x, rsu_y, 'o', 'MarkerFaceColor', 'cyan');
    hold on;

    % Menghubungkan dua titik koordinat dengan garis berdasarkan nilai unik pada Data_l
    for j = 1:length(Data_l)
        idx_l = idx & strcmp(l, Data_l(j));
        x_l = x(idx_l);
        y_l = y(idx_l);
        id_l = data.id(idx_l); % Kolom id dari data
        type_l = data.type(idx_l); % Kolom type dari data

        % Menggambar garis yang menghubungkan titik terdekat
        for k = 1:length(x_l)-1
            % Menghitung jarak antara dua titik
            distance2 = sqrt((x_l(k+1) - x_l(k))^2 + (y_l(k+1) - y_l(k))^2);

            % Memilih warna berdasarkan jarak
            if distance2 <= 30
                line_color = 'green'; % Warna hijau untuk jarak <= 30 meter
            elseif distance2 <= 50
                line_color = 'red'; % Warna merah untuk jarak <= 50 meter
            end

            % Menggambar garis dengan warna yang sesuai
            line1 = plot([x_l(k), x_l(k+1)], [y_l(k), y_l(k+1)], '--', 'Color', line_color);
        end

        % Menghitung jarak antara titik dengan RSU
        distance_to_rsu = sqrt((x_l - rsu_x).^2 + (y_l - rsu_y).^2);
        idx_rsu = distance_to_rsu <= 30;

        % Menghitung jarak antara titik dengan RSU dan overwrite data
        distance_to_rsu = sqrt((x - rsu_x).^2 + (y - rsu_y).^2);
        data.Distance_to_RSU = distance_to_rsu;

        % Menggambar garis yang menghubungkan titik dengan RSU
        for k = 1:length(x_l(idx_rsu))
            line1 = plot([x_l(idx_rsu(k)), rsu_x], [y_l(idx_rsu(k)), rsu_y], '--', 'Color', 'cyan');
        end
        
        % Memberikan warna pada mobil & taxi ketika jarak >= 300
        for k = 1:size(x_l)
            Xi = x_l(k);
            Yi = y_l(k);
            id_i = id_l(k); % Id kendaraan
            type_i = type_l{k}; % Type kendaraan
            if Xi <= 300 && sqrt((Xi - rsu_x).^2 + (Yi - rsu_y).^2) <= 30
                node_color = 'Green';
            elseif Yi <= 300 
                node_color = 'Red';
            end
            plot(Xi, Yi, 'o', 'MarkerFaceColor', node_color);
            %text(Xi, Yi, [' ' id_i ,  type_i], 'Color', 'black', 'FontSize', 8);
            %text(Xi, Yi, [type_i], 'Color', 'black', 'FontSize', 8);
        end
    end
    legend('reachable','unreachable', 'RSU', 'Location', 'northwest');
    %legend('mobil','taxi', 'RSU', 'Location', 'northwest');
    
    
    subplot(4, 1, 4);
    cla;
    
    % Plot titik koordinat RSU 
    rsu_x = 119.797421731123;
    rsu_y = 50.2803738317757;
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left')
    plot(rsu_x, rsu_y, 'o', 'MarkerFaceColor', 'cyan');
    hold on;
    
    % Menghubungkan dua titik koordinat dengan garis berdasarkan nilai unik pada Data_l
    for j = 1:length(Data_l)
        idx_l = idx & strcmp(l, Data_l(j));
        x_l = x(idx_l);
        y_l = y(idx_l);
    
        % Menggambar garis yang menghubungkan titik terdekat
        for k = 1:length(x_l)-1
            % Menghitung jarak antara dua titik
            distance2 = sqrt((x_l(k+1) - x_l(k))^2 + (y_l(k+1) - y_l(k))^2);
    
            % Memilih warna berdasarkan jarak
            if distance2 <= 30
                line_color = 'green'; % Warna hijau untuk jarak <= 30 meter
            elseif distance2 <= 50
                line_color = 'red'; % Warna merah untuk jarak <= 50 meter
            end
    
            % Menggambar garis dengan warna yang sesuai
            %line1 = plot([x_l(k), x_l(k+1)], [y_l(k), y_l(k+1)], '--', 'Color', line_color);
        end
    
        % Menghitung jarak antara titik dengan RSU
        distance_to_rsu = sqrt((x_l - rsu_x).^2 + (y_l - rsu_y).^2);
        idx_rsu = distance_to_rsu <= 30;
    
        % Menggambar garis yang menghubungkan titik dengan RSU
        for k = 1:length(x_l(idx_rsu))
            %line1 = plot([x_l(idx_rsu(k)), rsu_x], [y_l(idx_rsu(k)), rsu_y], '--', 'Color', 'cyan');
        end
    end
    
    
    % Menambahkan data sudut (angle) dan normalisasi
    data_angle = a; 
    min_angle = min(data_angle);
    max_angle = max(data_angle);

    % Menambahkan nilai minimum dan maksimum dari data kecepatan
    min_speed = min(speed);
    max_speed = max(speed);

    
    % Normalisasi data sudut ke rentang yang sama dengan data x dan y
    min_range = min(x); 
    max_range = max(x); 
    
    % Normalisasi data Speed
    normalized_speed = min_range + ((speed - min_speed) / (max_speed - min_speed)) * (max_range - min_range);

    % Normalisasi data angle
    normalized_angle = min_range + ((data_angle - min_angle) / (max_angle - min_angle)) * (max_range - min_range);
    

    % Menggabungkan data kecepatan yang telah dinormlaisasi
    data_xy_angle_speed = [x(idx), y(idx), normalized_angle(idx), normalized_speed(idx)];


    % Menambahkan clustering K-Means menggunakan data x, y, dan sudut yang telah dinormalisasi
    data_xy_angle = [x(idx), y(idx), normalized_angle(idx)];
    k = 4; % jumlah cluster menjadi 4
    

    % membuat perhitungan dengan memanggil function clustering K-Means 
    % memasukkan idx kedalam iterasi dan membuat variable idx_kmeans untuk
    % menyimpan hasil clustering dengan cluster index yang ditetapkan
    % data_xy_angle yang dikaitkan dengan variable k cluster yang ditentukan
    % variable C untuk menyimpan koordinat Centroid pusat dari masing
    % masing cluster, k untuk memanggil variable jumlah cluster untuk
    % dimasukkan kedalam proses perhitungan. 
    % 'Distance', 'sqeuclidean'merupakan paramter untuk menentukan metrik
    % jarak menggunakan rumus persamaan eqeulidean  
    % 'Replicates', 5' merupakan parameter untuk mengontrol jumlah iterasi
    % yang akan dilakukan oleh algoritma K-means K-means melakukan 5 kali
    % perhitungan dengan titik awal yang berbeda untuk hasil iterasi yang
    % terbaik
    [idx_kmeans, C] = kmeans(data_xy_angle, k, 'Distance', 'sqeuclidean', 'Replicates', 5);
    
    % Menggambar hasil clustering dengan warna yang berbeda
    for cluster = 1:k
        cluster_points = data_xy_angle(idx_kmeans == cluster, :);
    % menggunakan loop untuk memisahkan clustering dengan warna dan marker
    % yang berbeda untuk tiap cluster
        if cluster == 1
            marker = 'h'; 
            color = 'blue';
        elseif cluster == 2
            marker = 's'; 
            color = 'red';
        elseif cluster == 3
            marker = '^'; 
            color = 'green';
        else
            marker = 'd'; 
            color = 'magenta';
        end
    
        % Plot titik-titik yang termasuk dalam cluster
        scatter3(cluster_points(:, 1), cluster_points(:, 2), cluster_points(:, 3), 50, color, marker, 'filled');
        hold on;
    
        % Plot centroid cluster dengan tanda X
        scatter3(C(cluster, 1), C(cluster, 2), C(cluster, 3), 200, color, 'X', 'LineWidth', 2);
        hold on;

        % Menambahkan label jenis kendaraan pada titik-titik data
        for i = 1:size(cluster_points, 1)
            x_label = cluster_points(i, 1);
            y_label = cluster_points(i, 2);
            z_label = cluster_points(i, 3);
            vehicle_label = p(idx_kmeans == cluster); % Mengambil label jenis kendaraan sesuai dengan cluster
        
            text(x_label, y_label, z_label, vehicle_label{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 8, 'Color', color);
            hold on;
        end
        % Menambahkan label kecepatan (speed) pada titik-titik data yang sudah dinormalisasi
        for i = 1:size(cluster_points, 1)
            x_label = cluster_points(i, 1);
            y_label = cluster_points(i, 2);
            z_label = cluster_points(i, 3);
            speed_label = normalized_speed(idx_kmeans == cluster); % Mengambil data kecepatan yang sesuai dengan cluster
        
            text_str = sprintf('%.2f', speed_label(i)); % Menampilkan label kecepatan dengan dua angka desimal
            text(x_label, y_label, z_label, text_str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 8, 'Color', color);
            hold on;
        end
    end

    
    
    
    % Menampilkan legenda
    legend('RSU', 'Cluster 1', 'Centroid 1', 'Cluster 2', 'Centroid 2', 'Cluster 3', 'Centroid 3', 'Cluster 4', 'Centroid 4', 'Location', 'northwest');



        
    pause(0.45);

    % Add the new column to the table
    data.Kondisi = kondisi;
    %outputData = table2cell(data);
    %outputData = {'time','id', 'x', 'y', 'lane', 'type','speed','pos','lane','slope', 'kondisi'};
    %outputFile = 'Hsimulasitracecount.xlsx';

    %xlswrite(outputFile, outputData, sheet);


    % Write the updated table back to Excel
   %writetable(data, filename, 'Sheet', sheet, 'WriteVariableNames', true);
end

hold off;
    