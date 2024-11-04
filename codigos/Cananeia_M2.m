% Código para calcular as principais constantes harmonicas anualmente
% Posteriormente cria-se a série temporal para avaliar a variaÇão das
% constantes no tempo
clear all; 
close all;
clc

dado = importdata('dad02.txt');
data = dado.textdata(:,1);
hora = dado.textdata(:,2);
altura_zero = dado.data(:,1); %em milimetro n 
altura_zero = altura_zero;

%converter datas e horas para números
data_hora_str = strcat(data, {' '}, hora);
data_numerica = datenum(data_hora_str, 'dd/mm/yyyy HH:MM');

des = std(altura_zero)
% Extrair o ano de cada data
anos = year(datetime(data_numerica, 'ConvertFrom', 'datenum'));
anos_unicos = unique(anos); % Obter os anos únicos presentes nos dados

% Realizar análise harmônica para cada ano separadamente
for i = 1:length(anos_unicos)
    ano_atual = anos_unicos(i);
    indices_ano_atual = find(anos == ano_atual); % Índices das datas do ano atual
    
    % Extrair alturas do nível do mar para o ano atual
    alturas_ano_atual = altura_zero(indices_ano_atual); 
    
    % Realizar análise harmônica usando o UTide
    coeficientes_harmonicos{i} = ut_solv(data_numerica(indices_ano_atual), ...
                                         alturas_ano_atual, [], -25.0181, 'auto');
    
    % Reconstruir as alturas da maré para o ano atual
    [componentes_mare{i}] = ut_reconstr(data_numerica(indices_ano_atual), coeficientes_harmonicos{i});
end

% Inicializar matrizes para armazenar as principais componentes de maré e seus sinais-ruído para cada ano
principais_componentes = cell(length(anos_unicos), 1);
sinal_ruido = cell(length(anos_unicos), 1);


% Inicializar matrizes para armazenar as amplitudes e fases da componente M2 para cada ano
amplitudes_M2 = zeros(length(anos_unicos), 1);
amplitudes_S2 = zeros(length(anos_unicos), 1);
amplitudes_O1 = zeros(length(anos_unicos), 1);
amplitudes_M3 = zeros(length(anos_unicos), 1);
fases_M2 = zeros(length(anos_unicos), 1);
fases_S2 = zeros(length(anos_unicos), 1);
fases_O1 = zeros(length(anos_unicos), 1);
fases_M3 = zeros(length(anos_unicos), 1);
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

%{
% Plotar amplitudes da componente M2 ao longo do tempo
figure;
plot(anos_unicos, amplitudes_M2, 'o-', 'LineWidth', 1.5);
xlabel('Ano');
ylabel('Amplitude da Componente M2 (cm)');
title('Amplitude da Componente M2 em Arraial do Cabo');
grid on;

% Plotar fases da componente M2 ao longo do tempo
figure;
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 1.5);
xlabel('Ano');
ylabel('Fase da Componente M2 (graus) ');
title('Fase da Componente M2 em Arraial do Cabo');
grid on;
%}


% Inicializar matrizes para armazenar as amplitudes e fases das componentes para cada ano
amplitudes_M2 = zeros(length(anos_unicos), 1);
amplitudes_S2 = zeros(length(anos_unicos), 1);
amplitudes_O1 = zeros(length(anos_unicos), 1);
amplitudes_M3 = zeros(length(anos_unicos), 1);
fases_M2 = zeros(length(anos_unicos), 1);
fases_S2 = zeros(length(anos_unicos), 1);
fases_O1 = zeros(length(anos_unicos), 1);
fases_M3 = zeros(length(anos_unicos), 1);

% Criar figura para subplots
figure;

