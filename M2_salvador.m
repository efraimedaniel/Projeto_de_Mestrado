 clear all; 
 close all;
 clc

dado = importdata('salv_708_2004_2021.txt');
data = dado.textdata(:,1);
hora = dado.textdata(:,2);
altura_zero = dado.data(:,1); %em milimetro 
altura = mean(altura_zero);
altura_zero = altura_zero *100;
%converter datas e horas para números
data_hora_str = strcat(data, {' '}, hora);
data_numerica = datenum(data_hora_str, 'dd/mm/yyyy HH:MM');

% Calcular os percentis anuais
% Extrair o ano de cada data
anos = year(datetime(data_numerica, 'ConvertFrom', 'datenum'));
anos_unicos = unique(anos); % Obter os anos únicos presentes nos dados

% Inicializar arrays para armazenar os percentis anuais
percentis = zeros(length(anos_unicos), 13); % 13 percentis, de 0.05 a 99.95

% Calcular os percentis para cada ano
for i = 1:length(anos_unicos)
    ano_atual = anos_unicos(i);
    indices_ano_atual = find(anos == ano_atual); % Índices das datas do ano atual
    alturas_ano_atual = altura_zero(indices_ano_atual); % Alturas correspondentes ao ano atual
    percentis_ano_atual = prctile(alturas_ano_atual, [0.05 0.5 2 5 10 20 50 80 90 95 98 99.5 99.95]); % Calcular percentis
    percentis(i, :) = percentis_ano_atual; % Armazenar os percentis calculados
end


% Agora, 'percentis_reduzidos' contém as séries de percentis reduzidas.

% Encontre a série correspondente ao percentil 50 (mediana)
indice_mediana = 7; % Supondo que a mediana esteja na sétima linha da matriz 'percentis'

% Subtraia os valores dos outros percentis pela série do percentil 50
soma_percentis = sum(percentis, 2); % Soma ao longo das colunas para obter a série de percentis da mediana
percentis_reduzidos = percentis - soma_percentis(indice_mediana, :);

coef = ut_solv(data_numerica, altura_zero, [], -12.9586, 'auto');
[mare_dani00] = ut_reconstr(data_numerica, coef);

% Calcular os percentis para cada ano com mare astronomica ou processado
% por utide
% Calcular os percentis para cada ano
for i = 1:length(anos_unicos)
    ano_atual = anos_unicos(i);
    indices_ano_atual = find(anos == ano_atual); % Índices das datas do ano atual
    alturas_ano_utide = mare_dani00(indices_ano_atual); % Alturas correspondentes ao ano atual
    percentis_ano_atual_utide = prctile(alturas_ano_utide, [0.05:0.05:99.95]); % Calcular percentis
    percentis_utide(i, :) = percentis_ano_atual_utide; % Armazenar os percentis calculados
end


% Calcular os percentis para cada ano com a maré processada pelo UTide
for i = 1:length(anos_unicos)
    ano_atual = anos_unicos(i);
    indices_ano_atual = find(anos == ano_atual); % Índices das datas do ano atual
    alturas_ano_utide = mare_dani00(indices_ano_atual); % Alturas correspondentes ao ano atual
    percentis_ano_atual_utide1 = prctile(alturas_ano_utide, [0.05 0.5 2 5 10 20 50 80 90 95 98 99.5 99.95]); % Calcular percentis
    percentis_ut_01(i, :) = percentis_ano_atual_utide1; % Armazenar os percentis calculados
end

% Subtrair os percentis da maré dos percentis originais
variacoes_residuais = percentis - percentis_ut_01;

% Cálculo do Desvio Padrão das Séries de Percentis Residuais
std_residuals = std(variacoes_residuais, [], 2);

% Visualização dos Desvios Padrão das Séries de Percentis Residuais
figure;
plot(anos_unicos, std_residuals, 'o-', 'LineWidth', 1.5);
xlabel('Ano');
ylabel('Desvio Padrão das Séries de Percentis Residuais');
title('Variabilidade Interanual das Séries de Percentis Residuais');
grid on;

% Plote as variações residuais em um gráfico de série temporal
figure;
plot(variacoes_residuais(:), 'b', 'LineWidth', 1.5);
title('Variações Residuais ao Longo do Tempo');
xlabel('Período (Amostras)');
ylabel('Variações Residuais');
grid on;

