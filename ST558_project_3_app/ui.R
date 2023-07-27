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

colnames(abalone) <- c("Sex", "Length(mm)", "Diameter(mm)", "Height(mm)", "Whole weight(g)", "Shucked weight(g)", "Viscera weight(g)",  "Shell weight(g)", "Rings" )


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
                    sidebarPanel(h4("widgets for eda will go here")),
                  mainPanel(h4("output and graphs for eda will go here")
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
                             sidebarPanel(h4("widgets for model fitting")), 
                             mainPanel(h4("model fitting output info"))
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
