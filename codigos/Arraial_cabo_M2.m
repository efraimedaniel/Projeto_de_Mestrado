clear all; 
close all;
clc

dado = importdata('arca_178_2017_2022.txt');
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
                                         alturas_ano_atual, [], -22.9725, 'auto');
    
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


% Extrair amplitudes e fases das componentes para cada ano
for i = 1:length(anos_unicos)
    % Obter os coeficientes harmônicos para o ano atual
    coeficientes_atual = coeficientes_harmonicos{i};
    
    % Encontrar os índices das componentes M2, S2, O1 e SA nos coeficientes
    indice_M2 = find(strcmp(coeficientes_atual.name, 'M2'));
    indice_S2 = find(strcmp(coeficientes_atual.name, 'S2'));
    indice_O1 = find(strcmp(coeficientes_atual.name, 'O1'));
    indice_K1 = find(strcmp(coeficientes_atual.name, 'K1'));
    
    % Extrair amplitude e fase das componentes M2, S2, O1 e SA
    amplitude_M2 = coeficientes_atual.A(indice_M2);
    fase_M2 = coeficientes_atual.g(indice_M2);
    
    amplitude_S2 = coeficientes_atual.A(indice_S2);
    fase_S2 = coeficientes_atual.g(indice_S2);
    
    amplitude_O1 = coeficientes_atual.A(indice_O1);
    fase_O1 = coeficientes_atual.g(indice_O1);
    
    amplitude_K1 = coeficientes_atual.A(indice_K1);
    fase_K1 = coeficientes_atual.g(indice_K1);
    
    % Armazenar amplitudes e fases das componentes para o ano atual
    amplitudes_M2(i) = amplitude_M2;
    amplitudes_S2(i) = amplitude_S2;
    amplitudes_O1(i) = amplitude_O1;
    amplitudes_K1(i) = amplitude_K1;
    
    fases_M2(i) = fase_M2;
    fases_S2(i) = fase_S2;
    fases_O1(i) = fase_O1;
    fases_K1(i) = fase_K1; % Corrigido: Atribuindo a fase_SA a fases_M3
end
%{
% Criar figura para subplots
%figure;
% Criar subplot para as amplitudes
subplot(2, 4, 1);
plot(anos_unicos, amplitudes_M2, 'o-', 'LineWidth', 2);
title('Amplitude M2 em Arraial do Cabo');
xlabel('Ano');
ylabel('Amplitude da M2 (cm)');
grid on;

subplot(2, 4, 2);
plot(anos_unicos, amplitudes_S2, 'o-', 'LineWidth', 2);
title('Amplitude S2 em Arraial do Cabo');
xlabel('Ano');
ylabel('Amplitude da S2 (cm)');
grid on;

subplot(2, 4, 3);
plot(anos_unicos, amplitudes_O1, 'o-', 'LineWidth', 2);
title('Amplitude O1 em Arraial do Cabo');
xlabel('Ano');
ylabel('Amplitude da O1 (cm)');
grid on;

subplot(2, 4, 4);
plot(anos_unicos, amplitudes_K1, 'o-', 'LineWidth', 2);
title('Amplitude M3 em Arraial do Cabo');
xlabel('Ano');
ylabel('Amplitude da K1 (cm)');
grid on;

% Criar subplot para as fases
subplot(2, 4, 5);
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 2);
title('Fase da M2 Arraial do Cabo');
xlabel('Ano');
ylabel('Fase (graus)');
grid on;

subplot(2, 4, 6);
plot(anos_unicos, fases_S2, 'o-', 'LineWidth', 2);
title('Fase da S2 em Arraial do Cabo');
xlabel('Ano');
ylabel('Fase (graus)');
grid on;

subplot(2, 4, 7);
plot(anos_unicos, fases_O1, 'o-', 'LineWidth', 2);
title('Fase da O1 em Arraial do Cabo');
xlabel('Ano');
ylabel('Fase (graus)');
grid on;

