#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
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



# Define server logic required to draw a histogram
function(input, output, session) {

    output$dataTable <- renderDataTable({
iris

    })

}
