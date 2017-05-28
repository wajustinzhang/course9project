
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
if(!require('shiny')) install.packages("shiny")

library(shiny)

shinyUI(fluidPage(
  # Application title
  titlePanel("Exploratory Data Analysis"),

  sidebarLayout(
    sidebarPanel(
      ## Select the datasource
      selectInput("datasets", "Select dataset", choices=NULL),
      
      fluidRow(column(width=10, checkboxInput("dtype", "Dataset type", FALSE))),
      fluidRow(column(width=10, checkboxInput("varType", "Variable type", FALSE))),
      fluidRow(column(width=10, checkboxInput("dimension", "Dimension", FALSE))),
      fluidRow(column(width=5,  checkboxInput("header", "Header", FALSE)),
               column(width=5,numericInput("header_rows", "Rows?", value=5, min=0))),
      fluidRow(column(width=10,  checkboxInput("summary", "Summary", FALSE))),
      fluidRow(column(width=5, checkboxInput("histrogram", "Histrogram", FALSE)),
               column(width=5,selectInput("attr1", "Attribute", choices=NULL))),
      
      fluidRow(column(width=10, checkboxInput("cooralation", "Correlation", FALSE))),
      
      fluidRow(column(width=4,selectInput("attr22", "Y attribute", choices=NULL)),
               column(width=4,selectInput("attr21", "X attribute", choices=NULL)),
               column(width=4,selectInput("attr23", "Color attr", choices=NULL)))
    ),
    
    mainPanel(
      uiOutput("ui")
    )
  )

))
