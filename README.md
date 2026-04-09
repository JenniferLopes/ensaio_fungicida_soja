# Ensaio de eficácia de fungicida em soja

Análise estatística de um ensaio de campo simulado para avaliação da eficácia de fungicida na cultura da soja. O projeto demonstra um pipeline reprodutível completo: simulação de dados, limpeza, análise exploratória, modelagem com GLMM, relatório em Quarto com referências bibliográficas reais, e ambiente containerizado com Docker e gerenciado com `{renv}`.

## Sobre o projeto

Este projeto foi desenvolvido como um MVP de modelagem estatística para uso em mentoria individual, com o objetivo de preparar o aluno antes das sessões práticas. O material cobre de forma integrada quatro pilares:

1.  Modelagem estatística: ajuste de GLMM com distribuição beta e LMM gaussiano, seleção de modelo por AIC, diagnóstico de resíduos e comparações múltiplas.

2.  Conceitos estatísticos: efeitos fixos e aleatórios, distribuição beta, AIC, delta-AIC, médias marginais, correção de Tukey e componentes de variância, todos definidos em linguagem acessível no dicionário do relatório.

3.   Experimentação agrícola: delineamento em blocos casualizados completos (RCBD), medições repetidas no tempo, covariáveis ambientais e estrutura hierárquica de dados de campo.

4.   Programação em R: scripts modulares e documentados, boas práticas de código reprodutível, uso de {renv} para controle de ambiente e {Quarto} para geração de relatório técnico-científico.

> O relatório gerado pelo projeto serve como material de referência para o aluno consultar os conceitos, acompanhar o raciocínio analítico e reproduzir cada etapa do pipeline antes e após as sessões de mentoria.
>
> Após a conclusão desta etapa com dados simulados, os mesmos métodos e pipeline foram aplicados aos dados do aluno, dando continuidade ao trabalho desenvolvido na mentoria. Aqui tivemos alguns contextos diferentes deste MPV.
>
> **Desenvolvido em janeiro de 2026.**

## Contexto

A ferrugem asiática da soja (*Phakopsora pachyrhizi*) é uma das principais doenças da cultura no Brasil. Este ensaio avalia quatro tratamentos (controle e três doses de fungicida) em delineamento de blocos casualizados completos (RCBD) com medições em três momentos após a aplicação, conduzido em três localidades.

Os dados foram simulados para reproduzir a estrutura e a variabilidade de um ensaio real de registro de defensivo agrícola, permitindo a verificação da recuperação de parâmetros pelo modelo.

## Estrutura do projeto

```         
ensaio_fungicida_soja/
├── Dockerfile
├── README.md
├── renv.lock
├── .Rprofile
├── rodar_pipeline.R
├── R/
│   ├── 01_simular_dados.R
│   ├── 02_limpar_dados.R
│   ├── 03_eda.R
│   ├── 04_analise_glmm.R
│   └── 05_configurar_renv.R
├── report/
│   ├── relatorio.qmd
│   ├── referencias.bib
│   └── estilo.css
├── data/
│   ├── raw/
│   └── processed/
└── output/
    ├── figuras/
    ├── tabelas/
    └── modelos/
```

## Variáveis simuladas

| Variável        | Descrição                                   |
|-----------------|---------------------------------------------|
| `tratamento`    | Controle, dose baixa, dose média, dose alta |
| `bloco`         | 6 blocos (efeito aleatório)                 |
| `local`         | 3 localidades (efeito aleatório)            |
| `tempo_dias`    | 30, 60 e 90 dias após aplicação             |
| `umidade_rel`   | Umidade relativa do ar (%)                  |
| `temp_media`    | Temperatura média diária (graus C)          |
| `severidade`    | Percentual de área foliar afetada (0-100)   |
| `produtividade` | Produção de grãos (kg/ha)                   |

## Análises realizadas

-   Análise exploratória com distribuições, evolução temporal e relação com covariáveis ambientais
-   GLMM com distribuição beta para a severidade (proporção de área foliar afetada)
-   LMM gaussiano para a produtividade
-   Diagnóstico de resíduos por simulação via `{DHARMa}`
-   Seleção de modelo por AIC e delta-AIC
-   Médias marginais estimadas e comparações múltiplas com correção de Tukey via `{emmeans}`
-   Componentes de variância dos efeitos aleatórios (bloco e localidade)
-   Verificação de recuperação de parâmetros verdadeiros da simulação

## Decisões metodológicas

**Por que GLMM e não ANOVA?** A severidade é uma proporção com distribuição assimétrica, as medições são repetidas no tempo e os dados têm estrutura hierárquica (blocos e localidades). A ANOVA não acomoda nenhuma dessas três características.

**Por que distribuição beta?** A distribuição beta modela diretamente proporções no intervalo (0, 1), sem necessidade de transformação arco-seno, que produz estimativas viesadas nos extremos da distribuição.

**Por que efeitos aleatórios para bloco e localidade?** Os níveis observados representam uma amostra de condições possíveis. Modelá-los como aleatórios permite generalizar as conclusões para além das condições específicas do ensaio.

## Pacotes principais

| Pacote      | Função                                           |
|-------------|--------------------------------------------------|
| `glmmTMB`   | Ajuste de GLMM com distribuição beta e gaussiana |
| `DHARMa`    | Diagnóstico de resíduos por simulação            |
| `emmeans`   | Médias marginais e contrastes                    |
| `ggplot2`   | Visualizações                                    |
| `gt` / `DT` | Tabelas no relatório                             |
| `quarto`    | Relatório reprodutível                           |
| `renv`      | Gerenciamento de versões dos pacotes             |

## Como executar

### Com Docker

``` bash
docker build -t ensaio-fungicida .
docker run --rm -v $(pwd)/output:/project/output ensaio-fungicida
```

O relatório HTML será gerado em `output/relatorio.html`.

### Sem Docker

Restaure o ambiente e execute os scripts em ordem:

``` r
renv::restore()

source("R/01_simular_dados.R")
source("R/02_limpar_dados.R")
source("R/03_eda.R")
source("R/04_analise_glmm.R")

quarto::quarto_render("report/relatorio.qmd")
```

Ou rode o pipeline completo de uma vez:

``` r
source("rodar_pipeline.R")
```

### Configuração do renv (primeira vez)

Consulte o script `R/05_configurar_renv.R` para instruções detalhadas sobre como inicializar, registrar e restaurar o ambiente com `{renv}`.

## Autora

Jennifer Luz Lopes
