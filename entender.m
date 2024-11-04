clc; clear all; close all;

dado = importdata('imbi_718_2001_2021.txt');
data = dado.textdata(:,1);
hora = dado.textdata(:,2);
altura = dado.data(:,1); %em milimetro 

%converter datas e horas para números
data_hora_str = strcat(data, {' '}, hora);
data_numerica = datenum(data_hora_str, 'dd/mm/yyyy HH:MM');

altura_media = 1.58;
altura_zero = altura - altura_media;


%calcular os confiente usando a função ut_solv
coef = ut_solv (data_numerica, altura_zero, [],-22.97250,'auto'); 

%renconstruir a função coefinciente
 [u_fit_i] = ut_reconstr(data_numerica, coef);
%residuo
 residuo = altura_zero - u_fit_i;
 
% acessar nomes dos componentes
nome_comp = coef.name;
ampl = coef.A;
freq = coef.aux.frq;
fase = coef.g;

% Suponha que você já tenha calculado 'nome_comp' e 'ampl'.

% Criar um vetor de números inteiros para o eixo x
x_values = 1:length(nome_comp);

% Plote as amplitudes usando a função 'bar'
bar(x_values, ampl);

% Configure os rótulos no eixo x
xticks(x_values);
xticklabels(nome_comp);

% Rótulos de rotação se necessário para melhor visualização
xtickangle(45);  % Ângulo de rotação de 45 graus para os rótulos do eixo x

% Configurar rótulos e título
xlabel('Componentes de Maré');
ylabel('Amplitude');
title('Amplitude dos Componentes de Maré');
