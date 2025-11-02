files = { ...
    '20250929-s11-2bw+cap-modulus[-3GHz].csv', ...
    '20250929-s11-2bw+cap-modulus[-3GHz]cyl.csv' ...
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


    % --- Plot ---
    h(k) = plot(freq_Hz, S11_dB, [colors{k} '-'], 'LineWidth', 3);


   
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