subplot(2, 4, 8);
plot(anos_unicos, fases_K1, 'o-', 'LineWidth', 2);
title('Fase da K1 em Arraial do Cabo');
xlabel('Ano');
ylabel('Fase (graus)');
grid on
%}

%criar uma tendencia para todas componentes mais relevante
%vetor_tmp_M2 = [ones(length(anos_unicos), 1) anos_unicos];
%x1_M2 = vetor_tmp_M2 \ amplitudes_M2;
%b1_M2 = (vetor_tmp_M2*x1_M2);

% Calcular a variação total das amplitudes das componentes de marés nos últimos 50 anos

var_total_M2 = max(amplitudes_M2) - min(amplitudes_M2); % Supondo que os dados estejam organizados em ordem cronológica

% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_M2 = var_total_M2 / anos_anos_unicos;
%
%vetor_tmp_S2 = [ones(length(anos_unicos), 1) anos_unicos];
%x1_S2 = vetor_tmp_S2\amplitudes_S2;
%b1_S2 = (vetor_tmp_S2*x1_S2);

var_total_S2 = max(amplitudes_S2) - min(amplitudes_S2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_S2 = var_total_S2 / anos_anos_unicos;

%vetor_tmp_O1 = [ones(length(anos_unicos), 1) anos_unicos];
%x1_O1 = vetor_tmp_O1\amplitudes_O1;
%b1_O1 = (vetor_tmp_O1*x1_O1);

var_total_O1 = max(amplitudes_O1) - min(amplitudes_O1); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_O1 = var_total_O1 / anos_anos_unicos;
%
%vetor_tmp_M3 = [ones(length(anos_unicos), 1) anos_unicos];
%x1_M3 = vetor_tmp_M3\amplitudes_M3;
%b1_M3 = (vetor_tmp_M3*x1_M3);
%
var_total_K1 = max(amplitudes_K1) - min(amplitudes_K1); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_K1 = var_total_K1 / anos_anos_unicos;


%criar uma tendencia para todas as fases mais relevante
%
%vetor_fase_M2 = [ones(length(anos_unicos), 1) anos_unicos];
%x1_fase_M2 = vetor_fase_M2 \ fases_M2;
%b1_fase_M2 = (vetor_fase_M2 * x1_fase_M2);
%
var_total_fase_M2 = max(fases_M2) - min(fases_M2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_M2 = var_total_fase_M2 / anos_anos_unicos;
%
%vetor_fase_S2 = [ones(length(anos_unicos), 1) anos_unicos];
%x1_fase_S2 = vetor_fase_S2 \ fases_S2;
%b1_fase_S2 = (vetor_fase_S2 * x1_fase_S2);
%
var_total_fase_S2 = max(fases_S2) - min(fases_S2); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_S2 = var_total_fase_S2 / anos_anos_unicos;
%
%vetor_fase_O1 = [ones(length(anos_unicos), 1) anos_unicos];
%x1_fase_O1 = vetor_fase_O1 \ fases_O1;
%b1_fase_O1 = (vetor_fase_O1 * x1_fase_O1);
%
var_total_fase_O1 = max(fases_O1) - min(fases_O1); 
% Calcular a taxa anual de variação da amplitude da componente de maré M2
anos_anos_unicos = length(anos_unicos); % Número de anos de observação
taxa_anual_fase_O1 = var_total_fase_O1 / anos_anos_unicos;
%
%vetor_fase_K1 = [ones(length(anos_unicos), 1) anos_unicos];
%x1_fase_K1 = vetor_fase_K1 \ fases_K1;
%b1_fase_K1 = (vetor_fase_K1 * x1_fase_K1);
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
%plot(anos_unicos, b1_M2, 'LineWidth', 2);
title('Amplitude M2 em Arraial do cabo');
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
%plot(anos_unicos, b1_S2, 'LineWidth', 2);
title('Amplitude S2 em Arraial do cabo');
xlabel('Ano');
ylabel('Amplitude da S2 (cm)');
legend('Amplitude da S2', 'Tendência da S2', 'FontSize', 8);
grid on;

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
text(max(anos_unicos), min(amplitudes_S2), sprintf(' = %.3f cm/ano', taxa_anual_S2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);

subplot(2, 4, 3);
plot(anos_unicos, amplitudes_O1, 'o-', 'LineWidth', 2);
%hold on
%plot(anos_unicos, b1_O1, 'LineWidth', 2);
title('Amplitude O1 em Arraial do cabo');
xlabel('Ano');
ylabel('Amplitude da O1 (cm)');
legend('Amplitude da O1', 'Tendência da O1', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(amplitudes_O1), sprintf(' = %.3f cm/ano', taxa_anual_O1),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);



subplot(2, 4, 4);
plot(anos_unicos, amplitudes_K1, 'o-', 'LineWidth', 2);
%hold on
%plot(anos_unicos, b1_K1, 'LineWidth', 2);
title('Amplitude K1 em Arraial do cabo');
xlabel('Ano');
ylabel('Amplitude da K1 (cm)');
legend('Amplitude da K1', 'Tendência da M3', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(amplitudes_K1), sprintf(' = %.3f cm/ano', taxa_anual_K1),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


% Criar subplot para as fases
subplot(2, 4, 5);
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 2);
%hold on
%plot(anos_unicos, b1_fase_M2, 'LineWidth', 2);
title('Fase da M2 em Arraial do cabo');
xlabel('Ano');
ylabel('Fase (graus)');
legend('Fase da M2', 'Tendência da M2', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(fases_M2), sprintf(' = %.3f °/ano', taxa_anual_fase_M2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


subplot(2, 4, 6);
plot(anos_unicos, fases_S2, 'o-', 'LineWidth', 2);
%hold on
%plot(anos_unicos, b1_fase_S2, 'LineWidth', 2);
title('Fase da S2 em Arraial do cabo');
xlabel('Ano');
ylabel('Fase (graus)');
legend('Fase da S2', 'Tendência da S2', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(fases_S2), sprintf(' = %.3f °/ano', taxa_anual_fase_S2),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


subplot(2, 4, 7);
plot(anos_unicos, fases_O1, 'o-', 'LineWidth', 2);
%hold on
%plot(anos_unicos, b1_fase_O1, 'LineWidth', 2);
title('Fase da O1 em Arraial do cabo');
xlabel('Ano');
ylabel('Fase (graus)');
legend('Fase da O1', 'Tendência da O1', 'FontSize', 8);
grid on;
text(max(anos_unicos), min(fases_O1), sprintf(' = %.3f °/ano', taxa_anual_fase_O1),... 
'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);


subplot(2, 4, 8);
plot(anos_unicos, fases_K1, 'o-', 'LineWidth', 2);
%hold on
%plot(anos_unicos, b1_fase_K1, 'LineWidth', 2);
title('Fase da K1 em Arraial do cabo');
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
saveas(gcf, 'Componente_M2_Arraial do Cabo.png');

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
plot(anos_unicos, amplitudes_M2, 'k', 'LineWidth', 2);
hold on
%plot(anos_unicos, b1_M2, 'r', 'LineWidth', 2);
title('Amplitude');
xlim([2017, 2022]);
%xlabel('Ano');
ylabel('Amplitude (cm)');
grid on;
% Adicionar legenda com rótulos explicativos
%legend('M2 (A)', 'FontSize', 6);
legend('M2 (A)', 'FontSize', 6, 'Location', 'best');


% Calcular as coordenadas x e y para o canto inferior direito do subplot
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 11.5 %0.947; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e cm/ano', var_b1_linear_M2),...
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
xlim([2017, 2022]);
ylabel('Fase (graus)');
legend('M2 (B)', 'FontSize', 6);
grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 61 %0.0102; % Posição y igual ao valor mínimo do eixo y

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
xlim([2017, 2022]);
ylabel('Amplitude (cm)');
%legend('S2 (C)', 'FontSize', 6);
legend('S2 (C)', 'FontSize', 6, 'Location', 'best');


grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 8.5 %0.31; % Posição y igual ao valor mínimo do eixo y

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
xlim([2017, 2022]);
ylabel('Fase (graus)');
%legend('S2 (D)', 'FontSize', 6);
legend('S2 (D)', 'FontSize', 6, 'Location', 'best');

grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 51 %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e °/ano', var_reg_linear_S2),...
%    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
set(gca, 'XTickLabel', []);

subplot(4, 2, 5);
plot(anos_unicos, amplitudes_O1, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_O1,'g', 'LineWidth', 2);
%title('Amplitude O1 em Fortaleza');
%xlabel('Ano');
xlim([2017, 2022]);
ylabel('Amplitude (cm)');
legend('O1 (E)', 'FontSize', 6);
grid on;

% Calcular as coordenadas x e y para o canto inferior direito do subplot
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 9.5 %0.0693; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e cm/ano', var_b1_linear_O1),...
%    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8)
set(gca, 'XTickLabel', []);

subplot(4, 2, 6);
plot(anos_unicos, fases_O1, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_fase_O1,'g', 'LineWidth', 2);
%title('Fase da O1 em Fortaleza');
%xlabel('Ano');
xlim([2017, 2022]);
ylabel('Fase (graus)');
%legend('O1 (F)', 'FontSize', 6);
legend('O1 (F)', 'FontSize', 6, 'Location', 'best');


grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 70 %0.0102; % Posição y igual ao valor mínimo do eixo y
% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e °/ano', var_reg_linear_O1),...
 %   'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);
set(gca, 'XTickLabel', []);

subplot(4, 2, 7);
plot(anos_unicos, amplitudes_K1, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_K1,'b' , 'LineWidth', 2);
%title('Amplitude M3 em Fortaleza');
xlim([2017, 2022]);
xlabel('Anos');
ylabel('Amplitude (cm)');
legend('K1 (G)', 'FontSize', 6);
grid on;

x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 5.5 %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e cm/ano', var_b1_linear_K1),...
 %   'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8)

subplot(4, 2, 8);
plot(anos_unicos, fases_K1, 'k', 'LineWidth', 1.5);
hold on
%plot(anos_unicos, b1_fase_K1, 'b', 'LineWidth', 2);
%title('Fase da M3 em Fortaleza');
% Definir os limites do eixo x de 2001 a 2022
xlim([2017, 2022]);
xlabel('Anos');
ylabel('Fase (graus)');
%legend('K1 (H)', 'FontSize', 6);
legend('K1 (H)', 'FontSize', 6, 'Location', 'best');

grid on;

% Ajuste das coordenadas para a posição do texto
x_pos = 2022;  % Posição x igual ao valor máximo do eixo x
y_pos = 130 %0.0102; % Posição y igual ao valor mínimo do eixo y

% Adicionar texto com a taxa anual de variação da amplitude da componente M2
%text(x_pos, y_pos, sprintf('= %.3e °/ano', var_reg_linear_K1),...
    %'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 8);

%sgtitle('Análise das Componentes Harmônicas das Marés em Arraial do Cabo', ...
 %       'FontSize', 14, ...      % Tamanho da fonte
%      'FontWeight', 'bold', ...% Peso da fonte (negrito)
  %      'FontName', 'Arial', ... % Nome da fonte
   %     'Color', 'black');       % Cor da fonte
    
% Salva a figura com a resolução especificada (300 dpi)
fig = gcf; % Obtém a figura atual
fig.PaperSize = [21 13]; % Define o tamanho do papel como 21x13 cm
fig.PaperPosition = [0 0 21 13]; % A figura ocupa todo o papel
print('Componente_M2_arraia_03.svg', '-dsvg', '-r600');



