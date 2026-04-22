clc
clearvars  % 比clear all更高效，只清除变量不清除函数和路径
close all;
%% 读入数据
file_path = 'D:\rawam\research work\Experiment\Droplet\mine\dodecane (C12H26)\5 atm\matlab\';  % 文件路径
file_name = 'All_data-gw80.xlsx';                               % 文件名
full_path = fullfile(file_path, file_name);                % 完整路径
pressure = '5atm';                                        % 压力参数

% 读取数据（保持原有逻辑）
Bouncing_data_original = xlsread(full_path, pressure, 'A:B');
Coalescence_data_original = xlsread(full_path, pressure, 'G:H');
Reflective_data_original = xlsread(full_path, pressure, 'M:N');
Stretching_data_original = xlsread(full_path, pressure, 'S:T');

% 合并数据（保持原有逻辑）
Other_data_original = cat(1, Coalescence_data_original, Reflective_data_original, Stretching_data_original);

% 直接对整个矩阵的列进行加减操作，无需逐行循环
Bouncing_data = Bouncing_data_original;  % 先复制原始数据
Bouncing_data(:, 1) = Bouncing_data(:, 1);    % 第一列全部+1/-1
Bouncing_data(:, 2) = Bouncing_data(:, 2);% 第二列全部-0.015/+0.015

Other_data = Other_data_original;        % 先复制原始数据
Other_data(:, 1) = Other_data(:, 1);% 第一列全部+1/-1
Other_data(:, 2) = Other_data(:, 2);% 第二列全部-0.015/+0.015

% （可选）如果需要保留原有的计数逻辑，仍可保留，但不影响速度
Bouncing_number = size(Bouncing_data_original, 1);  % 用size替代length更严谨
Other_number = size(Other_data_original, 1);
All_number = Bouncing_number + Other_number;

%% 循环参数初始化
we_all = [];
b_all = [];
count = 0;
jilu_all = [];  % 初始化记录数组，避免未定义警告
% ========== 新增：初始化has_abnormal数值记录数组 ==========
abnormal_record = [];  % 存储格式：[aa, bb, cc, has_abnormal数值]
record_index = 0;      % 记录数组的索引计数器

% 四重循环遍历参数
for aa = 0.1:0.1:2.5
for bb = 0.1:0.1:3.5
for cc = 0.9:0.01:1.1
            % 每次进入新的cc循环，先清空we_all和b_all，避免上一轮数据干扰
            we_all = [];
            b_all = [];
            
            % 遍历b参数，生成we_all和b_all
            for b = 0:0.0001:0.9
                n = round(b*10000 + 1);
                t = 2*(1 - b);
                fai = aa*b^bb + cc;
                fai_1 = 1*2*(6/fai - 2)^(1/3) + ((6/fai - 2)^(-2/3));
                
                if t > 1
                    x = 1 - 0.25*((2 - t)^2)*(1 + t);
                else
                    x = 0.25*(t^2)*(3 - t);
                end
                
                we = (8*(fai_1 - 3))/(x*(1 - b^2)); 
                we_all(n,:) = we;
                b_all(n,:) = b;
            end
            
            % ========== 核心修改：检测异常并跳过无效参数组合 ==========
            % 1. 先去除we_all和b_all中的空值（避免索引异常）
            valid_idx = ~isnan(we_all) & ~isnan(b_all);
            we_valid = we_all(valid_idx);
            b_valid = b_all(valid_idx);
            
            % 2. 检测是否存在"we递增但b递减"的异常情况
            has_abnormal = false;
            if length(we_valid) > 1
                for i = 2:length(we_valid)
                    % 判断条件：we_all(n+1) > we_all(n) 且 b_all(n+1) < b_all(n)
                    if we_valid(i) < we_valid(i-1)
                        has_abnormal = true;
                        break;  % 只要发现一个异常，立即终止检测
                    end
                end
            end
            
            % ========== 新增：将has_abnormal转换为数值并存储 ==========
            record_index = record_index + 1;
            % MATLAB中 true=1，false=0，直接转换为数值存入数组
            abnormal_record(record_index, :) = [aa, bb, cc, double(has_abnormal)];
            
            % 3. 如果存在异常，跳过当前aa、bb、cc组合的后续计算
            if has_abnormal
                continue;  % 直接进入下一个cc循环，不执行误差计算/绘图/记录
            end
            
            % ========== 原有逻辑：仅处理无异常的参数组合 ==========
            kk = 1;
            oo = 1;
            error_Bouncing = [];
            
            for ii = 1:Bouncing_number
                for jj = 1:length(we_all)
                    if (we_all(jj)-Bouncing_data(ii,1)<0) && (b_all(jj)-Bouncing_data(ii,2)>0)
                        error_Bouncing(kk,:) = Bouncing_data(ii,:);
                        kk = kk + 1;
                        break
                    end
                end
            end
            
            error_Other = [];
            for mm = 1:Other_number
                for nn = 1:length(we_all)
                    if (we_all(nn)-Other_data(mm,1)>0) && (b_all(nn)-Other_data(mm,2)<0)
                        error_Other(oo,:) = Other_data(mm,:);
                        oo = oo + 1;
                        break
                    end
                end
            end
            
            count = count + 1;
            jingdu_Bouncing = 1 - length(error_Bouncing)/Bouncing_number;
            jingdu_Other = 1 - length(error_Other)/Other_number;
            jingdu = 1 - (length(error_Bouncing)+length(error_Other))/(Bouncing_number+Other_number);
            jilu_all(count,:) = [aa bb cc jingdu_Bouncing jingdu_Other jingdu];
            
            plot(we_all,b_all); hold on
        end
    end
end
%% 作图
plot(Bouncing_data(:,1),Bouncing_data(:,2),'o');
plot(Other_data(:,1),Other_data(:,2),'*');
xlim([0 50]);
ylim([0 1]);
xlabel('We');
ylabel('B');