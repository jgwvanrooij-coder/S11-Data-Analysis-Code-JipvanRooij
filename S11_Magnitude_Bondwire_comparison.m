%% Compare S11 magnitude vs frequency for 1–5 bondwires
% Put this script in the same folder as the CSVs or use full paths.


files = { ...
    '20250925-s11-1bondwPCB-peak-1.59GHzmodulus.csv', ...
   '20250929-s11-2bw+cap-modulus[-3GHz].csv', ...
    '20250929-s11-3bw+cap-modulus[-3GHz].csv',...
    '20250929-s11-4bw+cap-modulus[-3GHz].csv'}%, ...
    % '20250925-s11-5bondwPCB-modulus.csv'};

labels = { ...
    '1 bw', ...
    '2 bw', ...
    '3 bw', ...
         '4 bw'}, ...
    % '5 bw'};


figure('Name', 'S11 Magnitude of PCB With Sample');
hold on; grid on;

for k = 1:numel(files)
    [freq_Hz, S11_dB] = read_s11_csv(files{k});
    plot(freq_Hz, S11_dB, 'LineWidth', 3);
end

xlabel('Frequency (Hz)', 'FontSize', 18, 'FontWeight', 'bold');
ylabel('S11 Magnitude (dB)', 'FontSize', 18, 'FontWeight', 'bold');
title('S11 Magnitude of PCB With Sample', 'FontSize', 18);
legend(labels, 'Location', 'best', 'Interpreter', 'none');
xlim([0 2e9]);
%ylim([-15 1]);
% axis tight;


% ------------------------------------------------------------




%% -------- Helper: robust reader for your CSV format --------
function [freq_Hz, S11_dB] = read_s11_csv(filename)
%READ_S11_CSV Robustly read "<freq>; <S11_dB>; ..." with metadata header.
% Handles lines starting with '#', a header like "freq[Hz];Trc1_S11[dB];",
% and trailing semicolons.

    freq_Hz = []; S11_dB = [];

    fid = fopen(filename, 'r');
    if fid == -1
        warning('Cannot open file: %s', filename);
        return;
    end

    % Read all lines
    C = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
    fclose(fid);
    if isempty(C) || isempty(C{1})
        return;
    end
    lines = C{1};

    % Find where the numeric data starts.
    % Preferred: line after a header line containing 'freq' and a semicolon.
    headerIdx = find(contains(lower(lines), 'freq') & contains(lines, ';'), 1, 'first');
    if ~isempty(headerIdx)
        startIdx = headerIdx + 1;
    else
        % Fallback: first line that looks like "number;number"
        pat = '^\s*[-+]?(\d+(\.\d+)?([eE][-+]?\d+)?)[\s]*;[\s]*[-+]?(\d+(\.\d+)?([eE][-+]?\d+)?)';
        startIdx = find(~cellfun('isempty', regexp(lines, pat, 'once')), 1, 'first');
        if isempty(startIdx); return; end
    end

    dataLines = lines(startIdx:end);

    % Fast path: try textscan from the beginning with HeaderLines
    try
        fid2 = fopen(filename, 'r');
        % Skip startIdx-1 lines
        raw = textscan(fid2, '%f%f%*[^\n]', 'Delimiter', ';', ...
                       'HeaderLines', startIdx-1, 'MultipleDelimsAsOne', true);
        fclose(fid2);
        if ~isempty(raw) && numel(raw) >= 2
            freq_Hz = raw{1};
            S11_dB  = raw{2};
            % Clean NaNs (in case there are blank lines)
            mask = ~(isnan(freq_Hz) | isnan(S11_dB));
            freq_Hz = freq_Hz(mask);
            S11_dB  = S11_dB(mask);
            if ~isempty(freq_Hz); return; end
        end
    catch
        % fall through to manual parse
    end

    % Manual parse fallback
    f = []; s11 = [];
    for i = 1:numel(dataLines)
        parts = strsplit(strtrim(dataLines{i}), ';');
        if numel(parts) < 2, continue; end
        a = str2double(parts{1});
        b = str2double(parts{2});
        if ~isnan(a) && ~isnan(b)
            f(end+1,1)   = a; %#ok<AGROW>
            s11(end+1,1) = b; %#ok<AGROW>
        end
    end

    freq_Hz = f; S11_dB = s11;
end
