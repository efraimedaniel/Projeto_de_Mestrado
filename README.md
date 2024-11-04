# Projeto de Mestrado: Análise do Nível do Mar no Brasil

Este projeto de mestrado consiste na análise detalhada de dados maregráficos para avaliar o comportamento do nível do mar em diferentes localidades da costa brasileira. A pesquisa inclui análise de tendências, subsidência, variabilidade sazonal e interanual, e análise espectral das marés.

## Índice
- [Objetivo do Projeto](#objetivo-do-projeto)
- [Metodologia](#metodologia)
  - [Tendência do Nível do Mar](#tendência-do-nível-do-mar)
  - [Subsidência](#subsidência)
  - [Variabilidade Sazonal e Interanual](#variabilidade-sazonal-e-interanual)
  - [Análise das Componentes Harmônicas](#análise-das-componentes-harmônicas)
  - [Análise Espectral](#análise-espectral)
- [Como Usar](#como-usar)
- [Estrutura do Repositório](#estrutura-do-repositório)
- [Contribuições](#contribuições)
- [Licença](#licença)

## Objetivo do Projeto

Este projeto visa compreender a evolução do nível médio do mar em diferentes pontos da costa brasileira, com foco nas seguintes localidades: Imbituba, Cananéia, Arraial do Cabo, Salvador, Fortaleza, Belém e Santana. A análise fornece insights importantes para prever a elevação do nível do mar, visando alertar sobre potenciais impactos futuros e contribuir para a conscientização climática.

## Metodologia

A metodologia aplicada inclui quatro análises principais:

### Tendência do Nível do Mar

Esta etapa consiste no cálculo da tendência de elevação do nível médio do mar em cada localidade usando técnicas de regressão linear. Os dados maregráficos foram processados para remover inconsistências e ruídos, e foram analisadas variações anuais e interanuais.

### Subsidência

Foram analisados os efeitos de subsidência nos locais onde os maregráficos foram instalados. Para isso, usamos dados de GPS para identificar possíveis afundamentos do solo e ajustar a análise da elevação do nível do mar em função desses fatores.

### Variabilidade Sazonal e Interanual

Nesta análise, exploramos a variabilidade sazonal (ciclo anual) e interanual (variações de longo prazo) das marés. Esses dados ajudam a identificar padrões de variação e anomalias que podem impactar as projeções futuras do nível do mar.

### Análise das Componentes Harmônicas

Usamos o software **Utide** para decompor as marés em suas componentes harmônicas e analisar como diferentes fatores astronômicos e meteorológicos afetam o comportamento das marés em cada localidade.

### Análise Espectral

Para entender a distribuição de energia ao longo das frequências das marés, realizamos uma análise espectral utilizando a Transformada Rápida de Fourier (FFT). Esta análise fornece informações sobre os ciclos predominantes nas variações das marés e identifica os períodos de maior energia.

## Como Usar

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/efraimedaniel/Projeto_de_Mestrado.git


---


