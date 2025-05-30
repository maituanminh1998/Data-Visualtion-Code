In Vietnam, selling industrial washing machines (typically with capacities above 30 kg per batch) to public hospitals generally requires participation in the public bidding process. This is primarily because the unit price often exceeds 100 million VND, and hospitals prefer this method to avoid legal and compliance issues.

The evaluation process for selecting a winning bidder typically involves three key stages:
1/Company Qualification Review: Assessing the credibility and legal status of the bidding company.
2/ Technical Specification Fulfillment: Comparing product specifications against bidding documents, which usually shortlist 2–3 specific models already available in the market.
3/ Price Evaluation: Once technical compliance is confirmed, price becomes the final determining factor.

As part of Vietnam’s transparency policy, the prices of all awarded contracts are published publicly. Leveraging a corporate account, we can access this data. However, a major challenge lies in the data quality—since the entries are manually input by non-technical staff, the dataset is often inconsistent, unstructured, and time-consuming to clean (taking up to a full day per dataset).

To address this, I have developed an interactive dashboard that allows users to:
- Select filters by year, province, and brand
- Visualize key metrics:
+ Bar chart: Average winning price by province
+ Box plot: Price distribution per province
+ Pie chart: Market share by brand
+ Line chart: Number of tenders over time
+ Scatter plot: Price vs. machine capacity
+ Interactive table: Filtered view of raw tender data

These analytics tools serve not just as reporting instruments, but as strategic tools to:
+ Forecast competitor pricing
+ Identify underpriced or overpriced market segments
+ Determine the optimal pricing point for future tenders to maximize profit while maintaining competitiveness

This solution enables data-driven bidding strategies, helping companies make informed decisions and improve their chances of winning public procurement contracts efficiently.

Code: 
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

