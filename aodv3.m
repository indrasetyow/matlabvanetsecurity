% Code: AODV Routing
x = 1:20;
s1 = x(1);
d1 = x(20);
clc;
A = randi([0, 1], 20);  % Assuming a binary adjacency matrix (0 or 1)
A = triu(A) + triu(A, 1).';  % Make the matrix symmetric
A(logical(eye(20))) = 0;  % Set diagonal elements to zero

disp('Adjacency Matrix:');
disp(A);

t = 1:20;
disp('Nodes:');
disp(t);

status(1) = '!';
dist(2:20) = Inf;
next(1:20) = 0;

for i = 2:20
    status(i) = '?';
    dist(i) = A(i, 1);
    next(i) = 1;
    disp(['i == ' num2str(i) ' A(i, 1)=' num2str(A(i, 1)) ' status:=' status(i) ' dist(i)=' num2str(dist(i))]);
end

flag = 0;
for i = 2:20
    if A(1, i) == 1
        disp(['Node 1 sends RREQ to node ' num2str(i)])
        if i == 20 && A(1, i) == 1
            flag = 1;
        end
    end
end
disp(['Flag= ' num2str(flag)]);

while true
    if flag == 1
        break;
    end
    
    temp = 0;
    for i = 1:20
        if status(i) == '?'
            minDist = dist(i);
            vert = i;
            break;
        end
    end
    
    for i = 1:20
        if minDist > dist(i) && status(i) == '?'
            minDist = dist(i);
            vert = i;
        end
    end
    status(vert) = '!';
    
    for i = 1:20
        if status(i) == '!'
            temp = temp + 1;
        end
    end
    
    if temp == 20
        break;
    end
end

i = 20;
count = 1;
route(count) = 20;

while next(i) ~= 1
    disp(['Node ' num2str(i) ' sends RREP message to node ' num2str(next(i))])
    i = next(i);
    count = count + 1;
    route(count) = i;
end

disp(['Node ' num2str(i) ' sends RREP to node 1'])
disp('Node 1')
for i = count:-1:1
    disp(['Sends message to node ' num2str(route(i))])
end
