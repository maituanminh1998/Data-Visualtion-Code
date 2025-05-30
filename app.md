---
title: "R Notebook"
output: html_notebook
---

In Vietnam, to sell a industrial washing machine (typically above 30 kg/batch), you need to go through bidding process because the selling price usually above 100 million VND and the hospital do not want to have legal problems.

Hence, the process of choosing the best bidder usually go though company profile, technical fullfilment (usually lock in 2-3 models on the market) and lastly price. Since all the models of washer machine which won the contracts will have price release publicly. We can use a corporate account to get the data, the problems are that data are not clean due to the fact that they are all manually key in by non-IT and the data are super messy, which take up to a day just to clean the data.

I have allowed user to select year, select province, select brand and have the data appear as  bar chart (Averge wining price by provience), box plot (price range by province), pie chart (market share), line chart (tenders over time), scatter plot (price vs capacity), filtered table (to see all the data)

These tools can help to predicts price of opponent and predict more precise pricing point so that the company can have maximum profit gain while winning the bid

```{r}
install.packages('rsconnect')
rsconnect::setAccountInfo(name='maituanminh', token='9296D6D026886417BECF0BACEF23BEBC', secret='OSsdwfLzFJFiUdSMomAnS9ocMktvtt2i55kEbaLS')

install.packages("shiny")
library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("My Cool App"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("name", "Enter your name:", ""),
      actionButton("greet_btn", "Greet Me")
    ),
    
    mainPanel(
      h3(textOutput("greeting_output"))
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$greeting_output <- renderText({
    req(input$greet_btn)  # only respond after button is clicked
    paste("Hello,", input$name, "!")
  })
}

# Run the app
shinyApp(ui = ui, server = server)


```

