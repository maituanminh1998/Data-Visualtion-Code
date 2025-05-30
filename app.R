library(shiny)
library(ggplot2)
library(dplyr)
library(readxl)
library(DT)
library(scales)

# Load raw data
data <- read_excel("data.xlsx", sheet = "Danh sách hàng hóa", skip = 1)

# Rename columns based on their raw order
colnames(data)[c(1:19)] <- c(
  'STT', 'Tên thiết bị', 'Đơn vị tính', 'Khối lượng', 'Xuất xứ',
  'Mã HS', 'Nhãn hiệu', 'Hãng sản xuất', 'Năm sản xuất', 'Cấu hình kỹ thuật',
  'Đơn giá (VND)', 'Mã TBMT', 'Tên CĐT', 'Hình thức LCNT',
  'Ngày đăng tải KQLCNT', 'Số quyết định', 'Ngày ban hành quyết định',
  'Số nhà thầu', 'Địa điểm'
)

# Parse fields
data$`Đơn giá (VND)` <- as.numeric(data$`Đơn giá (VND)`)
data$CapacityKG <- as.numeric(data$`Cấu hình kỹ thuật`)
data$`Ngày đăng tải KQLCNT` <- as.Date(data$`Ngày đăng tải KQLCNT`, format = "%d/%m/%Y")
data$Tỉnh <- sub(".*Tỉnh\\s*", "", as.character(data$`Địa điểm`))
data$Tỉnh[grepl("Thành phố", data$`Địa điểm`)] <- sub(".*Thành phố\\s*", "", data$`Địa điểm`[grepl("Thành phố", data$`Địa điểm`)])

# UI
ui <- fluidPage(
  titlePanel("Washing Machine Tender Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("year", "Select Year:", choices = c("All", unique(format(data$`Ngày đăng tải KQLCNT`, "%Y")))),
      selectInput("region", "Select Province:", choices = c("All", unique(data$Tỉnh))),
      selectInput("brand", "Select Brand:", choices = c("All", unique(data$`Hãng sản xuất`))),
      downloadButton("downloadData", "Download Filtered Data")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Bar Chart", plotOutput("barChart")),
        tabPanel("Box Plot", plotOutput("boxPlot")),
        tabPanel("Pie Chart", plotOutput("pieChart")),
        tabPanel("Line Chart", plotOutput("lineChart")),
        tabPanel("Scatter Plot", plotOutput("scatterPlot")),
        tabPanel("Filtered Table", DTOutput("dataTable"))
      )
    )
  )
)

# Server
server <- function(input, output) {
  filteredData <- reactive({
    df <- data
    if (input$year != "All") {
      df <- df[format(df$`Ngày đăng tải KQLCNT`, "%Y") == input$year, ]
    }
    if (input$region != "All") {
      df <- df[df$Tỉnh == input$region, ]
    }
    if (input$brand != "All") {
      df <- df[df$`Hãng sản xuất` == input$brand, ]
    }
    df
  })
  
  safePlot <- function(df, required_cols, plotFunc) {
    if (nrow(df) == 0 || any(sapply(required_cols, function(col) all(is.na(df[[col]]))))) {
      plot.new()
      title(paste("Not enough valid", paste(required_cols, collapse = " and "), "data to plot."))
    } else {
      plotFunc(df)
    }
  }
  
  output$barChart <- renderPlot({
    df <- filteredData() %>% filter(!is.na(`Đơn giá (VND)`), `Đơn giá (VND)` > 0)
    safePlot(df, c("Tỉnh", "Đơn giá (VND)"), function(df) {
      summary_df <- df %>% group_by(Tỉnh) %>% summarise(AveragePrice = mean(`Đơn giá (VND)`))
      ggplot(summary_df, aes(x = reorder(Tỉnh, AveragePrice), y = AveragePrice)) +
        geom_bar(stat = "identity") + coord_flip() +
        labs(title = "Average Winning Price by Province", x = "Province", y = "Average Price (VND)") +
        scale_y_continuous(labels = label_comma(suffix = " VND"))
    })
  })
  
  output$boxPlot <- renderPlot({
    df <- filteredData() %>% filter(!is.na(`Đơn giá (VND)`))
    safePlot(df, c("Tỉnh", "Đơn giá (VND)"), function(df) {
      ggplot(df, aes(x = Tỉnh, y = `Đơn giá (VND)`)) +
        geom_boxplot() + coord_flip() +
        labs(title = "Price Range by Province", x = "Province", y = "Price (VND)") +
        scale_y_continuous(labels = label_comma(suffix = " VND"))
    })
  })
  
  output$pieChart <- renderPlot({
    df <- filteredData() %>%
      group_by(`Hãng sản xuất`) %>%
      summarise(Count = n()) %>%
      filter(!is.na(`Hãng sản xuất`))
    safePlot(df, c("Hãng sản xuất", "Count"), function(df) {
      ggplot(df, aes(x = "", y = Count, fill = `Hãng sản xuất`)) +
        geom_bar(stat = "identity", width = 1) +
        coord_polar("y") +
        labs(title = "Market Share by Brand")
    })
  })
  
  output$lineChart <- renderPlot({
    df <- filteredData() %>%
      mutate(Month = format(`Ngày đăng tải KQLCNT`, "%Y-%m")) %>%
      group_by(Month) %>%
      summarise(Count = n()) %>%
      filter(!is.na(Month))
    
    safePlot(df, c("Month", "Count"), function(df) {
      ggplot(df, aes(x = Month, y = Count, group = 1)) +
        geom_line() + geom_point() +
        labs(title = "Tenders Over Time", x = "Month", y = "Count") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    })
  })
  
  output$scatterPlot <- renderPlot({
    df <- filteredData() %>%
      filter(!is.na(CapacityKG), !is.na(`Đơn giá (VND)`))
    
    safePlot(df, c("CapacityKG", "Đơn giá (VND)"), function(df) {
      ggplot(df, aes(x = CapacityKG, y = `Đơn giá (VND)`, color = `Hãng sản xuất`)) +
        geom_point(size = 3, alpha = 0.7) +
        geom_smooth(method = "lm", se = TRUE, color = "black", linetype = "dashed") +
        labs(
          title = "Price vs Capacity (with Trend Line)",
          x = "Capacity (kg)",
          y = "Price (VND)"
        ) +
        scale_y_continuous(labels = label_comma(suffix = " VND"))
    })
  })
  
  
  output$dataTable <- renderDT({
    datatable(filteredData())
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("filtered_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(filteredData(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui = ui, server = server)

