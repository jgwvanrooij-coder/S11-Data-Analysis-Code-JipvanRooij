clear; close all; clc;

% --- Files to plot ---
mod   = '20250926-s11-4bw3+cap-modulus.csv';

% Put your phase files here (add more later)
phaseFiles = { ...
    '20250925-s11-1bondwPCB-phase.csv', ...
     '20250925-s11-2bondwPCB-phase.csv', ...
     '20250925-s11-3bondwPCB-phase.csv', ...
     '20250925-s11-4bondwPCB-phase.csv', ...
     '20250925-s11-5bondwPCB-phase.csv'};

%% --- Read modulus dataset once ---
[freq1, S11_1] = read_s11_csv(mod);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read + process each phase dataset in a loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
freq2_all = cell(numel(phaseFiles),1);
S11_2_all = cell(numel(phaseFiles),1);

for k = 1:numel(phaseFiles)
    phase = phaseFiles{k};
    [freq2, S11_2] = read_s11_csv(phase);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% BEGIN PART ADDED BY CASPAR (looped)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    oriS11magniData  = S11_1;  %#ok<NASGU>   % kept for completeness; not used below
    oriS11phaseData  = S11_2;

    numPoints1 = length(freq1); %#ok<NASGU>   % can print/inspect if desired
    numPoints2 = length(freq2);               % can print/inspect if desired

    procS11magniData = zeros(numPoints1,1); %#ok<NASGU>
    procS11phaseData = zeros(numPoints2,1);

    unwrapCounter = 0;

    for index = 2:numPoints2
        prevPntPhase = oriS11phaseData(index-1);
        currPntPhase = oriS11phaseData(index);

        if currPntPhase - prevPntPhase > 200
            unwrapCounter = unwrapCounter + 1;
        end
        procS11phaseData(index) = oriS11phaseData(index) - unwrapCounter*360;
    end

    % % (UN)COMMENT THE 6 LINES BELOW IF YOU DO (NOT) WANT TO SUBTRACT THE AVERAGE LINEAR TREND
    % minPhase     = min(procS11phaseData); %#ok<NASGU>
    % maxFreq      = max(freq2);
    % phasePerFreq = (min(procS11phaseData)/maxFreq) * 1;  % uses minPhase/maxFreq as in your code
    % 
    % for index = 1:numPoints2
    %     procS11phaseData(index) = procS11phaseData(index) - freq2(index)*phasePerFreq;
    % end

    S11_2 = procS11phaseData;  % same name as before, now processed for this file

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% END PART ADDED BY CASPAR (looped)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Store for plotting
    freq2_all{k} = freq2;
    S11_2_all{k} = S11_2;
end

% (Optional) find minima for the first file (or loop similarly if you want per-file)
[minVal1, idx1] = min(S11_1);           %#ok<NASGU>
f_res1 = freq1(idx1);
[minVal2, idx2] = min(S11_2_all{1});    %#ok<NASGU>
f_res2 = freq2_all{1}(idx2);

figure('Name','S11 Magnitude Comparison','Color','w');

% % ---- Magnitude subplot (single file as before) ----
% subplot(2,1,1);
% plot(freq1, S11_1, 'r-', 'LineWidth', 1.6); hold on; grid on;
% xlabel('Frequency (Hz)', 'FontSize', 12);
% ylabel('S11 magnitude (dB)', 'FontSize', 12);
% title('S11 Magnitude', 'FontSize', 14, 'FontWeight', 'bold');
% ax = gca; ax.XMinorGrid = 'on'; ax.YMinorGrid = 'on';

% ---- Phase subplot (all files) ----
subplot(2,1,2); hold on; grid on;
for k = 1:numel(phaseFiles)
    plot(freq2_all{k}, S11_2_all{k}, 'LineWidth', 1.6, 'DisplayName', sprintf('Phase %d', k));
end
%xlim([0 2e9])
xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('Phase (degrees)', 'FontSize', 12);
title('S11 Phase (unwrapped / detrended)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location','best');
ax = gca; ax.XMinorGrid = 'on'; ax.YMinorGrid = 'on';

%% -------- Helper function --------
function [freq_Hz, S11_dB] = read_s11_csv(filename)
    % Reads a CSV with two numeric columns: frequency [Hz]; S11 magnitude [dB]
    fid = fopen(filename, 'r');
    if fid < 0
        error('Cannot open file: %s', filename);
    end
    raw = textscan(fid, '%s', 'Delimiter', '\n'); 
    fclose(fid);
    lines = raw{1};

    % Skip potential header lines
    data_lines = lines(3:end);
    split_data = cellfun(@(x) strsplit(x, ';'), data_lines, 'UniformOutput', false);

    % Safely parse numeric data
    num_data = [];
    for i = 1:numel(split_data)
        vals = str2double(split_data{i});
        if numel(vals) >= 2 && all(isfinite(vals(1:2)))
            num_data(end+1,:) = vals(1:2); %#ok<AGROW>
        end
    end

    freq_Hz = num_data(:,1);
    S11_dB  = num_data(:,2);
end
