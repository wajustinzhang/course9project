
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
  observe({
    if(input$datasets == '') {
      c<-c("mtcars", "iris" ) #data()$results[, "Item"]
      updateSelectInput(session, "datasets", choices=c, selected=FALSE)  
    }
    else {
      dsString <- str_replace_all(unlist(strsplit(input$datasets, '\\('))[1], pattern = "\\s+", "")
      data<-get(dsString);
      dataCls <- class(data)
      
      if(dataCls == 'data.frame') {
        updateNumericInput(session, "header_rows", max=dim(data)[1])
        print("updateAttributes")
        updateSelectInput(session, "attr1", choices=names(data), selected=FALSE)  
        updateSelectInput(session, "attr21", choices=names(data), selected=FALSE)
        updateSelectInput(session, "attr22", choices=names(data), selected=FALSE)  
        updateSelectInput(session, "attr23", choices=names(data), selected=FALSE)  
      }
    }
  })
  
  output$ui<- renderUI({
    if(input$datasets == '')
      return()
    
    tags <- c();
    
    dsString <- str_replace_all(unlist(strsplit(input$datasets, '\\('))[1], pattern = "\\s+", "")
    data<-get(dsString);
    
    if(input$dtype) {
      tags<-c(tags, renderPrint(class(data)))
    }
    
    if(input$varType) {
      tags<-c(tags, renderPrint(lapply(data, class)))
    }
    
    dataCls <- class(data)
    if(input$dimension){ ## render dimension portion
      if(dataCls == 'data.frame' || dataCls == 'matrix' || dataCls == 'array')
        tags <- c(tags, renderPrint(dim(data)))  
      else {
        tags <- c(tags, renderPrint('No dimension for non-tabular dataset or array'))  
      }
    }
    
    if(input$header){
      if(dataCls == 'data.frame' || dataCls == 'matrix' || dataCls == 'array'){
        rows <-input$header_rows
        if(rows == '' || rows >dim(data)[1] )
          rows <- dim(data)[1]
        
        tag<-renderPrint(head(data, rows))
        tags <- c(tags, tag)
      }
      else {
        if(dataCls == 'ts') {
           tags <- c(tags, renderText('For time series data, show first 100 data'))  
           tags <- c(tags,  renderPrint({data[1:100]}))  
        }
        else{
          tags <- c(tags, renderPrint('No header information for non-tabular dataset or array'))  
        }
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
  })      
})
  