% Gráfico de dispersão das variações residuais
figure;
scatter(1:numel(variacoes_residuais), variacoes_residuais(:), 'r', 'filled');
title('Gráfico de Dispersão das Variações Residuais');
xlabel('Período (Amostras)');
ylabel('Variações Residuais');
grid on;

% Boxplot das variações residuais
figure;
boxplot(variacoes_residuais);
title('Boxplot das Variações Residuais');
xlabel('Período');
ylabel('Variações Residuais');
grid on;


% Para cada ano, realizaremos uma análise harmônica separada usando o UTide.

% Inicializar matrizes para armazenar os coeficientes harmônicos para cada ano
coeficientes_harmonicos = cell(length(anos_unicos), 1);
componentes_mare = cell(length(anos_unicos), 1);

% Realizar análise harmônica para cada ano separadamente
for i = 1:length(anos_unicos)
    ano_atual = anos_unicos(i);
    indices_ano_atual = find(anos == ano_atual); % Índices das datas do ano atual
    
    % Extrair alturas do nível do mar para o ano atual
    alturas_ano_atual = altura_zero(indices_ano_atual); 
    
    % Realizar análise harmônica usando o UTide
    coeficientes_harmonicos{i} = ut_solv(data_numerica(indices_ano_atual), ...
                                         alturas_ano_atual, [], -12.9586, 'auto');
    
    % Reconstruir as alturas da maré para o ano atual
    [componentes_mare{i}] = ut_reconstr(data_numerica(indices_ano_atual), coeficientes_harmonicos{i});
end


% Inicializar matrizes para armazenar as principais componentes de maré e seus sinais-ruído para cada ano
principais_componentes = cell(length(anos_unicos), 1);
sinal_ruido = cell(length(anos_unicos), 1);

%{
% Inicializar matrizes para armazenar as amplitudes e fases da componente M2 para cada ano
amplitudes_M2 = zeros(length(anos_unicos), 1);
fases_M2 = zeros(length(anos_unicos), 1);

% Extrair amplitudes e fases da componente M2 para cada ano
for i = 1:length(anos_unicos)
    % Obter os coeficientes harmônicos para o ano atual
    coeficientes_atual = coeficientes_harmonicos{i};
    
    % Encontrar o índice da componente M2 nos coeficientes
    indice_M2 = find(strcmp(coeficientes_atual.name, 'M2'));
    
    % Extrair amplitude e fase da componente M2
    amplitude_M2 = coeficientes_atual.A(indice_M2);
    fase_M2 = coeficientes_atual.g(indice_M2);
    
    % Armazenar amplitude e fase da componente M2 para o ano atual
    amplitudes_M2(i) = amplitude_M2;
    fases_M2(i) = fase_M2;
end

%criar uma tendencia
vetor_tmp_M2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_M2 = vetor_tmp_M2\amplitudes_M2;
b1_M2 = (vetor_tmp_M2*x1_M2);

% Plotar amplitudes da componente M2 ao longo do tempo
figure;
plot(anos_unicos, amplitudes_M2, 'o-', 'LineWidth', 1.5);
hold on
plot(anos_unicos, b1_M2, 'r', 'LineWidth', 1.5);
xlabel('Ano');
ylabel('Amplitude da Componente M2');
title('Amplitude da Componente M2 ao Longo do Tempo');
grid on;

% Plotar fases da componente M2 ao longo do tempo
figure;
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 1.5);
xlabel('Ano');
ylabel('Fase da Componente M2 (graus)');
title('Fase da Componente M2 ao Longo do Tempo');
grid on;

