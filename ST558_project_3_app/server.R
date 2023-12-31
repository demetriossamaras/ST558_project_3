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

## reads in the dataset and names te colums 
abalone <- read.csv("abalone.data") %>% as_tibble 

colnames(abalone) <- c("Sex", "Length", "Diameter", "Height", "Whole_weight", "Shucked_weight", "Viscera_weight",  "Shell_weight", "Rings" )



# Define server logic required to draw a histogram
function(input, output, session) {
  
  ## creates te image and stores in output$image1
  output$image1 <- renderImage({
    
    filename <- normalizePath(file.path('./www/images','Abalone-noaa.jpg'))
    
    list(src = filename,
         contentType = 'image/png',
         alt = "This is alternate text")
    
  }, deleteFile=FALSE )
  
  output$select <- renderUI({
    text <-paste0("Summary of ", input$var1, " abalone data")
    h5(text)
  })

    output$plot1 <- renderPlot({
      ##subsets rows based on selected range 
      abalone1 <- abalone[input$range[1]:input$range[2],]
      ## creats graphs based on selected inputs 
      if(input$norg == "Graphical" & input$graph1 == "Scatterplot"){
        g <- ggplot(data=abalone1, aes(x= !!sym(input$explanvar ), y=!!sym(input$respvar )))
        g+ geom_point(aes(color= Sex)) + geom_smooth(method = "lm") + ggtitle("Scatterplot")
      } else if(input$norg == "Graphical" & input$graph1 == "Boxplot"){
        h <- ggplot(data = abalone1, aes(x= Sex, y= Rings))
        h+ geom_boxplot(aes(color=Sex))+ggtitle("# of rings by Sex")
      } else if (input$norg == "Graphical" & input$graph1 == "Histogram"){
        g <- ggplot(data=abalone, aes(x= !!sym(input$hisvar)))
        g+ geom_histogram( color="red", fill="blue", ) + ggtitle("Histogram")
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
        test <- dplyr::setdiff(1:nrow(abalone), train)
        
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
    ## renders rmse train
    output$lmRMSE <- renderPrint({
      if(input$check1){
        lmModel <-linear1()
        lmModel$results$RMSE
      }
      
    })
    ## renders summary train
    output$multiL2 <- renderPrint({
      if(input$check1){
        summary(linear1())
      }
      
    })
    ## tests on test set renders result 
    output$multiL3 <- renderPrint({
      if(input$check1){
        set.seed(13) 
        train <- sample(1:nrow(abalone), size = nrow(abalone)*input$trainsize )
        test <- dplyr::setdiff(1:nrow(abalone), train)
        
        # training and testing subsets
        abalone_train <- abalone[train, ]
        abalone_test <- abalone[test, ]
      ##prediction of model on test 
      linear_model_1_pred <- predict(linear1(), newdata = dplyr::select(abalone_test, -Rings))
      
      ## storing error of model on test set 
      linear_1_RMSE<- postResample(linear_model_1_pred, obs = abalone_test$Rings)
      ## outputs results
      
      linear_1_RMSE
      }
    })
    ## creates tree model
    tree1<- reactive({
      if(input$check1){
        set.seed(13) 
        train <- sample(1:nrow(abalone), size = nrow(abalone)*input$trainsize )
        test <- dplyr::setdiff(1:nrow(abalone), train)
        
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
        set.seed(13) 
        train <- sample(1:nrow(abalone), size = nrow(abalone)*input$trainsize )
        test <- dplyr::setdiff(1:nrow(abalone), train)
        
        # training and testing subsets
        abalone_train <- abalone[train, ]
        abalone_test <- abalone[test, ]
      tree_model_1_pred <- predict(tree1(), newdata = dplyr::select(abalone_test, -Rings))
      ## storing error of model on test set 
      tree_1_RMSE<- postResample(tree_model_1_pred, obs = abalone_test$Rings)
      
      tree_1_RMSE 
      }
    })
    ## creates random forrest model
    forest1 <- reactive({
      if(input$check1){
        set.seed(13) 
        train <- sample(1:nrow(abalone), size = nrow(abalone)*input$trainsize )
        test <- dplyr::setdiff(1:nrow(abalone), train)
        
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
        set.seed(13) 
        train <- sample(1:nrow(abalone), size = nrow(abalone)*input$trainsize )
        test <- dplyr::setdiff(1:nrow(abalone), train)
        
        # training and testing subsets
        abalone_train <- abalone[train, ]
        abalone_test <- abalone[test, ]
        rf_model_1_pred <- predict(forest1(), newdata = dplyr::select(abalone_test, -Rings))
        
        ## storing error of model on test set 
       rf_1_RMSE<- postResample(rf_model_1_pred, obs = abalone_test$Rings)
        
        rf_1_RMSE
     }
    })
    ## shoes the table of novel predictors selected 
    output$predTable <- renderPrint({
      if(input$check1){
        ## makes a names vector based on predictors input
        names<- unlist(strsplit(input$predP, ",")) %>% c()
        ## makes a values dataframe based on predictor values given
        values<- unlist(strsplit(input$predN, ",")) %>% as.numeric()
        names(values)<- names
        values <- data.frame(t(values))
        values 
      }
      
    })
    ## makes prediction based on inputted values and model selected
    output$pred1 <- renderPrint({
      if(input$check1 & input$modelSelect=="Linear model"){
        ## makes a names vector based on predictors input
        names<- unlist(strsplit(input$predP, ",")) %>% c()
        ## makes a values dataframe based on predictor values given
        values<- unlist(strsplit(input$predN, ",")) %>% as.numeric()
        names(values)<- names
        values <- data.frame(t(values))
      
        prediction1 <- predict(linear1(), newdata= values)
        prediction1
        
      }else if(input$check1 & input$modelSelect=="Tree model"){
        names<- unlist(strsplit(input$predP, ",")) %>% c()
        ## makes a values dataframe based on predictor values given
        values<- unlist(strsplit(input$predN, ",")) %>% as.numeric()
        names(values)<- names
        values <- data.frame(t(values))
        
        prediction1 <- predict(tree1(), newdata= values)
        prediction1
        
      }else if(input$check1 & input$modelSelect=="Random forest model"){
        names<- unlist(strsplit(input$predP, ",")) %>% c()
        ## makes a values dataframe based on predictor values given
        values<- unlist(strsplit(input$predN, ",")) %>% as.numeric()
        names(values)<- names
        values <- data.frame(t(values))
        
        prediction1 <- predict(forest1(), newdata= values)
        prediction1
        
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
