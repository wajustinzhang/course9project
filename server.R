
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

if(!require('shiny')) install.packages("shiny")

library(shiny)
library(shinyjs)
library(stringr)
library(datasets)
library(ggplot2)

shinyServer(function(input, output, session) {
  output$dtype <- reactive({
    if(input$datasets == '')
      NULL
    else{
      dsString <- str_replace_all(unlist(strsplit(input$datasets, '\\('))[1], pattern = "\\s+", "")
      data<-get(dsString)
      class(data)
  }})
  
  outputOptions(output, "dtype", suspendWhenHidden = FALSE)  
  
  observe({
    if(input$datasets == '') {
      c<-c("mtcars", "iris", "volcano", "AirPassengers", "mdeaths", "treering", "uspop" ) #data()$results[, "Item"]
      updateSelectInput(session, "datasets", choices=c, selected=FALSE)  
    }
    else {
      dsString <- str_replace_all(unlist(strsplit(input$datasets, '\\('))[1], pattern = "\\s+", "")
      data<-get(dsString);
      dataCls <- class(data)
      
      if(dataCls == 'data.frame') {
        fac<-c()
        for(name in names(data)) {
          if(length(unique(data[[name]])) < 10)
            fac<-c(fac, name)
        }
        
        updateNumericInput(session, "header_rows", max=dim(data)[1])
        updateSelectInput(session, "attr1", choices=names(data), selected=FALSE)  
        updateSelectInput(session, "attr11", choices=names(data), selected=FALSE)
        updateSelectInput(session, "attr12", choices=names(data), selected=FALSE)  
        updateSelectInput(session, "attr13", choices=fac, selected=FALSE)         
        updateSelectInput(session, "attr21", choices=names(data), selected=FALSE)
        updateSelectInput(session, "attr22", choices=names(data), selected=FALSE)  
        updateSelectInput(session, "attr23", choices=fac, selected=FALSE)  
      }
    }
  })
  
  output$ui<- renderUI({
    tags <- c()
    if(input$datasets == '') {
      tages<-c(tags, renderPrint("Exploratory data analaysis content"))
      tagList(tags)
    }
    else {
      dsString <- str_replace_all(unlist(strsplit(input$datasets, '\\('))[1], pattern = "\\s+", "")
      data<-get(dsString)
      
      if(input$dtype) {
        tags<-c(tags, renderPrint(class(data)))
      }
      
      if(input$varType) {
        if(class(data)=='data.frame') {
          tags<-c(tags, renderPrint(sapply(data, class)))
        }
        else if(class(data)=='ts' || class(data) == 'matrix'){
           tags<-c(tags, renderPrint(unique(sapply(data, class))))
        }
      }
      
      dataCls <- class(data)
      if(input$dimension){ ## render dimension portion
        if(dataCls == 'data.frame' || dataCls == 'matrix' || dataCls == 'array')
          tags <- c(tags, renderPrint(dim(data)))  
      }
      
      if(input$header){
        if(dataCls == 'data.frame' || dataCls == 'matrix' || dataCls == 'array'){
          rows <-input$header_rows
          if(rows == '' || rows >dim(data)[1] )
            rows <- dim(data)[1]
          
          tag<-renderPrint(head(data, rows))
          tags <- c(tags, tag)
        }
      }
      
      if(input$summary) {
        tag<-renderPrint(summary(data))
        tags <- c(tags, tag)
      }
      
      if(input$histrogram){
        if(dataCls == 'data.frame'){
          if(input$attr1 != ''){
            tag<-renderPlot({
              apply(data[input$attr1][1],2, hist)
            })
            
            tags <- c(tags, tag)
          }
        }
      }
      
      if(input$scatterplot && class(data)=='data.frame') {
        if(input$attr11 != '' && input$attr12 != ''){
          if(input$attr13 != ''){
            sd<- data[, c(input$attr11, input$attr12, input$attr13)]
            tag<-renderPlot({
              ggplot(sd, aes(x=sd[[input$attr11]], y=sd[[input$attr12]])) +
                geom_boxplot(aes(fill= factor(sd[[input$attr13]]))) +
                xlab(input$attr21) +
                ylab(input$attr22)
            })
            tags <- c(tags, tag)
          }
          else{
            sd<- data[, c(input$attr11, input$attr12)]
            tag<-renderPlot({
              ggplot(sd, aes(x=sd[[input$attr11]], y=sd[[input$attr12]])) +
                geom_boxplot() +
                xlab(input$attr11) +
                ylab(input$attr12)
            })
            tags <- c(tags, tag)
          }          
          

        }
      }
      
      if(input$tsplot && class(data)=='ts'){
         tag<-renderPlot({plot(data)})
         tags <- c(tags, tag)
      }
      
      if(input$cooralation) {
        if(dataCls == 'data.frame'){
          if(input$attr21 != '' && input$attr22 != ''){
            if(input$attr23 != ''){
              selectedData<- data[, c(input$attr21, input$attr22, input$attr23)]
              tag<-renderPlot({
                ggplot(selectedData, aes(x=selectedData[[input$attr21]], y=selectedData[[input$attr22]])) +
                  geom_point(size=6,aes(colour = factor(selectedData[[input$attr23]]))) +
                  xlab(input$attr21) +
                  ylab(input$attr22)
              })
              tags <- c(tags, tag)
            }
            else{
              selectedData<- data[, c(input$attr21, input$attr22)]
              tag<-renderPlot({
                ggplot(selectedData, aes(x=selectedData[[input$attr21]], y=selectedData[[input$attr22]])) +
                  geom_point(size=6) +
                  xlab(input$attr21) +
                  ylab(input$attr22)
              })
              tags <- c(tags, tag)
            }
          }
        }
      }
      
      tagList(tags)      
    }      
  })      
})
  