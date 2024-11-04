clear all; 
close all;
clc; 
% Carregue os dados
dado = importdata('imbi_718_2001_2021.txt');
data = dado.textdata(:, 1);
hora = dado.textdata(:, 2);
altura_zero = dado.data(:, 1);

%datum vertical, enconto o valor nas ficha maregráfica; 
%datum = 5.850;

% Referenciar o dado ao maregrafo de imbituba
%altura_zero =   

% Calcular a nova média após referenciar ao imbituba. 
altura_01 = mean(altura_zero);

% Remover a média dos dados para que esteja em torno do zero.
altura_zero = altura_zero - altura_01;


Fs = 1;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(altura_zero);             % Length of signal
t = (0:L-1)*T;        % Time vector


fft_altura = fft(altura_zero);

P2 = abs(fft_altura/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
% figure
% plot(f,P1) 
title('Single-Sided Amplitude Spectrum of DADO TODO')
xlabel('f (Hz)')
ylabel('|P1(f)|')


% SEGUNDO PLOT APENAS 1 ANO
L_1ano = 6*8760;             % Length of 1 ANO
t = (0:L_1ano-1)*T;        % Time vector


fft_altura_1ano = fft(altura_zero(1:L));

P2_1ano = abs(fft_altura_1ano/L_1ano);
P1_1ano = P2_1ano(1:L_1ano/2+1);
P1_1ano(2:end-1) = 2*P1_1ano(2:end-1);

f_1ano = Fs*(0:(L_1ano/2))/L_1ano;


figure
plot(f_1ano,P1_1ano)
hold on
plot(f,P1) 

title('Single-Sided Amplitude Spectrum of 1 ANO')
xlabel('f (Hz)')
ylabel('|P1(f)|')






% Vetor de períodos correspondentes aos picos de amplitude
periodos = [2.9280, 0.9760, 0.3660, 0.2662, 0.1830, 0.1464, 0.1331, 0.1220, 0.1126, 0.1010, ...
           0.0861, 0.0813, 0.0771, 0.0732, 0.0637, 0.0610, 0.0586, 0.0563, 0.0532, 0.0514, ...
           0.0488, 0.0472, 0.0457, 0.0431, 0.0407, 0.0380, 0.0371, 0.0357, 0.0340, 0.0329, ...
           0.0322, 0.0315, 0.0308, 0.0302, 0.0284, 0.0269, 0.0259, 0.0248, 0.0242];

% Vetor de frequências correspondentes aos picos de amplitude
frequencias = 1 ./ periodos;

% Nome das componentes harmônicas correspondentes aos picos de amplitude
nomes_componentes = {'M1', 'O1', 'K1', 'P1', 'Q1', 'N2', 'M2', 'S2', 'K2', 'Mm', ...
                     'L2', 'N2', 'S2', 'M3', 'M4', 'MS4', 'MN4', 'S4', 'M6', '2MK6', ...
                     'M8', 'MS8', 'M10', '2M12', 'M12', '2MK12', 'M14', 'MS14', 'M16', ...
                     'M18', 'MS18', 'M20', '2MK20', 'M22', 'M24', '2MK26', '2MK28', ...
                     'M30', '2MK30', 'M32', 'M34'};

% Encontrar as componentes harmônicas com período maior ou igual a 1 ano (12 meses)
componentes_maiores_1_ano = nomes_componentes(periodos >= 12);

% Exibir as componentes harmônicas com período maior ou igual a 1 ano e suas frequências correspondentes
disp('Componentes harmônicas com período maior ou igual a 1 ano:');
for i = 1:length(componentes_maiores_1_ano)
    disp([componentes_maiores_1_ano{i}, ': ', num2str(frequencias(periodos >= 12), '%.4f'), ' ciclos por mês']);
end
