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

## reads in the dataset and names te colums
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
                    ## creates tags for the text to show up
                    h4("The purpose of this app is to explore the 'Abalone' dataset from the UC Irvine machine learning repository. This is a dataset that takes a number of physical measurements of collected Abalone and then counts the number of rings of the shell which gives the age of the animal(# of rings+ 1.5 = age in years). Because the rings are counted by cutting the shell open, staining it, and manually counting the rings, it would be great to be able to predict age without having to count rings. For more info on this data please follow this " , tags$a("Abalone link", href= "https://archive.ics.uci.edu/dataset/1/abalone"), ". Using this app you will be able to explore summaries about differnt parts of the data, devlop and test differnt models for predicting number of rings based on your chosen predictors, give novel values for prediction, investigate/subset the entire dataset, and save that subsetted data as a csv."), 
                    h4(" In the data exploration page you will be able to get numeric summaries about each variable in the data set and graph your desired variables of interest to explore the relationships between variables and get a sense for the dataset"), 
                    h4("In the Supervised Learning Models page you will be able to read a breif explanation of the models avalible on the modeling info tab. In the Model Fitting tab you will be able to set the predictiors that you want to use for your models and see how effective that model is. On the Prediction tab you will be able to give novel values to set for the predictors and see what the chosen model would predict based on those values."), 
                    h4("In the Dataset page you will be able to look at the entire dataset, subset based on you desired prefrences, and save the subsetted data of interest to a .csv"), 
                    h4("Below is a nice picture of an Abalone enjoying not being a part of this dataset. If it does not immediatly show up please be patient as it can take a second to render"),
                    ## outputs image generated by renderImage
                    imageOutput("image1")
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
                      h4("Choose rows of interest"), 
                      sliderInput("range", label="Desired rows",value=c(1,4176), min=1, max=4176, step=1
                                  ),
                      ## conditional panels based on summary input 
                      conditionalPanel(condition = "input.norg == 'Numeric'",                             selectInput("var1", label = "Variable to summarize", choices = list("Sex", "Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" ), selected = "Rings"
                                          )
                                       ),
                      ## condition panel to choose graph
                      conditionalPanel(condition= "input.norg == 'Graphical'",                  selectInput("graph1", label="Type of graph", choices = list ("Scatterplot", "Boxplot", "Histogram" )
                                           )
                                        ),
                      ## condition panel to choose variables based on graph
                      conditionalPanel(condition= "input.norg == 'Graphical' & input.graph1 == 'Scatterplot'",                                                              selectInput("respvar", label="Response variable", list("Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" ), selected = "Rings"
                                            ), 
                                selectInput("explanvar", label="Explanatory variable", list("Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" ), selected = "Legth"
                                            )
                                       ), 
                      ## conditional panel to choose histogram vars
                                conditionalPanel(condition= "input.norg == 'Graphical' & input.graph1 == 'Histogram'",                                                              selectInput("hisvar", label="Variable of interest", list("Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" ), selected = "Rings"
                                          )
                                               )
                                ),
                      
                  mainPanel(
                    ## outputs summaries generated by server
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
                  ## allows for mathtype through the panel 
                  withMathJax(), 
                  titlePanel("Supervised Learning Models"),
                  tabsetPanel(
                  tabPanel("Modeling Info",
                             mainPanel(
                               h4("Linear Regression Model"), 
                               h5(" A multiple linear regression model will generate a line of best fit that relates the response variable to the predictors with the general form of \\(Y+\\beta_0+\\beta_1x_1+\\beta_2x_2+\\cdots+\\beta_kx_k+\\varepsilon\\) where \\(\\beta_0\\) is the y intercept and each subsequent \\(\\beta_i\\) is the slope of the given predictor \\(x_i\\) and \\(\\varepsilon\\) is the random error. The main benefits of linear regression is that it is easy to use and interpret results from, it can also be extended to include interaction terms and quadratics with relative ease, and we can easily understand the influence that each predictor term had on the model. The main drawbacks of linear regression is that it is sensative to outliers and assumes that there is some kind of linear relationship which may not always be the case."), 
                               h4("Regression Tree Model"),
                               h5("A regression tree is a type of decision tree that will split up the predictor space into a number a regions and give differnt predictions based on the region. The main benefits of a regression tree are that the method is quick and the model created can be easily interpreted and understood. The main disadvantages are that they are vulnerable to overfitting which can be minimized by using pruning and they can have trouble using continous variables"), 
                               h4("Random Forest Model"), 
                               h5("A random forest model is an ensamble based method that generates a large number of decision trees using bootstraped samples of the data set and a random selection of the predictors \\(p\\) of size \\(m\\) where \\(m<p\\) and then combines these trees to form the model. We usually use \\(m=\\sqrt{p}\\) for classification and \\(m=\\frac{p}{3}\\) for regression. The biggest advantages are that you should have better predictability based on a better fit to the data and decreased variability because of the large number of trees being grown. The main disadvantages of this model is that you lose interpretability because it is a combination of a large number of trees, and that this model takes alot of computation and time to be generated.")
                                       )
                           ),
                  tabPanel("Model Fitting",
                           sidebarLayout(
                             sidebarPanel(
                               h4("Input desired predictors for each model, Rings is the response variable of interest"),
                               h5("For example, if you only want to look at only length as a predictor put 'Length' and if you want to use all predictors put ' . ' do not include quotes. After inputting desired predictors check the box at the bottom. Please be patient as the random forest will take a long time to run."),
                               ## allos the user to define desired predictors
                               textInput("multiL1", label = "Multiple linear regression", value = "Length + Whole_weight"), 
                               textInput("regtree1", label = "Regression tree", value = "Length + Whole_weight"), 
                               textInput("randomf1", label = "Random forest", value = "."),
                               h5("select mtry value for random forest, must be equal to or less than number of predictors"),
                               ## allows user to select mtry for rf
                               numericInput("mtry1", label = "M = ", value = 2, min=1, max=8, step=1
                               ), 
                               h5("select size of training data set, test set will be 1- training set"), 
                               ## allows user to select size of training and test set
                               numericInput("trainsize", label = "Training set size(.5-.95)", value= .7, min=.5, max= .95, step = .05),
                               ## allows user to run the models only when box is checked
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
                               ## allows user to select desired model
                               selectInput("modelSelect", label = "Model", choices = list("Linear model", "Tree model", "Random forest model")), 
                               ## user to input the predictions they used for the model
                               textInput("predP", label = "Input predictors used for the desired model. Must match the predictors of the model chosen, be seperated by a comma and have no spaces", value = "Length,Whole_weight"), 
                               ## user to input the novel value for those predictions
                               textInput("predN", label= "Input values for predictors in same order. Must be seperated by a comma", value = "0.5,0.4")
                                          ), 
                             mainPanel(
                               ## outputs prediction based on chosen values
                               h4("Table of desired predictor values"),
                               verbatimTextOutput("predTable"),
                               h4("predicted number of rings"), 
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
