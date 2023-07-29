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
library(tree)
library(randomForest)

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
    ## outputs the numeric summary
    output$numericSum <- renderPrint({
      ## outputs contingency table of sex vs rings
      abalone2 <- abalone[input$range[1]:input$range[2],]
      if(input$var1=="Sex"){
      table(abalone2$Rings, abalone2$Sex)  
      ## outputs summary stats for other variables 
      }else if (input$var1!="Sex"){
      aa<- input$var1
      summary(abalone2[[aa]])
      }
  })
    
    ## linear regression model 
    linear1 <- reactive({
      if(input$check1){
       set.seed(13) 
        train <- sample(1:nrow(abalone), size = nrow(abalone)*input$trainsize )
        test <- setdiff(1:nrow(abalone), train)
        
        # training and testing subsets
        abalone_train <- abalone[train, ]
        abalone_test <- abalone[test, ]
        
        lmodel1 <- reformulate(input$multiL1, response = "Rings")
        linear_model_1 <- train(lmodel1 , 
                                data = abalone_train,
                                 method = "lm",
                                 preProcess = c("center", "scale"),
                                 trControl = trainControl(method = "cv", 
                                                          number = 5))
         linear_model_1
      }
      
  })
    
    output$lmRMSE <- renderPrint({
      if(input$check1){
        lmModel <-linear1()
        lmModel$results$RMSE
      }
      
    })
    
    output$multiL2 <- renderPrint({
      if(input$check1){
        summary(linear1())
      }
      
    })
    
    output$multiL3 <- renderPrint({
      if(input$check1){
      ##prediction of model on test 
      linear_model_1_pred <- predict(linear1(), newdata = dplyr::select(abalone_test, -Rings))
      
      ## storing error of model on test set 
      linear_1_RMSE<- postResample(linear_model_1_pred, obs = abalone_test$Rings)
      ## outputs results
      
      linear_1_RMSE
      }
    })
    
    tree1<- reactive({
      if(input$check1){
        set.seed(13) 
        train <- sample(1:nrow(abalone), size = nrow(abalone)*input$trainsize )
        test <- setdiff(1:nrow(abalone), train)
        
        # training and testing subsets
        abalone_train <- abalone[train, ]
        abalone_test <- abalone[test, ]
        
        treemodel1 <- reformulate(input$regtree1, response = "Rings")
        tree_model_1 <- train(treemodel1, 
                              data = abalone_train,
                              method = "rpart",
                              preProcess = c("center", "scale"),
                              trControl = trainControl(method = "cv", number = 5))
        
        tree_model_1
        
      }
    })
    output$regRMSE <- renderPrint({
      if(input$check1){
        treeModel <-tree1()
        treeModel$results$RMSE
      }
      
    })
    
   output$regtree2<- renderPlot({
     if(input$check1){
     treeModel <-tree1() 
     plot(treeModel$finalModel)
     text(treeModel$finalModel)
     }
   })
    
    output$regtree3 <- renderPrint({
      if(input$check1){
      tree_model_1_pred <- predict(tree1(), newdata = dplyr::select(abalone_test, -Rings))
      ## storing error of model on test set 
      tree_1_RMSE<- postResample(tree_model_1_pred, obs = abalone_test$Rings)
      
      tree_1_RMSE 
      }
    })
    
    forest1 <- reactive({
      if(input$check1){
        set.seed(13) 
        train <- sample(1:nrow(abalone), size = nrow(abalone)*input$trainsize )
        test <- setdiff(1:nrow(abalone), train)
        
        # training and testing subsets
        abalone_train <- abalone[train, ]
        abalone_test <- abalone[test, ]
        
        rfmodel1 <- reformulate(input$randomf1 , response = "Rings")
        rf_model_1 <- train(rfmodel1 , 
                              data = abalone_train,
                              method = "rf",
                              preProcess = c("center", "scale"),
                             trControl = trainControl(method = "cv", number = 5), tuneGrid = expand.grid(mtry= input$mtry1))
        
        rf_model_1
      }
    })
    
    output$rfRMSE <- renderPrint({
      if(input$check1){
        rfModel <-forest1()
        rfModel$results$RMSE
      }
      
    })
    
    output$randomf2 <- renderPlot({
      if(input$check1){
        varImp(forest1()) %>% plot()
      }
    })
    
    output$randomf3 <- renderPrint({
      if(input$check1){
        rf_model_1_pred <- predict(forest1(), newdata = dplyr::select(abalone_test, -Rings))
        
        ## storing error of model on test set 
       rf_1_RMSE<- postResample(rf_model_1_pred, obs = abalone_test$Rings)
        
        rf_1_RMSE
     }
    })
    
    output$pred1 <- renderPrint({
      if(input$check1 & input$modelSelect=="Linear model"){
        data1 <- data.frame(!!sym(input$pred))
        data1
        #prediction1 <- predict(linear1(), newdata= data1)
        #prediction1
        
      }else if(input$check1 & input$modelSelect=="Tree model"){
        
      }else if(input$check1 & input$modelSelect=="Random forest model"){
        
      }
      
    })
    
    output$dataTable <- renderDataTable({
      ## creates a data table for the abalone data set
      datatable(abalone,
                ## sets options 
                options = list(paging = TRUE,    
                               pageLength = 50, 
                               scrollX = TRUE,  
                               scrollY = TRUE,
                               autoWidth = TRUE, 
                               server = TRUE,   
                               dom = 'Bfrtip',
                               buttons = c('csv'),
                               columnDefs = list(list(targets = '_all', className = 'dt-center'))
                ),
                ## allows visible data to be saved with server=TRUE
                extensions = 'Buttons',
                selection = 'multiple',
                filter = 'top',              
                rownames = TRUE              
      )
      
    })
    
    

}
