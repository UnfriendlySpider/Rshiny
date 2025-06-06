library(shiny)
library(plotly)

# Define UI
ui <- fluidPage(
    titlePanel("Simple Heatmap App"),
    
    sidebarLayout(
        sidebarPanel(
            sliderInput("rows",
                                    "Number of rows:",
                                    min = 5,
                                    max = 20,
                                    value = 10),
            
            sliderInput("cols",
                                    "Number of columns:",
                                    min = 5,
                                    max = 20,
                                    value = 10)
        ),
        
        mainPanel(
            plotlyOutput("heatmap")
        )
    )
)

# Define server logic
server <- function(input, output) {
    output$heatmap <- renderPlotly({
        # Generate random data matrix
        data_matrix <- matrix(rnorm(input$rows * input$cols), 
                                                 nrow = input$rows, 
                                                 ncol = input$cols)
        
        # Create heatmap
        plot_ly(
            z = data_matrix,
            type = "heatmap",
            colorscale = "Viridis"
        ) %>%
            layout(
                title = "Interactive Heatmap",
                xaxis = list(title = "Columns"),
                yaxis = list(title = "Rows")
            )
    })
}

# Run the application
shinyApp(ui = ui, server = server)