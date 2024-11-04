clear
%cd ~/Desktop/Daniel
cd('D:/Sazonalidade');
%
load Cananeia_01.mat
%
clf
subplot(211)
tmp=smoothdata(ciclo_anual,'lowess',6);
[p,f] = spec(tmp,1/12,1);
loglog(f,p)
grid
subplot(212)
plot(ciclo_anual)
hold on
plot(tmp,'r')
%grid on
% Compute the autocovariance function
autocov = xcorr(ciclo_anual, 'biased');

% Apply smoothing to the autocovariance function (adjust the window size as needed)
smoothed_autocov = smoothdata(autocov, 'gaussian', 47);


% Compute the Fourier transform of the smoothed autocovariance function
fourier_spectrum = abs(fft(smoothed_autocov));

% Compute the corresponding frequencies
N = length(fourier_spectrum);
sampling_frequency = 1; % Assuming the data is sampled once per year
frequencies = (0:N-1) / N * sampling_frequency;

% Plot the Fourier spectrum with logarithmic scale on y-axis
semilogy(frequencies, fourier_spectrum);
xlabel('Frequency (cycles/month)');
ylabel('Magnitude (cm^2/month)');
title('Fourier Spectrum of Smoothed Autocovariance Function');
xlim([0 0.2]); % Limit x-axis to 0.2 cycles/year



% Dados e parâmetros
N = length(ciclo_anual); % Número de dados
fs = 12; % Frequência de amostragem (mensal)
T = 1/fs; % Período de amostragem
t = (0:N-1)*T; % Vetor de tempo

% Transformada de Fourier
Y = fft(ciclo_anual);
P2 = abs(Y/N); % Normalizar o espectro
P1 = P2(1:N/2+1); % Pegar apenas a metade positiva
P1(2:end-1) = 2*P1(2:end-1); % Ajuste de amplitude

f = fs*(0:(N/2))/N; % Vetor de frequências

% Plotar o espectro
figure;
loglog(f, P1);
xlabel('Frequência (ciclos/mês)');
ylabel('Magnitude');
title('Espectro de Fourier do Sinal da Maré');
grid on;

% Marcar frequências características
hold on;
xline(1/29.53, '--r', 'Ciclo Lunar (Mensal)'); % Ciclo lunar
xline(1/12, '--g', 'Ciclo Sazonal'); % Ciclo sazonal
xline(1/27.55, '--b', 'Ciclo Perigeano'); % Ciclo perigeano
xline(1/223, '--m', 'Ciclo Nodal'); % Ciclo nodal
xline(1, '--k', 'Ciclo Anual'); % Ciclo anual

% Ajustar limites do eixo x para incluir o ciclo nodal
xlim([1/300 1/10]); % Ajustar os limites do eixo x para visualizar ciclos de baixa frequência