% Extrair amplitudes e fases das componentes para cada ano
for i = 1:length(anos_unicos)
    % Obter os coeficientes harmônicos para o ano atual
    coeficientes_atual = coeficientes_harmonicos{i};
    
    % Encontrar os índices das componentes M2, S2, O1 e M3 nos coeficientes
    indice_M2 = find(strcmp(coeficientes_atual.name, 'M2'));
    indice_S2 = find(strcmp(coeficientes_atual.name, 'S2'));
    indice_O1 = find(strcmp(coeficientes_atual.name, 'O1'));
    indice_M3 = find(strcmp(coeficientes_atual.name, 'M3'));
    
    % Extrair amplitude e fase das componentes M2, S2, O1 e M3
    amplitude_M2 = coeficientes_atual.A(indice_M2);
    fase_M2 = coeficientes_atual.g(indice_M2);
    
    amplitude_S2 = coeficientes_atual.A(indice_S2);
    fase_S2 = coeficientes_atual.g(indice_S2);
    
    amplitude_O1 = coeficientes_atual.A(indice_O1);
    fase_O1 = coeficientes_atual.g(indice_O1);
    
    amplitude_M3 = coeficientes_atual.A(indice_M3);
    fase_M3 = coeficientes_atual.g(indice_M3);
    
    % Armazenar amplitudes e fases das componentes para o ano atual
    amplitudes_M2(i) = amplitude_M2;
    amplitudes_S2(i) = amplitude_S2;
    amplitudes_O1(i) = amplitude_O1;
    amplitudes_M3(i) = amplitude_M3;
    
    fases_M2(i) = fase_M2;
    fases_S2(i) = fase_S2;
    fases_O1(i) = fase_O1;
    fases_M3(i) = fase_M3;
end


%criar uma tendencia para todas componentes mais relevante
vetor_tmp_M2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_M2 = vetor_tmp_M2\amplitudes_M2;
b1_M2 = (vetor_tmp_M2*x1_M2);

% Calcular a variação total das amplitudes das componentes de marés nos últimos 50 anos

var_total_M2 = max(amplitudes_M2) - min(amplitudes_M2); % Supondo que os dados estejam organizados em ordem cronológica
var_start_end_M2 = (amplitudes_M2(end) - amplitudes_M2(1)) / 47; % novo calculo inicio - fim
var_b1_linear_M2 = (b1_M2(end) - b1_M2(1)) / 47; % taxa anual da tendencia liner de variacao da M2
%%
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
var_b1_linear_S2 = (b1_S2(end) - b1_S2(1)) / 47; % taxa anual da tendencia liner de variacao da S2
%%
vetor_tmp_O1 = [ones(length(anos_unicos), 1) anos_unicos];
x1_O1 = vetor_tmp_O1\amplitudes_O1;
b1_O1 = (vetor_tmp_O1*x1_O1);

var_total_O1 = max(amplitudes_O1) - min(amplitudes_O1); 
var_b1_linear_O1 = (b1_O1(end) - b1_O1(1)) / 47; % novo calculo inicio - fim
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_O1 = var_total_O1 / anos_anos_unicos;
%%
vetor_tmp_M3 = [ones(length(anos_unicos), 1) anos_unicos];
x1_M3 = vetor_tmp_M3\amplitudes_M3;
b1_M3 = (vetor_tmp_M3*x1_M3);

var_total_M3 = max(amplitudes_M3) - min(amplitudes_M3); % variavel de amp_max
var_b1_linear_M3 = (b1_M3(end) - b1_M3(1)) / 47; % taxa anual da tendencia liner de variacao da M2

% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_M3 = var_total_M3 / anos_anos_unicos;

%%
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
var_reg_linear_M2 = (b1_fase_M2(end) - b1_fase_M2(1)) / 47; % taxa anual da tendencia liner de variacao da M2

