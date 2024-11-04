clear all; 
close all;
clc

dado = importdata('bele_229_2019_2022.txt');
data = dado.textdata(:,1);
hora = dado.textdata(:,2);
altura_zero = dado.data(:,1); %em milimetro 
altura_zero = altura_zero * 100;

%converter datas e horas para números
data_hora_str = strcat(data, {' '}, hora);
data_numerica = datenum(data_hora_str, 'dd/mm/yyyy HH:MM');

% Calcular os percentis anuais
% Extrair o ano de cada data
anos = year(datetime(data_numerica, 'ConvertFrom', 'datenum'));
anos_unicos = unique(anos); % Obter os anos únicos presentes nos dados

%{
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

coef = ut_solv(data_numerica, altura_zero, [], -1.4423, 'auto');
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
%}

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
                                         alturas_ano_atual, [], -1.4423, 'auto');
    
    % Reconstruir as alturas da maré para o ano atual
    [componentes_mare{i}] = ut_reconstr(data_numerica(indices_ano_atual), coeficientes_harmonicos{i});
end

% Agora temos os coeficientes harmônicos e as alturas da maré reconstruídas para cada ano.
% Podemos utilizar essas informações para análises adicionais, se necessário.
% Inicializar matrizes para armazenar as principais componentes de maré e seus sinais-ruído para cada ano
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

% Plotar amplitudes da componente M2 ao longo do tempo
figure;
plot(anos_unicos, amplitudes_M2, 'o-', 'LineWidth', 1.5);
xlabel('Ano');
ylabel('Amplitude da Componente M2 (cm)');
title('Amplitude da Componente M2 em Belém');
grid on;

% Plotar fases da componente M2 ao longo do tempo
figure;
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 1.5);
xlabel('Ano');
ylabel('Fase da Componente M2 (graus) ');
title('Fase da Componente M2 em Belém');
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
% Criar figura para subplots
%figure;
%{
% Criar subplot para as amplitudes
subplot(2, 4, 1);
plot(anos_unicos, amplitudes_M2, 'o-', 'LineWidth', 2);
title('Amplitude M2 em Belém');
xlabel('Ano');
ylabel('Amplitude da M2 (cm)');
grid on;

subplot(2, 4, 2);
plot(anos_unicos, amplitudes_S2, 'o-', 'LineWidth', 2);
title('Amplitude S2 em Belém');
xlabel('Ano');
ylabel('Amplitude da S2 (cm)');
grid on;

subplot(2, 4, 3);
plot(anos_unicos, amplitudes_N2, 'o-', 'LineWidth', 2);
title('Amplitude N2 em Belém');
xlabel('Ano');
ylabel('Amplitude da N2 (cm)');
grid on;

subplot(2, 4, 4);
plot(anos_unicos, amplitudes_K1, 'o-', 'LineWidth', 2);
title('Amplitude M3 em Belém');
xlabel('Ano');
ylabel('Amplitude da K1 (cm)');
grid on;

% Criar subplot para as fases
subplot(2, 4, 5);
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 2);
title('Fase da M2 Belém');
xlabel('Ano');
ylabel('Fase (graus)');
grid on;

subplot(2, 4, 6);
plot(anos_unicos, fases_S2, 'o-', 'LineWidth', 2);
title('Fase da S2 em Belém');
xlabel('Ano');
ylabel('Fase (graus)');
grid on;

subplot(2, 4, 7);
plot(anos_unicos, fases_N2, 'o-', 'LineWidth', 2);
title('Fase da N2 em Belém');
xlabel('Ano');
ylabel('Fase (graus)');
grid on;

