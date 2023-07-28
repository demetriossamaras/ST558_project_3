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

colnames(abalone) <- c("Sex", "Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" )



# Define server logic required to draw a histogram
function(input, output, session) {
  
  output$select <- renderUI({
    text <-paste0("Summary of ", input$var1, " abalone data")
    h5(text)
  })

    output$plot1 <- renderPlot({
      ##subsets rows based on selected range 
      abalone1 <- abalone[input$range[1]:input$range[2],]
      if(input$norg == "Graphical" & input$graph1 == "Scatterplot"){
        g <- ggplot(data=abalone1, aes(x= !!sym(input$explanvar ), y=!!sym(input$respvar )))
        g+ geom_point(aes(color= Sex)) + geom_smooth(method = "lm") + ggtitle("scatterplot")
      } else if(input$norg == "Graphical" & input$graph1 == "Boxplot"){
        h <- ggplot(data = abalone1, aes(x= Sex, y= Rings))
        h+ geom_boxplot(aes(color=Sex))
      }
                               })
    
    output$numericSum <- renderPrint({
      abalone2 <- abalone[input$range[1]:input$range[2],]
      if(input$var1=="Sex"){
      table(abalone2$Rings, abalone2$Sex)  
      }else if (input$var1!="Sex"){
      aa<- input$var1
      summary(abalone2[[aa]])
      }
    })

}
