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
library(tree)
library(randomForest)

abalone <- read.csv("abalone.data") %>% as_tibble 

colnames(abalone) <- c("Sex", "Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" )


dashboardPage(
    ## adds title 
    dashboardHeader(title = "Abalone age App"),
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
                               h4("Input desired predictors for each model, Rings is the response variable of interest"),
                               h5("For example, if you only want to look at only length as a predictor put 'Length' and if you want to use all predictors put ' . ' do not include quotes. After inputting desired predictors check the box at the bottom. Please be patient as the random forest will take a long time to run."), 
                               textInput("multiL1", label = "Multiple linear regression", value = "Length + Whole_weight"), 
                               textInput("regtree1", label = "Regression tree", value = "Length + Whole_weight"), 
                               textInput("randomf1", label = "Random forest", value = "."),
                               h5("select mtry value for random forest, must be equal to or less than number of predictors"),
                               numericInput("mtry1", label = "M = ", value = 2, min=1, max=8, step=1
                               ), 
                               h5("select size of training data set, test set will be 1- training set"), 
                               numericInput("trainsize", label = "Training set size(.5-.95)", value= .7, min=.5, max= .95, step = .05),
                               checkboxInput("check1", label = "Check when ready", value = FALSE)
                               
                                          ), 
                             ## sets up the layout and displays the output from the server
                             mainPanel(h4("Model fitting output info"),
                                       h5("Linear model training RMSE"), 
                                       verbatimTextOutput("lmRMSE"), 
                                       verbatimTextOutput("multiL2"),
                                       h5("Linear model test results"),
                                       verbatimTextOutput("multiL3"),
                                       h5("regression tree training RMSE"),
                                       verbatimTextOutput("regRMSE"),
                                       h5("Tree grown"),
                                       plotOutput("regtree2"),
                                       h5("Regression tree test results"),
                                       verbatimTextOutput("regtree3"),
                                       h5("Random forest training RMSE"),
                                       verbatimTextOutput("rfRMSE"), 
                                       h5("Variable importance"),
                                       plotOutput("randomf2"), 
                                       h5("Random forest test result "), 
                                       verbatimTextOutput("randomf3")
                                       )
                                         )
                           ), 
                  tabPanel("Prediction",
                           sidebarLayout(
                             sidebarPanel(
                               h4("Choose desired model for prediction"), 
                               h5("NOTE: You must have already run the models on the Model Fitting tab and the checkbox must be pressed"),
                               selectInput("modelSelect", label = "Model", choices = list("Linear model", "Tree model", "Random forest model")), 
                               textInput("pred", label = "Input prediction values. Must include a value for each predictor selected for the desired model on the Model Fitting tab and a comma seperating each predictor", value = "Length= .33, Whole_weight=.205")
                                          ), 
                             mainPanel(
                               h4("output for prediction"),
                               verbatimTextOutput("pred1")
                                       )  
                                         )
                           )
                              )
                          )
                ), 
        tabItem("data",
                fluidPage(
                  titlePanel("The Dataset"), 
                  sidebarLayout(
                    sidebarPanel(
                    h4("Here you can look through all the data, subset the data using the filters at the top, and save the data that you are looking at by clicking the 'csv' button")
                                 ), 
                    mainPanel(
                      dataTableOutput("dataTable")
                              )
                                )
                         )
                )
              )
                 )
)