num_percentis = 5; % Defina o número de percentis desejados
percentis_desejados = [5, 25, 50, 75, 95]; % Defina os percentis desejados
%}
%{
% Inicializar matriz para armazenar os percentis de maré para cada ano
percentis_mare = zeros(length(anos_unicos), num_percentis);

% Calcular os percentis de maré para cada ano
for i = 1:length(anos_unicos)
    % Obter as alturas da maré reconstruídas para o ano atual
    alturas_mare_ano_atual = componentes_mare{i};
    
    % Calcular os percentis de maré para o ano atual
    percentis_mare_ano_atual = prctile(alturas_mare_ano_atual, percentis_desejados);
    
    % Armazenar os percentis calculados na matriz
    percentis_mare(i, :) = percentis_mare_ano_atual;
end

% Calcular os percentis anuais para cada ano
percentis_anuais = zeros(length(anos_unicos), num_percentis);

for i = 1:length(anos_unicos)
    % Obter as alturas da maré reconstruídas para o ano atual
    alturas_mare_ano_atual = componentes_mare{i};
    
    % Calcular os percentis anuais para o ano atual
    percentis_ano_atual = prctile(alturas_mare_ano_atual, percentis_desejados);
    
    % Armazenar os percentis anuais calculados na matriz
    percentis_anuais(i, :) = percentis_ano_atual;
end


% Defina o número de percentis desejados
num_percentis = 13; % Por exemplo, 13 percentis de 0.05 a 99.95
percentis_desejados = linspace(0.05, 99.95, num_percentis);

% Inicializar matriz para armazenar os percentis de maré para cada ano
percentis_mare = zeros(length(anos_unicos), num_percentis);

% Calcular os percentis de maré para cada ano
for i = 1:length(anos_unicos)
    % Obter as alturas da maré reconstruídas para o ano atual
    alturas_mare_ano_atual = componentes_mare{i};
    
    % Calcular os percentis de maré para o ano atual
    percentis_mare_ano_atual = prctile(alturas_mare_ano_atual, percentis_desejados);
    
    % Armazenar os percentis calculados na matriz
    percentis_mare(i, :) = percentis_mare_ano_atual;
end

% Inicializar matriz para armazenar as séries de percentis residuais
residual_percentis = zeros(size(percentis));

% Calcular as séries de percentis residuais para cada ano
for i = 1:length(anos_unicos)
    % Obter os percentis anuais e de maré para o ano atual
    percentis_ano_atual = percentis(i, :);
    percentis_mare_ano_atual = percentis_mare(i, :);
    
    % Subtrair os percentis de maré das séries de percentis anuais
    residual_percentis_ano_atual = percentis_ano_atual - percentis_mare_ano_atual;
    
    % Armazenar os percentis residuais calculados na matriz
    residual_percentis(i, :) = residual_percentis_ano_atual;
end

% Realizar ajuste de regressão linear para cada série de percentis residuais
p_values = zeros(1, num_percentis); % Inicializar vetor para armazenar os p-valores

for j = 1:num_percentis
    % Extrair a série de percentis residuais para o percentil atual
    percentis_residuais = residual_percentis(:, j);
    
    % Ajustar o modelo de regressão linear
    modelo = fitlm(anos_unicos, percentis_residuais);
    
    % Obter o p-valor do coeficiente de inclinação (tendência)
    p_values(j) = modelo.Coefficients.pValue(2);
end

% Exibir os resultados
for j = 1:num_percentis
    fprintf('Para o percentil %d, ', j);
    if isnan(p_values(j))
        fprintf('a tendência não é significativa (p-valor = NaN)\n');
    else
        fprintf('a tendência é significativa (p-valor = %.4f)\n', p_values(j));
    end
end


% Definir o tamanho da janela da média móvel centrada
window_size = 30; % 30 dias

% Calcular a média móvel centrada para cada hora de nível do mar
media_movel = movmean(altura_zero, window_size, 'omitnan', 'Endpoints', 'shrink');

% Calcular o número de pontos a serem ignorados nas extremidades
ignored_points = (window_size - 1) / 2;

% Subtrair a média móvel centrada dos dados originais para obter as séries detrendidas
altura_zero_detrended = altura_zero - media_movel;

% Plotar as séries originais e detrendidas para visualização
figure;
plot(data_numerica, altura_zero, 'b', 'LineWidth', 1.5);
hold on;
plot(data_numerica, altura_zero_detrended, 'r', 'LineWidth', 1.5);
xlabel('Data');
ylabel('Altura do Nível do Mar (mm)');
title('Séries Temporais de Altura do Nível do Mar');
legend('Original', 'Detrended');
grid on;

%}


% Inicializar matrizes para armazenar as amplitudes e fases das componentes para cada ano
amplitudes_M2 = zeros(length(anos_unicos), 1);
amplitudes_S2 = zeros(length(anos_unicos), 1);
amplitudes_N2 = zeros(length(anos_unicos), 1);
amplitudes_K1 = zeros(length(anos_unicos), 1);
fases_M2 = zeros(length(anos_unicos), 1);
fases_S2 = zeros(length(anos_unicos), 1);
fases_N2 = zeros(length(anos_unicos), 1);
fases_K1 = zeros(length(anos_unicos), 1); % Corrigido: Adicionando inicialização de fases_M3