%%
vetor_fase_S2 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_S2 = vetor_fase_S2 \ fases_S2;
b1_fase_S2 = (vetor_fase_S2 * x1_fase_S2);
%
var_total_fase_S2 = max(fases_S2) - min(fases_S2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_S2 = var_total_fase_S2 / anos_anos_unicos;
var_reg_linear_S2 = (b1_fase_S2(end) - b1_fase_S2(1)) / 47; % taxa anual da tendencia liner de variacao da S2
%%
vetor_fase_O1 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_O1 = vetor_fase_O1 \ fases_O1;
b1_fase_O1 = (vetor_fase_O1 * x1_fase_O1);
%
var_total_fase_O1 = max(fases_O1) - min(fases_O1); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_O1 = var_total_fase_O1 / anos_anos_unicos;
var_reg_linear_O1 = (b1_fase_O1(end) - b1_fase_O1(1)) / 47; % taxa anual da tendencia liner de variacao da M3
%%
vetor_fase_M3 = [ones(length(anos_unicos), 1) anos_unicos];
x1_fase_M3 = vetor_fase_M3 \ fases_M3;
b1_fase_M3 = (vetor_fase_M3 * x1_fase_M3);

var_total_fase_M3 = max(fases_M3) - min(fases_M3); % variacao máxima da fase M3 em 47 anos de dados
var_start_end_fase_M3 = (fases_M3(end) - fases_M3(1)) / 47; % taxa anual de variaçao em 47 anos de dados >> analise fraca!
amp_reg_linear_M3 = max(b1_fase_M3) - min(b1_fase_M3); % taxa anual da tendencia liner de variacao da M3
var_reg_linear_M3 = (b1_fase_M3(end) - b1_fase_M3(1)) / 47; % taxa anual da tendencia liner de variacao da M3


% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_M3 = var_total_fase_M3 / anos_anos_unicos;

%%
%{
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
title('Amplitude M2 em Cananeia');
xlabel('Ano');
ylabel('Amplitude da M2 (cm)');
grid on;
% Adicionar legenda com rótulos explicativos
%legend('Amplitude da M2', 'Tendência da M2', 'FontSize', 8);

% Ajuste das coordenadas para a posição do texto
x_pos = anos_unicos(end); % Posição x igual ao último ano
y_pos = min(amplitudes_M2); % Posição y mínimo, para ficar na parte inferior do gráfico

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.3f cm/ano', var_b1_linear_M2),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
%%
subplot(2, 4, 2);
plot(anos_unicos, amplitudes_S2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_S2, 'LineWidth', 2);
title('Amplitude S2 em Cananeia');
xlabel('Ano');
ylabel('Amplitude da S2 (cm)');
%legend('Amplitude da S2', 'Tendência da S2', 'FontSize', 8);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = anos_unicos(end); % Posição x igual ao último ano
y_pos = min(amplitudes_S2); % Posição y mínimo, para ficar na parte inferior do gráfico

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.3f cm/ano', var_b1_linear_S2),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);

%%
subplot(2, 4, 3);
plot(anos_unicos, amplitudes_O1, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_O1, 'LineWidth', 2);
title('Amplitude O1 em Cananeia');
xlabel('Ano');
ylabel('Amplitude da O1 (cm)');
%legend('Amplitude da O1', 'Tendência da O1', 'FontSize', 8);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = anos_unicos(end); % Posição x igual ao último ano
y_pos = min(amplitudes_O1); % Posição y mínimo, para ficar na parte inferior do gráfico

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.3f cm/ano', var_b1_linear_O1),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


%%
subplot(2, 4, 4);
plot(anos_unicos, amplitudes_M3, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_M3, 'LineWidth', 2);
title('Amplitude M3 em Cananeia');
xlabel('Ano');
ylabel('Amplitude da M3 (cm)');
%legend('Amplitude da M3', 'Tendência da M3', 'FontSize', 8);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = anos_unicos(end); % Posição x igual ao último ano
y_pos = min(amplitudes_M3); % Posição y mínimo, para ficar na parte inferior do gráfico

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.3f cm/ano', var_b1_linear_M3),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);



%%
%
% Criar subplot para as fases
subplot(2, 4, 5);
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_M2, 'LineWidth', 2);
title('Fase da M2 em Cananeia');
xlabel('Ano');
ylabel('Fase (graus)');
%legend('Fase da M2', 'Tendência da M2', 'FontSize', 8);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = anos_unicos(end); % Posição x igual ao último ano
y_pos = min(fases_M2); % Posição y mínimo, para ficar na parte inferior do gráfico

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.3f °/ano', var_reg_linear_M2),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


%%
subplot(2, 4, 6);
plot(anos_unicos, fases_S2, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_S2, 'LineWidth', 2);
title('Fase da S2 em Cananeia');
xlabel('Ano');
ylabel('Fase (graus)');
%legend('Fase da S2', 'Tendência da S2', 'FontSize', 8);
grid on;


% Ajuste das coordenadas para a posição do texto
x_pos = anos_unicos(end); % Posição x igual ao último ano
y_pos = min(fases_S2); % Posição y mínimo, para ficar na parte inferior do gráfico

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.3f °/ano', var_reg_linear_S2),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);

%%
subplot(2, 4, 7);
plot(anos_unicos, fases_O1, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_O1, 'LineWidth', 2);
title('Fase da O1 em Cananeia');
xlabel('Ano');
ylabel('Fase (graus)');
%legend('Fase da O1', 'Tendência da O1', 'FontSize', 8);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = anos_unicos(end); % Posição x igual ao último ano
y_pos = min(fases_O1); % Posição y mínimo, para ficar na parte inferior do gráfico

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.3f °/ano', var_reg_linear_O1),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


%%
subplot(2, 4, 8);
plot(anos_unicos, fases_M3, 'o-', 'LineWidth', 2);
hold on
plot(anos_unicos, b1_fase_M3, 'LineWidth', 2);
title('Fase da M3 em Cananeia');
xlabel('Ano');
ylabel('Fase (graus)');
%legend('Fase da M3', 'Tendência da M3', 'FontSize', 8);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = anos_unicos(end); % Posição x igual ao último ano
y_pos = min(fases_M3); % Posição y mínimo, para ficar na parte inferior do gráfico

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.3f °/ano', var_reg_linear_M3),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


% Define o tamanho da figura (por exemplo, 10 polegadas de largura e 6 polegadas de altura)
largura = 12; % polegadas
altura = 6; % polegadas
set(gcf, 'Units', 'inches', 'Position', [0, 0, largura, altura]);

% Salva a figura com o tamanho especificado
saveas(gcf, 'Componente_M2_Cananeia.png');
%}
%%
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
plot(anos_unicos, b1_M2, 'b', 'LineWidth', .5);
title('Amplitude');
xlim([1954, 2004]);
ylim([0.34 0.38]);
yticks(0.34:0.02:0.38);
%xlabel('Ano');
ylabel('Amplitude (cm)');
grid on;
% Adicionar legenda com rótulos explicativos
legend('M2 (A)', 'Location', 'northwest', 'FontSize', 6);

