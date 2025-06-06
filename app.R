library(shiny)
library(plotly)
library(readr)
library(dplyr)
library(tidyr)
library(lubridate)

# Load employee data
employee_data <- read_csv("employee_work_history.csv")

# Process dates and add month information
employee_data <- employee_data %>%
    mutate(
        start_date = as.Date(start_date),
        end_date = as.Date(end_date)
    )

# Define UI
ui <- fluidPage(
    titlePanel("Employee Work History Dashboard"), # nolint
     # nolint
    sidebarLayout( # nolint
        sidebarPanel( # nolint
            selectInput("metric", # nolint
                        "Select Metric for Project Heatmap:",
                        choices = list(
                            "Hours Worked" = "hours_worked",
                            "Sick Days" = "sick_days",
                            "Vacation Days" = "vacation_days"
                        ),
                        selected = "hours_worked"),
            br(),
            selectInput("aggregation",
                        "Aggregation Method:",
                        choices = list(
                            "Sum" = "sum",
                            "Average" = "mean",
                            "Maximum" = "max"
                        ),
                        selected = "sum"),
            br(),
            helpText("The first heatmap shows employee work metrics across different projects."),
            br(),
            helpText("The second heatmap shows total hours worked by employees across months.")
        ),
        
        mainPanel(
            h3("Employee vs Projects Heatmap"),
            plotlyOutput("heatmap"),
            br(),
            h3("Employee vs Months Heatmap"),
            plotlyOutput("monthly_heatmap")
        )
    )
)

# Define server logic
server <- function(input, output) {
    output$heatmap <- renderPlotly({
        # Prepare data based on selected metric and aggregation
        heatmap_data <- employee_data %>%
            group_by(.data$employee_name, .data$project_name) %>%
            summarise(
                value = case_when(
                    input$aggregation == "sum" ~ sum(.data[[input$metric]], na.rm = TRUE),
                    input$aggregation == "mean" ~ mean(.data[[input$metric]], na.rm = TRUE),
                    input$aggregation == "max" ~ max(.data[[input$metric]], na.rm = TRUE)
                ),
                .groups = "drop"
            ) %>%
            pivot_wider(
                names_from = .data$project_name,
                values_from = .data$value,
                values_fill = 0
            )
        
        # Convert to matrix for heatmap
        employee_names <- heatmap_data$employee_name
        heatmap_matrix <- as.matrix(heatmap_data[, -1])
        rownames(heatmap_matrix) <- employee_names
        
        # Create metric label for title
        metric_label <- case_when(
            input$metric == "hours_worked" ~ "Hours Worked",
            input$metric == "sick_days" ~ "Sick Days",
            input$metric == "vacation_days" ~ "Vacation Days"
        )
        
        agg_label <- case_when(
            input$aggregation == "sum" ~ "Total",
            input$aggregation == "mean" ~ "Average",
            input$aggregation == "max" ~ "Maximum"
        )
        
        # Create heatmap
        plot_ly(
            z = heatmap_matrix,
            x = colnames(heatmap_matrix),
            y = employee_names,
            type = "heatmap",
            colorscale = "Viridis",
            hovertemplate = paste(
                "<b>Employee:</b> %{y}<br>",
                "<b>Project:</b> %{x}<br>",
                "<b>", metric_label, ":</b> %{z}<br>",
                "<extra></extra>"
            )
        ) %>%
            layout(
                title = paste(agg_label, metric_label, "by Employee and Project"),
                xaxis = list(
                    title = "Projects",
                    tickangle = -45
                ),
                yaxis = list(title = "Employees"),
                margin = list(b = 150, l = 150)
            ) # nolint
    })
    
    # Second heatmap: Employees vs Months
    output$monthly_heatmap <- renderPlotly({
        # Generate monthly data by extracting start month from each project
        monthly_data <- employee_data %>%
            mutate(
                start_month = format(.data$start_date, "%Y-%m"),
                end_month = format(.data$end_date, "%Y-%m")
            ) %>%
            # For simplicity, assign all hours to the start month of each project
            select(.data$employee_name, .data$start_month, .data$hours_worked) %>%
            rename(month = .data$start_month)
        
        # Aggregate by employee and month
        monthly_summary <- monthly_data %>%
            group_by(.data$employee_name, .data$month) %>%
            summarise(total_hours = sum(.data$hours_worked, na.rm = TRUE), .groups = "drop") %>%
            pivot_wider(
                names_from = .data$month,
                values_from = .data$total_hours,
                values_fill = 0
            )
        
        # Convert to matrix for heatmap
        employee_names <- monthly_summary$employee_name
        monthly_matrix <- as.matrix(monthly_summary[, -1])
        rownames(monthly_matrix) <- employee_names
        
        # Sort columns (months) chronologically
        month_cols <- colnames(monthly_matrix)
        month_cols <- sort(month_cols)
        monthly_matrix <- monthly_matrix[, month_cols, drop = FALSE]
        
        # Create heatmap
        plot_ly(
            z = monthly_matrix,
            x = colnames(monthly_matrix),
            y = employee_names,
            type = "heatmap",
            colorscale = "Blues",
            hovertemplate = paste(
                "<b>Employee:</b> %{y}<br>",
                "<b>Month:</b> %{x}<br>",
                "<b>Hours Worked:</b> %{z:.0f}<br>",
                "<extra></extra>"
            )
        ) %>%
            layout(
                title = "Total Hours Worked by Employee and Month",
                xaxis = list(
                    title = "Months (Project Start Dates)",
                    tickangle = -45
                ),
                yaxis = list(title = "Employees"),
                margin = list(b = 100, l = 150)
            )
    })
}

# Run the application
shinyApp(ui = ui, server = server)