% Extrair amplitudes e fases das componentes para cada ano
for i = 1:length(anos_unicos)
    % Obter os coeficientes harmônicos para o ano atual
    coeficientes_atual = coeficientes_harmonicos{i};
    
    % Encontrar os índices das componentes M2, S2, O1 e SA nos coeficientes
    indice_M2 = find(strcmp(coeficientes_atual.name, 'M2'));
    indice_S2 = find(strcmp(coeficientes_atual.name, 'S2'));
    indice_N2 = find(strcmp(coeficientes_atual.name, 'N2'));
    indice_K1 = find(strcmp(coeficientes_atual.name, 'K1'));
    
    % Extrair amplitude e fase das componentes M2, S2, O1 e SA
    amplitude_M2 = coeficientes_atual.A(indice_M2);
    fase_M2 = coeficientes_atual.g(indice_M2);
    
    amplitude_S2 = coeficientes_atual.A(indice_S2);
    fase_S2 = coeficientes_atual.g(indice_S2);
    
    amplitude_N2 = coeficientes_atual.A(indice_N2);
    fase_N2 = coeficientes_atual.g(indice_N2);
    
    amplitude_K1 = coeficientes_atual.A(indice_K1);
    fase_K1 = coeficientes_atual.g(indice_K1);
    
    % Armazenar amplitudes e fases das componentes para o ano atual
    amplitudes_M2(i) = amplitude_M2;
    amplitudes_S2(i) = amplitude_S2;
    amplitudes_N2(i) = amplitude_N2;
    amplitudes_K1(i) = amplitude_K1;
    
    fases_M2(i) = fase_M2;
    fases_S2(i) = fase_S2;
    fases_N2(i) = fase_N2;
    fases_K1(i) = fase_K1; % Corrigido: Atribuindo a fase_SA a fases_M3
end

%criar uma tendencia para todas componentes mais relevante
vetor_tmp_M2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_M2 = vetor_tmp_M2\amplitudes_M2;
b1_M2 = (vetor_tmp_M2*x1_M2);

% Calcular a variação total das amplitudes das componentes de marés nos últimos 50 anos

var_total_M2 = max(amplitudes_M2) - min(amplitudes_M2); % Supondo que os dados estejam organizados em ordem cronológica

% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_M2 = var_total_M2 / anos_anos_unicos;
%
vetor_tmp_S2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_S2 = vetor_tmp_S2\amplitudes_S2;
b1_S2 = (vetor_tmp_S2*x1_S2);