% Calcular as coordenadas x e y para o canto inferior direito do subplot
x_pos = 2004;  % Posição x igual ao valor máximo do eixo x
y_pos = 0.34; %0.947; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.1ecm.ano^{-1}', var_b1_linear_M2),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


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
plot(anos_unicos, b1_fase_M2,'b', 'LineWidth', .5);
xlim([1954, 2004]);
ylim([90 100]);
yticks(90:5:100);
title('Fase');
%xlabel('Ano');
ylabel('Fase (graus)');
legend('M2 (B)', 'Location', 'northwest', 'FontSize', 6);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2004;  % Posição x igual ao valor máximo do eixo x
y_pos = 90; %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.1e°.ano^{-1}', var_reg_linear_M2),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
set(gca, 'XTickLabel', []);

subplot(4, 2, 3);
plot(anos_unicos, amplitudes_S2, 'k', 'LineWidth', 1.5);
hold on
plot(anos_unicos, b1_S2, 'b', 'LineWidth', .5);
%title('Amplitude S2 em Fortaleza');
xlim([1954, 2004]);
ylim([0.22 0.26]);
yticks(0.22:0.02:0.26);
%xlabel('Ano');
ylabel('Amplitude (cm)');
legend('S2 (C)', 'Location', 'northwest', 'FontSize', 6);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2004;  % Posição x igual ao valor máximo do eixo x
y_pos = 0.22; %0.31; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.1ecm.ano^{-1}', var_b1_linear_S2),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8)

set(gca, 'XTickLabel', []);

subplot(4, 2, 4);
plot(anos_unicos, fases_S2, 'k', 'LineWidth', 1.5);
hold on
plot(anos_unicos, b1_fase_S2, 'b', 'LineWidth', .5);
%title('Fase da S2 em Fortaleza');
xlim([1954, 2004]);
ylim([90 110]);
yticks(90:10:110);
%xlabel('Ano');
ylabel('Fase (graus)');
legend('S2 (D)', 'Location', 'northwest', 'FontSize', 6);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2004;  % Posição x igual ao valor máximo do eixo x
y_pos = 90; %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.1e°.ano^{-1}', var_reg_linear_S2),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
set(gca, 'XTickLabel', []);

