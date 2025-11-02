
clear; close all; clc;

% --- Files to plot ---
mod = '20251710-bare-dips-mod.csv';
phase = '20251710-bare-dips-phase.csv';   
 

%% --- Read both datasets ---
[freq1, S11_1] = read_s11_csv(mod);
[freq2, S11_2] = read_s11_csv(phase);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BEGIN PART ADDED BY CASPAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

oriS11magniData = S11_1;
oriS11phaseData = S11_2;

numPoints1 = length(freq1) % Display these and keep an eye on them being the same
numPoints2 = length(freq2) % Display these and keep an eye on them being the same

procS11magniData = zeros(numPoints1,1);  % Just defining them as empty arrays first is healthy
procS11phaseData = zeros(numPoints2,1);  % Just defining them as empty arrays first is healthy

unwrapCounter = 0; % In the for loop below, this counter goes up with one if the code detects a
                   % jump in the S11 phase from about -180 to about +180.
                   % Note that the code only works for upward phase jumps of 360 (of 2 pi)

for index = 2:numPoints2 % Sequence over all entrues in array for oriS11phaseData
                         % Skip the process for the first entry, since it compares to previuous point
    prevPntPhase = oriS11phaseData(index-1);
    currPntPhase = oriS11phaseData(index);
 
    if currPntPhase - prevPntPhase > 200   %  It detects up jump if the phase is suddendly higher by 200 or more (change this value if you useful) 
        unwrapCounter = unwrapCounter + 1;
    end % if

    procS11phaseData(index) = oriS11phaseData(index) - unwrapCounter*360; 

end % of index for loop




%%% (UN)COMMENT THE 6 LINES BELOW IF YOU DO (NOT) WANT TO SUBTRACT THE AVERAGE LINEAR TREND FROM THE UNWRAPPED PHASE
minPhase = min(procS11phaseData)
maxFreq = max(freq2)
phasePerFreq = (minPhase/maxFreq) * 0.99;
for index = 1:numPoints2 % Sequence over all entries in array for procS11phaseData
    procS11phaseData(index) = procS11phaseData(index) - freq2(index)*phasePerFreq; % Replace the values with average linear trend removed. Here it works out that - and - makes +
end % of index for loop



S11_2 = procS11phaseData; % Name the phase again S11_2 (now with upwrapped value), such that the plotting below still works



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% END PART ADDED BY CASPAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[minVal1, idx1] = min(S11_1);
[minVal2, idx2] = min(S11_2);
f_res1 = freq1(idx1);
f_res2 = freq2(idx2);







figure('Name','S11 Magnitude Comparison','Color','w');


Modulus = 10.^(-S11_1/20);

subplot(2,1,1);
plot(freq1, S11_1, 'r-', 'LineWidth', 1.6); hold on; grid on;
%yl = ylim;
%plot([f_res1 f_res1], yl, 'k--', 'LineWidth', 1.2); ylim(yl);

xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('S11 magnitude (dB)', 'FontSize', 12);
title('S11 Magnitude', 'FontSize', 14, 'FontWeight', 'bold');
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';


subplot(2,1,2);
plot(freq2, S11_2, 'b-', 'LineWidth', 1.6); hold on; grid on;
%yl = ylim;
%plot([f_res1 f_res1], yl, 'k--', 'LineWidth', 1.2); ylim(yl);

xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('Phase (degrees)', 'FontSize', 12);
title('S11 Phase', 'FontSize', 14, 'FontWeight', 'bold');
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';

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
            num_data(end+1,:) = vals(1:2);
        end
    end
    
    freq_Hz = num_data(:,1);
    S11_dB  = num_data(:,2);
end

