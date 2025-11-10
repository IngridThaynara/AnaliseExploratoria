rm(list =ls())
# Objetivo ####
# Os scripts desse repositório têm como objetivo fazer uma análise do banco de dados.
# O banco contém informações sobre detentos, incluindo idade, tempo preso em meses,
# sexo, filhos, estado civil, escolaridade e score de periculosidade.
# Neste script é feita uma análise exploratória visual e os gráficos são salvos.

# Caso seja a primeira vez utilizando o R, descomente e rode as linhas abaixo:
# install.packages("readxl")
# install.packages("dplyr")
# install.packages("naniar")
# install.packages("ggplot2")

# Liberando os pacotes que serão uteis nesse projeto #### 

library(readxl) # pacote para fazer a leitura do arquivo em .xlsx
library(dplyr)  # pacote para fazer as manipulações necessárias
library(naniar)   # pacote para explorar NA's
library(ggplot2) # pacote para fazer os gráficos

# Importando do banco de dados ####
base<- read_xlsx(path = "Base_trabalho.xlsx")

# Criando pasta para salvar os gráficos
dir.create("figs", showWarnings = FALSE)

# Transformando as variáveis qualitativas em fator 
base$escolaridade = as.factor(base$escolaridade)
base$reincidente = as.factor(base$reincidente)
base$filhos = as.factor(base$filhos)
base$sexo = as.factor(base$sexo)
base$casado = as.factor(base$casado)

# Fazendo uma análise sobre os dados faltantes ####

# Verificando em toda a base a quantidade de NAs
colSums(is.na(base))

# A partir disso, percebemos que não há dados faltantes no banco de dados que estamos trabalhando

# Histograma da variável idade ####

base |>
  ggplot(aes(x = idade)) +
  geom_histogram(
    bins = 25,               
    fill = "#69b3a2",             
    color = "white",              
    alpha = 0.8                   
  )+
  scale_x_continuous(
    breaks = seq(20, 100, by = 5)  # eixo x de 5 em 5 anos
  ) +
  labs(
    title = "Distribuição da Idade",
    x = "Idade (anos)",
    y = "Frequência"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(color = "gray85"),
    axis.title = element_text(face = "bold")
  )

ggsave("figs/hist_idade.png", last_plot(), width = 7, height = 5, dpi = 300)

# Boxplot da variável tempo_preso ####

base |>
  ggplot(aes(y = tempo_preso)) +
  geom_boxplot(
    fill = "#69b3a2",        
    color = "gray30",        
    alpha = 0.8,
    width = 0.3,            
    outlier.color = "red",   
    outlier.alpha = 0.6
  ) +
  labs(
    title = "Distribuição do Tempo de Prisão",
    y = "Tempo de prisão (meses)",
    x = NULL
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.title.y = element_text(face = "bold")
  )

ggsave("figs/box_tempo_preso.png", last_plot(), width = 6, height = 5, dpi = 300)

# Boxplot da variável score_periculosidade por escolaridade ####

base |>
  ggplot(aes(x = factor(escolaridade,
                        levels = c(1, 2, 3),
                        labels = c("Fundamental", "Médio", "Superior")),
             y = score_periculosidade)) +
  geom_boxplot(
    fill = "#69b3a2",
    color = "gray30",
    alpha = 0.8,
    outlier.color = "red",
    outlier.alpha = 0.6
  ) +
  labs(
    title = "Score de Periculosidade por Escolaridade",
    x = "Escolaridade",
    y = "Score de Periculosidade"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("figs/box_score_por_escolaridade.png", last_plot(), width = 7, height = 5, dpi = 300)

# Gráfico de barras para a variável reincidente ####

base |>
  ggplot(aes(x = factor(reincidente,
                        levels = c(0, 1),
                        labels = c("Não reincidente", "Reincidente")))) +
  geom_bar(
    fill = "#69b3a2",
    color = "gray30",
    alpha = 0.8,
    width = 0.6
  ) + 
  geom_text(stat = "count",
            aes(label = after_stat(count)),
            vjust = -0.3,
            fontface = "bold") +
  expand_limits(y = max(table(base$reincidente)) * 1.1) +  
  labs(
    title = "Distribuição de Reincidência",
    x = "Condição",
    y = "Frequência"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.title = element_text(face = "bold")
  )

ggsave("figs/bar_reincidente.png", last_plot(), width = 6, height = 5, dpi = 300)
