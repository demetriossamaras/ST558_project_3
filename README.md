# ST558_project_3

This app is the final project for ST 558. The goal of this app is to be able to explore the 'Abalone' dataset, develop models with predictors selected by the user, and predict with novel predictor values using the trained model. 

The packages needed to run the app are:
library(shiny)
library(tidyverse)
library(caret)
library(DT)
library(ggplot2)
library(shinydashboard)
library(tree)
library(randomForest)

If you do not have these packages installed the following line will install all packages needed:
install.packages(c("shiny", "tidyverse", "caret", "DT", "ggplot2", "shinydashboard", "tree", "randomForest" ))

In order to run the app with the shiny::runGitHub() command run the following line:
shiny::runGitHub(repo= "ST558_project_3", username="demetriossamaras", ref="main", subdir = "ST558_project_3_app")
