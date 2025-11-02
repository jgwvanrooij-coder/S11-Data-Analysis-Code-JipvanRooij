files = { ...
    '20250929-s11-2bw+cap-phase[-3GHz].csv', ...
    '20250929-s11-2bw+cap-phase[-3GHz]cyl.csv' ...
    };

labels = { ...
    'Outside cylinder', ...
    'Inside cylinder' ...
    };

colors = {'r','b'};   % outside = red, inside = blue

figure; hold on;


%AI code for column seperation
for k = 1:numel(files)
    % --- Read file as text ---
    fid = fopen(files{k}, 'r');
    raw = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);

    % Skip first 2 header lines
    data_lines = raw{1}(3:end);

    % Split and convert to numeric
    split_data = cellfun(@(x) strsplit(x, ';'), data_lines, 'UniformOutput', false);
    num_data   = cellfun(@(x) str2double(x(1:2)), split_data, 'UniformOutput', false);
    num_data   = vertcat(num_data{:});

    freq_Hz = num_data(:,1);
    S11_dB  = num_data(:,2);

    % --- Find resonance (minimum S11) ---
    [minVal, idx] = min(S11_dB);
    f_res = freq_Hz(idx);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% BEGIN PART ADDED BY CASPAR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    oriS11magniData = freq_Hz;
    oriS11phaseData = S11_dB;

    numPoints1 = length(freq_Hz) % Display these and keep an eye on them being the same
    numPoints2 = length(freq_Hz) % Display these and keep an eye on them being the same

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
    maxFreq = max(freq_Hz)
    phasePerFreq = (minPhase/maxFreq) * 0.95
    for index = 1:numPoints2 % Sequence over all entries in array for procS11phaseData
        procS11phaseData(index) = procS11phaseData(index) - freq_Hz(index)*phasePerFreq; % Replace the values with average linear trend removed. Here it works out that - and - makes +
    end % of index for loop



    S11_2 = procS11phaseData; % Name the phase again S11_2 (now with upwrapped value), such that the plotting below still works





    % --- Plot ---
    h(k) = plot(freq_Hz, S11_2, [colors{k} '-'], 'LineWidth', 3);


   
end

%markers for resonance frequency
yl = ylim;
%plot([f_res f_res], yl, 'k--', 'LineWidth', 3);
ylim(yl);
%plot(f_res, minVal, 'k.', 'MarkerSize', 18);
%text(f_res, minVal, sprintf('  %.2f MHz', f_res/1e6), ...
%        'VerticalAlignment','top', 'FontSize',10, 'Color','k');



xlabel('Frequency (Hz)', 'FontSize', 18, 'FontWeight', 'bold');
ylabel('S11 Magnitude (dB)', 'FontSize', 18, 'FontWeight', 'bold');
title('S11 Magnitude','FontSize', 24, 'FontWeight', 'bold');
legend(h, labels, 'Location', 'best');
grid on;
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';