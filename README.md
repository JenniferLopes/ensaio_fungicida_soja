# Ensaio de eficacia de fungicida em soja

Analise estatistica de um ensaio de campo simulado para avaliacao da eficacia de fungicida na cultura da soja.
O projeto demonstra um pipeline reprodutivel completo: simulacao de dados, limpeza, analise exploratoria, modelagem com GLMM e relatorio em Quarto, containerizado com Docker.

## Contexto

A ferrugem asiatica da soja (*Phakopsora pachyrhizi*) e uma das principais doencas da cultura no Brasil.
Este ensaio avalia quatro tratamentos (controle e tres doses de fungicida) em delineamento de blocos casualizados completos (RCBD) com medicoes em tres momentos apos a aplicacao, conduzido em tres localidades.

Os dados foram simulados para reproduzir a estrutura e a variabilidade de um ensaio real de registro de defensivo agricola.

## Estrutura do projeto

```
ensaio_fungicida_soja/
├── Dockerfile
├── README.md
├── renv.lock
├── R/
│   ├── 01_simular_dados.R
│   ├── 02_limpar_dados.R
│   ├── 03_eda.R
│   └── 04_analise_glmm.R
├── report/
│   ├── relatorio.qmd
│   └── estilo.css
├── data/
│   ├── raw/
│   └── processed/
└── output/
    ├── figuras/
    ├── tabelas/
    └── modelos/
```

## Variaveis simuladas

| Variavel | Descricao |
|---|---|
| `tratamento` | Controle, dose baixa, dose media, dose alta |
| `bloco` | 6 blocos (efeito aleatorio) |
| `local` | 3 localidades (efeito aleatorio) |
| `tempo_dias` | 30, 60 e 90 dias apos aplicacao |
| `umidade_rel` | Umidade relativa do ar (%) |
| `temp_media` | Temperatura media diaria (graus C) |
| `severidade` | Percentual de area foliar afetada (0-100) |
| `produtividade` | Producao de graos (kg/ha) |

## Analises realizadas

- Analise exploratoria com distribuicoes, evolucao temporal e relacao com covariáveis ambientais
- GLMM com distribuicao beta para a severidade (proporcao de area foliar afetada)
- LMM gaussiano para a produtividade
- Diagnostico de residuos com simulacao via `{DHARMa}`
- Selecao de modelo por AIC
- Medias marginais estimadas e comparacoes multiplas com correcao de Tukey via `{emmeans}`
- Componentes de variancia dos efeitos aleatorios (bloco e localidade)

## Pacotes principais

| Pacote | Funcao |
|---|---|
| `glmmTMB` | Ajuste de GLMM com distribuicao beta e gaussiana |
| `DHARMa` | Diagnostico de residuos por simulacao |
| `emmeans` | Medias marginais e contrastes |
| `ggplot2` | Visualizacoes |
| `gt` / `DT` | Tabelas no relatorio |
| `quarto` | Relatorio reprodutivel |

## Como executar

### Com Docker

```bash
docker build -t ensaio-fungicida .
docker run --rm -v $(pwd)/output:/project/output ensaio-fungicida
```

O relatorio HTML sera gerado em `output/relatorio.html`.

### Sem Docker

Restaure o ambiente com `{renv}` e execute os scripts em ordem:

```r
renv::restore()

source("R/01_simular_dados.R")
source("R/02_limpar_dados.R")
source("R/03_eda.R")
source("R/04_analise_glmm.R")

quarto::quarto_render("report/relatorio.qmd")
```

## Autora

Jennifer Luz Lopes