subplot(4, 2, 5);
plot(anos_unicos, amplitudes_O1, 'k', 'LineWidth', 1.5);
hold on
plot(anos_unicos, b1_O1,'b', 'LineWidth', .5);
%title('Amplitude O1 em Fortaleza');
xlim([1954, 2004]);
ylim([0.108 0.120]);
yticks(0.108:0.004:0.120);
%xlabel('Ano');
ylabel('Amplitude (cm)');
legend('O1 (E)', 'Location', 'southwest', 'FontSize', 6);
grid on;

% Calcular as coordenadas x e y para o canto inferior direito do subplot
x_pos = 2004;  % Posição x igual ao valor máximo do eixo x
y_pos = 0.116; %0.0693; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.1ecm.ano^{-1}', var_b1_linear_O1),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8)
set(gca, 'XTickLabel', []);

subplot(4, 2, 6);
plot(anos_unicos, fases_O1, 'k', 'LineWidth', 1.5);
hold on
plot(anos_unicos, b1_fase_O1,'b', 'LineWidth', .5);
xlim([1954, 2004]);
ylim([80 88]);
yticks(80:4:88);
%title('Fase da O1 em Fortaleza');
%xlabel('Ano');
ylabel('Fase (graus)');
legend('O1 (F)', 'Location', 'southwest', 'FontSize', 6);

grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2004;  % Posição x igual ao valor máximo do eixo x
y_pos = 80; %0.0102; % Posição y igual ao valor mínimo do eixo y
% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.1e°.ano^{-1}', var_reg_linear_O1),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
set(gca, 'XTickLabel', []);

subplot(4, 2, 7);
plot(anos_unicos, amplitudes_M3, 'k', 'LineWidth', 1.5);
hold on
plot(anos_unicos, b1_M3,'b' , 'LineWidth', .5);
xlim([1954, 2004]);
ylim([0.06 0.10]);
yticks(0.06:0.02:0.10);
%title('Amplitude M3 em Fortaleza');
xlabel('Anos');
ylabel('Amplitude (cm)');
legend('M3 (G)', 'Location', 'northwest', 'FontSize', 6);
grid on;

x_pos = 2004;  % Posição x igual ao valor máximo do eixo x
y_pos = 0.08; %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.1ecm.ano^{-1}', var_b1_linear_M3),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8)

subplot(4, 2, 8);
plot(anos_unicos, fases_M3, 'k', 'LineWidth', 1.5);
hold on
plot(anos_unicos, b1_fase_M3, 'b', 'LineWidth', .5);
xlim([1954, 2004]);
ylim([220 260]);
yticks(220:20:260);
%title('Fase da M3 em Fortaleza');
xlabel('Anos');
ylabel('Fase (graus)');
legend('M3 (H)', 'Location', 'southwest', 'FontSize', 6);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2004;  % Posição x igual ao valor máximo do eixo x
y_pos = 220; %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(x_pos, y_pos, sprintf('= %.1e°.ano^{-1}', var_reg_linear_M3),...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);

%sgtitle('Análise das Componentes Harmônicas das Marés em Cananéia', ...
 %       'FontSize', 14, ...      % Tamanho da fonte
  %      'FontWeight', 'bold', ...% Peso da fonte (negrito)
   %     'FontName', 'Arial', ... % Nome da fonte
    %    'Color', 'black');       % Cor da fonte

% Salva a figura com a resolução especificada (300 dpi)
%print('Componente_M2_Cananeia_01.png', '-dpng', '-r300');
fig = gcf; % Obtém a figura atual
fig.PaperSize = [21 13]; % Define o tamanho do papel como 21x13 cm
fig.PaperPosition = [0 0 21 13]; % A figura ocupa todo o papel
print('Componente_M2_cananeia_03.svg', '-dsvg', '-r300');
