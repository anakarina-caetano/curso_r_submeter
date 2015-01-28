
library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Submissão de exercícios"),

  wellPanel(
    tags$p('Por favor escreva a primeira parte do seu e-mail no nome do arquivo'),

    tags$p('Por exemplo, se seu e-mail é joao.claudio@gmail.com, submeta o arquivo com nome joao.claudio.Rmd'),

    tags$div(textInput('email1', 'Email 1'), style='width:300px'),

    tags$div(textInput('email2', 'Email 2'), style='width:300px'),

    fileInput("arquivo", "Por favor, selecione o arquivo .Rmd"),

    actionButton('submit', "Submeter"),

    bsAlert('alerta_arq'),

    bsAlert('alerta_submit')
  ),
  wellPanel(
    dataTableOutput("arquivo_carregado")
  ),
  wellPanel(
    verbatimTextOutput("visualizador")
  )
))