var_total_S2 = max(amplitudes_S2) - min(amplitudes_S2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_S2 = var_total_S2 / anos_anos_unicos;

vetor_tmp_N2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_N2 = vetor_tmp_N2\amplitudes_N2;
b1_N2 = (vetor_tmp_N2*x1_N2);

var_total_N2 = max(amplitudes_N2) - min(amplitudes_N2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_N2 = var_total_N2 / anos_anos_unicos;
%
vetor_tmp_K1 = [ones(length(anos_unicos), 1) anos_unicos];
x1_K1 = vetor_tmp_K1\amplitudes_K1;
b1_K1 = (vetor_tmp_K1*x1_K1);
%
var_total_K1 = max(amplitudes_K1) - min(amplitudes_K1); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_K1 = var_total_K1 / anos_anos_unicos;


%criar uma tendencia para todas as fases mais relevante
%
vetor_fase_M2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_M2 = vetor_fase_M2 \ fases_M2;
b1_fase_M2 = (vetor_fase_M2 * x1_fase_M2);
%
var_total_fase_M2 = max(fases_M2) - min(fases_M2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_M2 = var_total_fase_M2 / anos_anos_unicos;
%
vetor_fase_S2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_S2 = vetor_fase_S2 \ fases_S2;
b1_fase_S2 = (vetor_fase_S2 * x1_fase_S2);
%
var_total_fase_S2 = max(fases_S2) - min(fases_S2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_S2 = var_total_fase_S2 / anos_anos_unicos;
%
vetor_fase_N2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_N2 = vetor_fase_N2 \ fases_N2;
b1_fase_N2 = (vetor_fase_N2 * x1_fase_N2);
%
var_total_fase_N2 = max(fases_N2) - min(fases_N2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_N2 = var_total_fase_N2 / anos_anos_unicos;
%
vetor_fase_K1 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_K1 = vetor_fase_K1 \ fases_K1;
b1_fase_K1 = (vetor_fase_K1 * x1_fase_K1);
%
var_total_fase_K1 = max(fases_K1) - min(fases_K1); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_K1 = var_total_fase_K1 / anos_anos_unicos;


% Criar subplot para as amplitudes
% Criar subplot para as amplitudes
figure('PaperSize',[20 20],...
       'PaperUnits','centimeters',...
       'InvertHardcopy','on',...
       'PaperPosition',[0 0 20 20],...
       'PaperPositionMode','auto',...
       'Position',[80 80 1800 900]);

subplot(2, 4, 1);
plot(anos_unicos, amplitudes_M2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_M2, 'LineWidth', 2);
title('Amplitude M2 em Salvador');
xlabel('Ano');
ylabel('Amplitude da M2 (cm)');
grid on;
% Adicionar legenda com rótulos explicativos
legend('Amplitude da M2', 'Tendência da M2', 'FontSize', 8);
% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(max(anos_unicos), min(amplitudes_M2), sprintf(' = %.3f cm/ano', taxa_anual_M2),...
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
%
subplot(2, 4, 2);
plot(anos_unicos, amplitudes_S2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_S2, 'LineWidth', 2);
title('Amplitude S2 em Salvador');
xlabel('Ano');
ylabel('Amplitude da S2 (cm)');
legend('Amplitude da S2', 'Tendência da S2', 'FontSize', 8);
grid on;

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(max(anos_unicos), min(amplitudes_S2), sprintf(' = %.3f cm/ano', taxa_anual_S2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);

subplot(2, 4, 3);
plot(anos_unicos, amplitudes_N2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_N2, 'LineWidth', 2);
title('Amplitude O1 em Salvador');
xlabel('Ano');
ylabel('Amplitude da N2 (cm)');
legend('Amplitude da N2', 'Tendência da O1', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(amplitudes_N2), sprintf(' = %.3f cm/ano', taxa_anual_N2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);



subplot(2, 4, 4);
plot(anos_unicos, amplitudes_K1, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_K1, 'LineWidth', 2);
title('Amplitude K1 em Salvador');
xlabel('Ano');
ylabel('Amplitude da K1 (cm)');
legend('Amplitude da K1', 'Tendência da K1', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(amplitudes_K1), sprintf(' = %.3f cm/ano', taxa_anual_K1),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


% Criar subplot para as fases
subplot(2, 4, 5);
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_M2, 'LineWidth', 2);
title('Fase da M2 em Salvador');
xlabel('Ano');
ylabel('Fase (graus)');
legend('Fase da M2', 'Tendência da M2', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(fases_M2), sprintf(' = %.3f °/ano', taxa_anual_fase_M2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


subplot(2, 4, 6);
plot(anos_unicos, fases_S2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_S2, 'LineWidth', 2);
title('Fase da S2 em Salvador');
xlabel('Ano');
ylabel('Fase (graus)');
legend('Fase da S2', 'Tendência da S2', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(fases_S2), sprintf(' = %.3f °/ano', taxa_anual_fase_S2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


subplot(2, 4, 7);
plot(anos_unicos, fases_N2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_N2, 'LineWidth', 2);
title('Fase da N2 em Salvador');
xlabel('Ano');
ylabel('Fase (graus)');
legend('Fase da N2', 'Tendência da N2', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(fases_N2), sprintf(' = %.3f °/ano', taxa_anual_fase_N2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
%
subplot(2, 4, 8);
plot(anos_unicos, fases_K1, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_K1, 'LineWidth', 2);
title('Fase da K1 em Salvador');
xlabel('Ano');
ylabel('Fase (graus)');
legend('Fase da K1', 'Tendência da K2', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(fases_K1), sprintf(' = %.3f °/ano', taxa_anual_fase_K1),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
%
% Define o tamanho da figura (por exemplo, 10 polegadas de largura e 6 polegadas de altura)
largura = 12; % polegadas
altura = 6; % polegadas
set(gcf, 'Units', 'inches', 'Position', [0, 0, largura, altura]);

% Salva a figura com o tamanho especificado
saveas(gcf, 'Componente_M2_Salvador.png');