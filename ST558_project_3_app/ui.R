#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(caret)
library(DT)
library(ggplot2)
library(shinydashboard)

abalone <- read.csv("abalone.data") %>% as_tibble 

colnames(abalone) <- c("Sex", "Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" )


dashboardPage(
    ## adds title 
    dashboardHeader(title = "Cancer Diagnosis App"),
    ## adds tabs 
    dashboardSidebar(sidebarMenu(
      menuItem("About", tabName = "about"),
      menuItem("Exploration", tabName = "explore"),
      menuItem("Modeling", tabName = "modeling"),
      menuItem("Data", tabName = "data")
                      )          ),
    ## adds body of tabs
    dashboardBody(
      ## attached to set tabs 
      tabItems(
        ## fills the specific tab with code 
        tabItem("about", 
                fluidPage(
                  titlePanel("About the App"), 
                  mainPanel(
                    h4("this is where the info about the app will go. it is about using measurements of abalone to predict age")
                            )
                          )
                ), 
        tabItem("explore", 
                fluidPage(
                  titlePanel("Data Exploration"), 
                  sidebarLayout(
                    sidebarPanel(
                      h4("Select the type of summary"), 
                      ## set up widget to select summay 
                      selectInput("norg", label = "Summary type", choices = list("Numeric", "Graphical")     ), 
                      h4("Select desired rows"), 
                      sliderInput("range", label="Desired rows",value=c(1,4176), min=1, max=4176, step=1
                                  ),
                      ## conditional panels based on summary input 
                      conditionalPanel(condition = "input.norg == 'Numeric'",                             selectInput("var1", label = "Variable to summarize", choices = list("Sex", "Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" )
                                          )
                                       ),
                      ## condition panel to choose graph
                      conditionalPanel(condition= "input.norg == 'Graphical'",                  selectInput("graph1", label="Type of graph", choices = list ("Scatterplot", "Boxplot" )
                                           )
                                        ),
                      ## condition panel to choose variables based on graph
                      conditionalPanel(condition= "input.norg == 'Graphical' & input.graph1 == 'Scatterplot'",                                                              selectInput("respvar", label="Response variable", list("Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" ), selected = "Rings"
                                            ), 
                                selectInput("explanvar", label="Explanatory variable", list("Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" ), selected = "Legth"
                                            )
                                       )
                                ),
                      
                  mainPanel(
                    h4("Numeric summaries and graphs for EDA"),
                    uiOutput("select"),
                    verbatimTextOutput("numericSum"), 
                    plotOutput("plot1")
                    
                            )
                                )
                         )
                ), 
        tabItem("modeling", 
                fluidPage(
                  titlePanel("Supervised Learning Models"),
                  tabsetPanel(
                  tabPanel("Modeling Info",
                             mainPanel(h4("mathjax and explan 3 models"))
                           ),
                  tabPanel("Model Fitting",
                           sidebarLayout(
                             sidebarPanel(
                               h4("Select model type"), 
                               selectInput("model1", list())
                                          ), 
                             mainPanel(h4("model fitting output info")
                                       )
                                         )
                           ), 
                  tabPanel("Prediction",
                           sidebarLayout(
                             sidebarPanel(h4("widgets for prediction")), 
                             mainPanel(h4("output for prediction"))  
                                         )
                           )
                              )
                          )
                ), 
        tabItem("data",
                fluidPage(
                  titlePanel("The Dataset"), 
                  sidebarLayout(
                    sidebarPanel(h4("widgets for subsetting data")), 
                    mainPanel(h4("all the data in a table that can be scrolled through"))
                                )
                         )
                )
              )
                 )
)
