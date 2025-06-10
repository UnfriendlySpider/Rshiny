# Employee Activity Tracker - Fixed Version
library(shiny)
library(shinyjs)
library(DT)
library(dplyr)
library(plotly)
library(readr)
library(lubridate)

# =============================================================================
# Configuration & Data Setup
# =============================================================================

# Employee profiles
employee_profiles <- data.frame(
  EmployeeID = c("EMP1001", "EMP1002", "EMP1003", "EMP1004", "EMP1005"),
  EmployeeName = c("John Smith", "Sarah Johnson", "Mike Davis", "Lisa Wilson", "David Brown"),
  Department = c("Finance", "Marketing", "Sales", "Engineering", "HR"),
  YearlyVacationAllowance = c(25, 25, 20, 30, 25),
  YearlySickDayAllowance = c(10, 10, 10, 12, 10),
  stringsAsFactors = FALSE
)

# Available projects
available_projects <- c(
  "Cloud Infrastructure", "Security Audit", "API Integration", 
  "E-commerce Platform", "Website Redesign", "Database Migration",
  "Mobile App Development", "AI Chatbot", "CRM System", "Data Analytics Dashboard"
)

# Initialize activity records
activity_records <- data.frame(
  RecordID = character(0),
  EmployeeID = character(0),
  Date = as.Date(character(0)),
  Activity = character(0),
  Project = character(0),
  Hours = numeric(0),
  Notes = character(0),
  stringsAsFactors = FALSE
)

# Helper functions
get_employees <- function() {
  return(employee_profiles$EmployeeName)
}

get_projects <- function() {
  return(available_projects)
}

get_employee_profile <- function(employee_name) {
  profile <- employee_profiles[employee_profiles$EmployeeName == employee_name, ]
  if (nrow(profile) == 0) {
    profile <- employee_profiles[1, ]  # Fallback to first employee
  }
  return(profile)
}

generate_record_id <- function() {
  return(paste0("REC", format(Sys.time(), "%Y%m%d%H%M%S"), sample(100:999, 1)))
}

# =============================================================================
# User Interface
# =============================================================================

ui <- fluidPage(
  useShinyjs(),
  titlePanel("Employee Activity Tracker"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Log New Activity"),
      
      selectInput("employee_selector", 
                  "Select Employee:",
                  choices = get_employees(),
                  selected = get_employees()[1]),
      
      dateInput("date_selector",
                "Date:",
                value = Sys.Date()),
      
      selectInput("activity_selector",
                  "Activity Type:",
                  choices = c("Project Work", "Sick Leave", "Vacation"),
                  selected = "Project Work"),
      
      conditionalPanel(
        condition = "input.activity_selector == 'Project Work'",
        selectInput("project_selector",
                    "Project:",
                    choices = get_projects()),
        
        numericInput("hours_input",
                     "Hours Worked:",
                     value = 8,
                     min = 0,
                     max = 24,
                     step = 0.5)
      ),
      
      textAreaInput("notes_input",
                    "Notes (Optional):",
                    value = "",
                    rows = 3),
      
      br(),
      actionButton("submit_button", "Submit Entry", 
                   class = "btn-primary btn-block"),
      
      br(),
      hr(),
      
      h4("Filter Options"),
      dateRangeInput("date_range_selector",
                     "Date Range:",
                     start = Sys.Date() - 30,
                     end = Sys.Date())
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Data Log", 
          h3("All Submitted Daily Entries"),
          br(),
          DT::dataTableOutput("activity_table"),
          br(),
          actionButton("delete_selected", "Delete Selected", 
                       class = "btn-danger")
        ),
        
        tabPanel("Dashboard", 
          h3("Analytics Dashboard"),
          br(),
          
          fluidRow(
            column(6,
              actionButton("export_summary_button", 
                           "Generate Summary Report (CSV)",
                           class = "btn-success btn-lg")
            ),
            column(6,
              downloadButton("download_summary", 
                            "Download CSV",
                            class = "btn-info",
                            style = "display: none;")
            )
          ),
          
          br(),
          hr(),
          
          # KPI Cards
          fluidRow(
            column(3,
              div(class = "well",
                h4("Total Hours"),
                textOutput("total_hours_kpi")
              )
            ),
            column(3,
              div(class = "well",
                h4("Sick Days"),
                textOutput("sick_days_kpi")
              )
            ),
            column(3,
              div(class = "well",
                h4("Vacation Days"),
                textOutput("vacation_days_kpi")
              )
            ),
            column(3,
              div(class = "well",
                h4("Active Projects"),
                textOutput("active_projects_kpi")
              )
            )
          ),
          
          br(),
          
          # Charts
          fluidRow(
            column(6,
              h4("Hours by Project"),
              plotlyOutput("hours_by_project_chart")
            ),
            column(6,
              h4("Activity Distribution"),
              plotlyOutput("activity_distribution_chart")
            )
          )
        ),
        
        tabPanel("Calendar View", 
          h3("Calendar View"),
          p("Calendar view functionality to be implemented")
        )
      )
    )
  )
)

