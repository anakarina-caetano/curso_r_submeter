library(ROAuth)
library(rDrop)
library(shiny)
library(shinyBS)
library(magrittr)
library(lubridate)

load('credentials.RData')

verifica_extensao <- function(a) {
  tolower(regmatches(a, regexpr('.[^.]*$', a))) == '.rmd'
}

shinyServer(function(input, output, session) {


  arq <- reactive({
    arq_metadados <- input$arquivo %>% as.data.frame
    if(is.null(input$arquivo)) { # verifica se algo foi carregado
      return(NULL)
    } else { # caso tenha algo carregado...

      s <- readChar(arq_metadados$datapath, 99999999)

      Sys.sleep(.1)
      progress <- shiny::Progress$new(session)
      progress$set(message = 'Processando arquivo...', detail = "Por favor aguarde.")

      resp <- NULL
      tryCatch({
        if(!verifica_extensao(arq_metadados$name)) {
          stop()
        }
        resp <- s
      },
      error = function(erro) {
        resp <<- NULL
        # mensagem de ERRO

        createAlert(session,
                    inputId = "alerta_arq",
                    message = "O arquivo selecionado não parece ser um '.Rmd' válido.",
                    type = "danger",
                    dismiss = TRUE,
                    block = FALSE,
                    append = FALSE
        )
      }, finally = progress$close())

      if(resp %>% is.null %>% not) {

        # mensagem de OK
        createAlert(session, inputId = "alerta_arq",
                    message = "Arquivo carregado com sucesso!",
                    type = "success",
                    dismiss = TRUE,
                    block = FALSE,
                    append = FALSE
        )
      }
      return(resp)
    }
  })
  # booleano para usar no conditionalPanel
  output$arquivoCarregado <- reactive({
    return(!is.null(arq()))
  })

  output$visualizador <- renderText({
    arq()
  })

  observe({
    x <- arq()
    arq_metadados <- input$arquivo %>% as.data.frame

    if(input$submit > 0 & length(x) > 0) {

      dttime <- now() %>% as.character %>% gsub(' |-|:', '_', .)
      arq <- paste(dttime, gsub('.[^.]*$', '', arq_metadados$name), sep='_')

      lista_arqs <- list(texto=x, email1=input$email1, email2=input$email2)

      dropbox_save(dropbox_credentials,
                   .objs=lista_arqs,
                   file=arq,
                   verbose=TRUE,
                   ext = ".rds")

      createAlert(session, inputId = "alerta_submit",
                  message = "Upload realizado com sucesso!",
                  type = "success",
                  dismiss = TRUE,
                  block = FALSE,
                  append = FALSE
      )
    } else {
      updateButton(session, 'submit', value=0)
    }
  })

  output$arquivo_carregado <- renderDataTable({
    x <- as.data.frame(input$arquivo)
  })

})
