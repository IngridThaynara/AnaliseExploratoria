rm(list =ls())
# Objetivo ####
# Os scripts desse repositório têm como objetivo fazer uma análise do banco de dados.
# O banco contém informações sobre detentos, incluindo idade, tempo preso em meses,
# sexo, filhos, estado civil, escolaridade e score de periculosidade.
# Neste script é feita uma análise exploratória com medidas de resumo e uma análise das variáveis quantitativas.

# Caso seja a primeira vez utilizando o R, descomente e rode as linhas abaixo:
# install.packages("readxl")
# install.packages("dplyr")
# install.packages("naniar")
# install.packages("ggplot2")
# install.packages("tidyr")

# Liberando os pacotes que serão uteis nesse projeto #### 

library(readxl) # pacote para fazer a leitura do arquivo em .xlsx
library(dplyr)  # pacote para fazer as manipulações necessárias
library(naniar)   # pacote para explorar NA's
library(ggplot2) # pacote para fazer os gráficos
library(tidyr)

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

# Obtendo a média, 1o quartil, mediana e 3o quartil para as variáveis score_periculosidade, idade e tempo_preso ####

tabela_resumo <- base |>
  summarise(
    Variável = c("score_periculosidade", "idade", "tempo_preso"),
    Média = c(mean(score_periculosidade, na.rm = TRUE),
              mean(idade, na.rm = TRUE),
              mean(tempo_preso, na.rm = TRUE)),
    "1º quartil" = c(quantile(score_periculosidade, 0.25, na.rm = TRUE),
           quantile(idade, 0.25, na.rm = TRUE),
           quantile(tempo_preso, 0.25, na.rm = TRUE)),
    Mediana = c(median(score_periculosidade, na.rm = TRUE),
                median(idade, na.rm = TRUE),
                median(tempo_preso, na.rm = TRUE)),
    "3º quartil" = c(quantile(score_periculosidade, 0.75, na.rm = TRUE),
           quantile(idade, 0.75, na.rm = TRUE),
           quantile(tempo_preso, 0.75, na.rm = TRUE))
  ) |>
  unnest(cols = c(Variável, Média, "1º quartil", Mediana, "3º quartil"))

# Gráfico de dispersão entre tempo_preso e score_periculosidade ####

base |>
  ggplot(aes(x = tempo_preso, y = score_periculosidade)) +
  geom_point(
    color = "#69b3a2",   
    alpha = 0.7,         
    size = 2             
  ) +
  labs(
    title = "Relação entre Tempo de Prisão e Score de Periculosidade",
    x = "Tempo de prisão (meses)",
    y = "Score de Periculosidade"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.title = element_text(face = "bold")
  )

ggsave("figs/disp_tempo_vs_score.png", last_plot(), width = 7, height = 5, dpi = 300) # Salvando o gráfico em .png na pasta criada

# Calculando a correlação entre as duas variáveis ####

cor(base$tempo_preso, base$score_periculosidade, use = "complete.obs")

# Obtendo variância, desvio padrão e amplitude para as variáveis score_periculosidade, idade e tempo_preso ####

tabela_dispersao <- base |>
  summarise(
    Variável = c("score_periculosidade", "idade", "tempo_preso"),
    Variância = c(var(score_periculosidade, na.rm = TRUE),
                  var(idade, na.rm = TRUE),
                  var(tempo_preso, na.rm = TRUE)),
    "Desvio padrão" = c(sd(score_periculosidade, na.rm = TRUE),
                        sd(idade, na.rm = TRUE),
                        sd(tempo_preso, na.rm = TRUE)),
    Amplitude = c(
      max(score_periculosidade, na.rm = TRUE) - min(score_periculosidade, na.rm = TRUE),
      max(idade, na.rm = TRUE) - min(idade, na.rm = TRUE),
      max(tempo_preso, na.rm = TRUE) - min(tempo_preso, na.rm = TRUE))
  ) |>
  unnest(cols = c(Variável, Variância, "Desvio padrão", Amplitude))

# Tabela final contendo todas as medidas de resumo que foram calculadas nesse script 

tabela_final <- tabela_resumo |>
  left_join(tabela_dispersao, by = "Variável") # Fazendo uma concatenação das duas tabelas criadas nesse script 

tabela_final <- tabela_final |>
  mutate(across(where(is.numeric), round, 2)) # Arredondando os valores das medidas de resumo para duas casas decimais.
 
write.csv(tabela_final, "tabela_final.csv", row.names = FALSE) #Exportando as medidas de resumo das variáveis quantitativas. 