subplot(2, 4, 8);
plot(anos_unicos, fases_K1, 'o-', 'LineWidth', 2);
title('Fase da K1 em Belém');
xlabel('Ano');
ylabel('Fase (graus)');
grid on
%}
%criar uma tendencia para todas componentes mais relevante
%{
vetor_tmp_M2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_M2 = vetor_tmp_M2\amplitudes_M2;
b1_M2 = (vetor_tmp_M2*x1_M2);

% Calcular a variação total das amplitudes das componentes de marés nos últimos 50 anos

var_total_M2 = max(amplitudes_M2) - min(amplitudes_M2); % Supondo que os dados estejam organizados em ordem cronológica

% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_M2 = var_total_M2 / anos_anos_unicos;
var_b1_linear_M2 = (b1_M2(end) - b1_M2(1)) / anos_anos_unicos; % taxa anual da tendencia liner de variacao da M2
%
vetor_tmp_S2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_S2 = vetor_tmp_S2\amplitudes_S2;
b1_S2 = (vetor_tmp_S2*x1_S2);

var_total_S2 = max(amplitudes_S2) - min(amplitudes_S2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_S2 = var_total_S2 / anos_anos_unicos;
var_b1_linear_S2 = (b1_S2(end) - b1_S2(1)) / anos_anos_unicos; % taxa anual da tendencia liner de variacao da M2


vetor_tmp_N2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_N2 = vetor_tmp_N2\amplitudes_N2;
b1_N2 = (vetor_tmp_N2*x1_N2);

var_total_N2 = max(amplitudes_N2) - min(amplitudes_N2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_N2 = var_total_N2 / anos_anos_unicos;
var_b1_linear_N2 = (b1_N2(end) - b1_N2(1)) / anos_anos_unicos; % taxa anual da tendencia liner de variacao da M2
%
vetor_tmp_K1 = [ones(length(anos_unicos), 1) anos_unicos];
x1_K1 = vetor_tmp_K1\amplitudes_K1;
b1_K1 = (vetor_tmp_K1*x1_K1);
%
var_total_K1 = max(amplitudes_K1) - min(amplitudes_K1); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_K1 = var_total_K1 / anos_anos_unicos;
var_b1_linear_K1 = (b1_K1(end) - b1_K1(1)) / anos_anos_unicos; % taxa anual da tendencia liner de variacao da M2

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
var_reg_linear_M2 = (b1_fase_M2(end) - b1_fase_M2(1)) / anos_anos_unicos; % taxa anual da tendencia liner de variacao da M2
%
vetor_fase_S2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_S2 = vetor_fase_S2 \ fases_S2;
b1_fase_S2 = (vetor_fase_S2 * x1_fase_S2);
%
var_total_fase_S2 = max(fases_S2) - min(fases_S2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_S2 = var_total_fase_S2 / anos_anos_unicos;
var_reg_linear_S2 = (b1_fase_S2(end) - b1_fase_S2(1)) / anos_anos_unicos; % taxa anual da tendencia liner de variacao da M2
%
vetor_fase_N2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_N2 = vetor_fase_N2 \ fases_N2;
b1_fase_N2 = (vetor_fase_N2 * x1_fase_N2);
%
var_total_fase_N2 = max(fases_N2) - min(fases_N2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_N2 = var_total_fase_N2 / anos_anos_unicos;
var_reg_linear_N2 = (b1_fase_N2(end) - b1_fase_N2(1)) / anos_anos_unicos; % taxa anual da tendencia liner de variacao da M2
%
vetor_fase_K1 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_K1 = vetor_fase_K1 \ fases_K1;
b1_fase_K1 = (vetor_fase_K1 * x1_fase_K1);
%
var_total_fase_K1 = max(fases_K1) - min(fases_K1); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_K1 = var_total_fase_K1 / anos_anos_unicos;
var_reg_linear_K1 = (b1_fase_K1(end) - b1_fase_K1(1)) / anos_anos_unicos; % taxa anual da tendencia liner de variacao da M2

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
title('Amplitude M2 em Belém');
xlabel('Ano');
ylabel('Amplitude da M2 (cm)');
grid on;
% Adicionar legenda com rótulos explicativos
legend('Amplitude da M2', 'Tendência da M2', 'FontSize', 8);
% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(max(anos_unicos), min(amplitudes_M2), sprintf(' = %.3f cm/ano', var_b1_linear_M2),...
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
%
subplot(2, 4, 2);
plot(anos_unicos, amplitudes_S2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_S2, 'LineWidth', 2);
title('Amplitude S2 em Belém');
xlabel('Ano');
ylabel('Amplitude da S2 (cm)');
legend('Amplitude da S2', 'Tendência da S2', 'FontSize', 8);
grid on;

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(max(anos_unicos), min(amplitudes_S2), sprintf(' = %.3f cm/ano', var_b1_linear_S2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);

subplot(2, 4, 3);
plot(anos_unicos, amplitudes_N2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_N2, 'LineWidth', 2);
title('Amplitude N2 em Belém');
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
title('Amplitude M3 em Belém');
xlabel('Ano');
ylabel('Amplitude da K1 (cm)');
legend('Amplitude da K1', 'Tendência da M3', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(amplitudes_K1), sprintf(' = %.3f cm/ano', taxa_anual_K1),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


% Criar subplot para as fases
subplot(2, 4, 5);
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_M2, 'LineWidth', 2);
title('Fase da M2 em Belém');
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
title('Fase da S2 em Belém');
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
title('Fase da N2 em Belém');
xlabel('Ano');
ylabel('Fase (graus)');
legend('Fase da N2', 'Tendência da N2', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(fases_N2), sprintf(' = %.3f °/ano', taxa_anual_fase_N2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


subplot(2, 4, 8);
plot(anos_unicos, fases_K1, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_K1, 'LineWidth', 2);
title('Fase da K1 em Belém');
xlabel('Ano');
ylabel('Fase (graus)');
legend('Fase da K1', 'Tendência da K1', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(fases_K1), sprintf(' = %.3f °/ano', taxa_anual_fase_K1),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


% Define o tamanho da figura (por exemplo, 10 polegadas de largura e 6 polegadas de altura)
largura = 12; % polegadas
altura = 6; % polegadas
set(gcf, 'Units', 'inches', 'Position', [0, 0, largura, altura]);

% Salva a figura com o tamanho especificado
%saveas(gcf, 'Componente_M2_Belém.png');
%%
%}
% rescrever os gráficos de formula orizontal

% Criar subplot para as amplitudes
% Criar subplot para as amplitudes
figure('PaperSize',[20 20],...
       'PaperUnits','centimeters',...
       'InvertHardcopy','on',...
       'PaperPosition',[0 0 20 20],...
       'PaperPositionMode','auto',...
       'Position',[80 80 1800 900]);

subplot(4, 2, 1);
plot(anos_unicos, amplitudes_M2, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_M2, 'r', 'LineWidth', 2);
title('Amplitude');
xlim([2019, 2022]);
%xlabel('Ano');
ylabel('Amplitude (cm)');
grid on;
% Adicionar legenda com rótulos explicativos
legend('M2 (A)', 'FontSize', 6);

% Calcular as coordenadas x e y para o canto inferior direito do subplot
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 0.786 %0.947; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e cm/ano', taxa_anual_M2),...
%    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


% Ajuste das coordenadas para a posição do texto
%x_pos = anos_unicos(end); % Posição x igual ao último ano
%y_pos = min(amplitudes_M2); % Posição y mínimo, para ficar na parte inferior do gráfico

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.4f cm/ano', var_b1_linear_M2),...
%    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8)
set(gca, 'XTickLabel', []);

% Criar subplot para as fases
subplot(4, 2, 2);
plot(anos_unicos, fases_M2, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_fase_M2,'r', 'LineWidth', 2);
title('Fase');
%xlabel('Ano');
xlim([2019, 2022]);
ylabel('Fase (graus)');
legend('M2 (B)', 'FontSize', 6);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 110.5 %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e °/ano', var_reg_linear_M2),...
%    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
set(gca, 'XTickLabel', []);

subplot(4, 2, 3);
plot(anos_unicos, amplitudes_S2, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_S2, 'Color', [0.5, 0, 0.5], 'LineWidth', 2);
%title('Amplitude S2 em Fortaleza');
%xlabel('Ano');
xlim([2019, 2022]);
ylabel('Amplitude (cm)');
%legend('S2 (C)', 'FontSize', 6 'best');
legend('S2 (C)', 'FontSize', 6, 'Location', 'best');

grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 0.295 %0.31; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e cm/ano', var_b1_linear_S2),...
 %   'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8)

set(gca, 'XTickLabel', []);

subplot(4, 2, 4);
plot(anos_unicos, fases_S2, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_fase_S2, 'Color', [0.5, 0, 0.5], 'LineWidth', 2);
%title('Fase da S2 em Fortaleza');
%xlabel('Ano');
xlim([2019, 2022]);
ylabel('Fase (graus)');
%legend('S2 (D)', 'FontSize', 6);
legend('S2 (D)', 'FontSize', 6, 'Location', 'best');

grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 112 %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e °/ano', var_reg_linear_S2),...
 %   'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
set(gca, 'XTickLabel', []);

subplot(4, 2, 5);
plot(anos_unicos, amplitudes_N2, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_N2,'g', 'LineWidth', 2);
%title('Amplitude O1 em Fortaleza');
%xlabel('Ano');
xlim([2019, 2022]);
ylabel('Amplitude (cm)');
%legend('N2 (E)','FontSize', 6);
legend('N2 (E)', 'FontSize', 6, 'Location', 'best');

grid on;

% Calcular as coordenadas x e y para o canto inferior direito do subplot
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 0.144 %0.0693; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e cm/ano', var_b1_linear_N2),...
%    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8)
set(gca, 'XTickLabel', []);

subplot(4, 2, 6);
plot(anos_unicos, fases_N2, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_fase_N2,'g', 'LineWidth', 2);
%title('Fase da O1 em Fortaleza');
%xlabel('Ano');
xlim([2019, 2022]);
ylabel('Fase (graus)');
legend('N2 (F)','FontSize', 6);

grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 107 %0.0102; % Posição y igual ao valor mínimo do eixo y
% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e °/ano', var_reg_linear_N2),...
 %   'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
set(gca, 'XTickLabel', []);

subplot(4, 2, 7);
plot(anos_unicos, amplitudes_K1, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_K1,'b' , 'LineWidth', 2);
%title('Amplitude M3 em Fortaleza');
xlim([2019, 2022]);
xlabel('Anos');
ylabel('Amplitude (cm)');
legend('K1 (G)','FontSize', 6);
grid on;

x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 0.037 %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e cm/ano', var_b1_linear_K1),...
%    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8)

subplot(4, 2, 8);
plot(anos_unicos, fases_K1, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_fase_K1, 'b', 'LineWidth', 2);
%title('Fase da M3 em Fortaleza');
% Definir os limites do eixo x de 2001 a 2022
xlim([2019, 2022]);
xlabel('Anos');
ylabel('Fase (graus)');
%legend('K1 (H)','FontSize', 8);
legend('K1 (H)', 'FontSize', 6);

grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 208 %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e °/ano', var_reg_linear_K1),...
%    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);

% Salva a figura com a resolução especificada (300 dpi)
%set(gcf,'papertype','A4');   
%fig = gcf;
%fig.PaperSize=[0 0 21 13];
%fig.PaperPosition = [1 1 20 25];
%print('Componente_M2_Belem_02.svg', '-dsvg', '-r600');

%fig = gcf; % Obtém a figura atual
%fig.PaperSize = [21 13]; % Define o tamanho do papel como 21x13 cm
%fig.PaperPosition = [0 0 21 13]; % A figura ocupa todo o papel
%print('Componente_M2_Belem_02.svg', '-dsvg', '-r600');
%{
fig = gcf; % Obtém a figura atual
fig.PaperSize = [21 13]; % Define o tamanho do papel como 21x13 cm
fig.PaperPosition = [0 0 21 13]; % A figura ocupa todo o papel

% Salva a figura em TIFF com alta qualidade
print('Componente_M2_Belem_02.tiff', '-dtiff', '-r600');
%}

%sgtitle('Análise das Componentes Harmônicas das Marés em Belém', ...
 %       'FontSize', 14, ...      % Tamanho da fonte
  %      'FontWeight', 'bold', ...% Peso da fonte (negrito)
   %     'FontName', 'Arial', ... % Nome da fonte
    %    'Color', 'black');       % Cor da fonte

% Salva a figura com a resolução especificada (300 dpi)
fig = gcf; % Obtém a figura atual
fig.PaperSize = [21 13]; % Define o tamanho do papel como 21x13 cm
fig.PaperPosition = [0 0 21 13]; % A figura ocupa todo o papel
print('Componente_M2_Belem_03.svg', '-dsvg', '-r600');