# =============================================================================
# Server Logic
# =============================================================================

server <- function(input, output, session) {
  
  # Reactive values
  values <- reactiveValues(
    activity_data = activity_records,
    summary_data = NULL
  )
  
  # Submit handler
  observeEvent(input$submit_button, {
    tryCatch({
      employee_name <- input$employee_selector
      profile <- get_employee_profile(employee_name)
      
      new_record <- data.frame(
        RecordID = generate_record_id(),
        EmployeeID = profile$EmployeeID[1],
        Date = input$date_selector,
        Activity = input$activity_selector,
        Project = ifelse(input$activity_selector == "Project Work" && !is.null(input$project_selector), 
                        input$project_selector, ""),
        Hours = ifelse(input$activity_selector == "Project Work" && !is.null(input$hours_input), 
                      input$hours_input, 0),
        Notes = ifelse(is.null(input$notes_input), "", input$notes_input),
        stringsAsFactors = FALSE
      )
      
      values$activity_data <- rbind(values$activity_data, new_record)
      
      # Reset form
      updateTextAreaInput(session, "notes_input", value = "")
      if (input$activity_selector == "Project Work") {
        updateNumericInput(session, "hours_input", value = 8)
      }
      
      showNotification("Activity logged successfully!", type = "message")
      
    }, error = function(e) {
      showNotification(paste("Error submitting entry:", e$message), type = "error")
    })
  })
  
  # Delete handler
  observeEvent(input$delete_selected, {
    selected_rows <- input$activity_table_rows_selected
    if (length(selected_rows) > 0) {
      current_data <- filtered_activity_data()
      if (nrow(current_data) > 0) {
        record_ids <- current_data$RecordID[selected_rows]
        values$activity_data <- values$activity_data[
          !values$activity_data$RecordID %in% record_ids, ]
        showNotification("Selected records deleted!", type = "warning")
      }
    } else {
      showNotification("Please select rows to delete!", type = "warning")
    }
  })
  
  # Export handler
  observeEvent(input$export_summary_button, {
    tryCatch({
      employee_name <- input$employee_selector
      profile <- get_employee_profile(employee_name)
      date_range <- input$date_range_selector
      
      filtered_logs <- values$activity_data %>%
        filter(.data$EmployeeID == profile$EmployeeID[1],
               .data$Date >= date_range[1],
               .data$Date <= date_range[2])
      
      if (nrow(filtered_logs) == 0) {
        showNotification("No data found for selected criteria!", type = "error")
        return()
      }
      
      # Group by project
      project_groups <- filtered_logs %>%
        filter(.data$Activity == "Project Work") %>%
        group_by(.data$Project) %>%
        summarise(
          start_date = min(.data$Date),
          end_date = max(.data$Date),
          hours_worked = sum(.data$Hours),
          .groups = "drop"
        )
      
      # Count sick and vacation days
      sick_days <- sum(filtered_logs$Activity == "Sick Leave")
      vacation_days <- sum(filtered_logs$Activity == "Vacation")
      
      if (nrow(project_groups) > 0) {
        summary_data <- project_groups %>%
          mutate(
            employee_id = profile$EmployeeID[1],
            employee_name = profile$EmployeeName[1],
            project_name = .data$Project,
            sick_days = sick_days,
            vacation_days = vacation_days,
            department = profile$Department[1]
          ) %>%
          select("employee_id", "employee_name", "project_name", "start_date", 
                 "end_date", "hours_worked", "sick_days", "vacation_days", "department")
      } else {
        summary_data <- data.frame(
          employee_id = profile$EmployeeID[1],
          employee_name = profile$EmployeeName[1],
          project_name = "No Project Work",
          start_date = date_range[1],
          end_date = date_range[2],
          hours_worked = 0,
          sick_days = sick_days,
          vacation_days = vacation_days,
          department = profile$Department[1]
        )
      }
      
      values$summary_data <- summary_data
      shinyjs::show("download_summary")
      showNotification("Summary report generated! Click Download CSV button.", type = "message")
      
    }, error = function(e) {
      showNotification(paste("Error generating summary:", e$message), type = "error")
    })
  })
  
  # Reactive data filtering
  filtered_activity_data <- reactive({
    date_range <- input$date_range_selector
    
    values$activity_data %>%
      filter(.data$Date >= date_range[1], .data$Date <= date_range[2]) %>%
      left_join(employee_profiles, by = "EmployeeID") %>%
      select("RecordID", "EmployeeName", "Date", "Activity", "Project", "Hours", "Notes") %>%
      arrange(desc(.data$Date))
  })
  
  employee_filtered_data <- reactive({
    employee_name <- input$employee_selector
    profile <- get_employee_profile(employee_name)
    date_range <- input$date_range_selector
    
    values$activity_data %>%
      filter(.data$EmployeeID == profile$EmployeeID[1],
             .data$Date >= date_range[1],
             .data$Date <= date_range[2])
  })
  
  # Render outputs
  output$activity_table <- DT::renderDataTable({
    filtered_activity_data()
  }, options = list(pageLength = 10, scrollX = TRUE), selection = 'multiple')
  
  output$total_hours_kpi <- renderText({
    data <- employee_filtered_data()
    total <- sum(data$Hours[data$Activity == "Project Work"], na.rm = TRUE)
    paste(total, "hours")
  })
  
  output$sick_days_kpi <- renderText({
    data <- employee_filtered_data()
    total <- sum(data$Activity == "Sick Leave")
    paste(total, "days")
  })
  
  output$vacation_days_kpi <- renderText({
    data <- employee_filtered_data()
    total <- sum(data$Activity == "Vacation")
    paste(total, "days")
  })
  
  output$active_projects_kpi <- renderText({
    data <- employee_filtered_data()
    projects <- unique(data$Project[data$Activity == "Project Work" & data$Project != ""])
    paste(length(projects), "projects")
  })
  
  output$hours_by_project_chart <- renderPlotly({
    data <- employee_filtered_data() %>%
      filter(.data$Activity == "Project Work", .data$Project != "") %>%
      group_by(.data$Project) %>%
      summarise(TotalHours = sum(.data$Hours), .groups = "drop")
    
    if (nrow(data) == 0) {
      return(plotly_empty())
    }
    
    plot_ly(data, x = ~Project, y = ~TotalHours, type = "bar") %>%
      layout(title = "Hours by Project",
             xaxis = list(title = "Project"),
             yaxis = list(title = "Hours"))
  })
  
  output$activity_distribution_chart <- renderPlotly({
    data <- employee_filtered_data() %>%
      count(.data$Activity) %>%
      mutate(Percentage = .data$n / sum(.data$n) * 100)
    
    if (nrow(data) == 0) {
      return(plotly_empty())
    }
    
    plot_ly(data, labels = ~Activity, values = ~n, type = "pie") %>%
      layout(title = "Activity Distribution")
  })
  
  # Download handler
  output$download_summary <- downloadHandler(
    filename = function() {
      employee_name <- gsub(" ", "_", input$employee_selector)
      paste0("Summary_Report_", employee_name, "_", Sys.Date(), ".csv")
    },
    content = function(file) {
      if (!is.null(values$summary_data)) {
        write_csv(values$summary_data, file)
      }
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
