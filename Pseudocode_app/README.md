# Employee Activity Tracker - Shiny Application

A comprehensive employee activity tracking system built in R Shiny, developed from pseudocode specifications. This application provides daily activity logging, analytics dashboard, and CSV export functionality.

## 📁 Project Structure

```
Pseudocode_app/
├── app.R              # Main Shiny application
├── run_app.R          # Launch script with dependency management
├── pseudocode.txt     # Original specifications
└── README.md          # This documentation
```

## 🚀 Quick Start

### Option 1: Using the launch script (Recommended)
```r
source("run_app.R")
```

### Option 2: Direct execution
```r
shiny::runApp("app.R", launch.browser = TRUE)
```

### Option 3: Manual setup
```r
# Install required packages
install.packages(c("shiny", "shinyjs", "DT", "dplyr", "plotly", "readr", "lubridate"))

# Run the app
shiny::runApp("app.R")
```

## 📱 Features

### 1. **Daily Activity Logging**
- Employee selection from predefined list
- Date picker (defaults to current date)
- Activity types:
  - **Project Work**: Requires project selection and hours input
  - **Sick Leave**: Simple logging
  - **Vacation**: Simple logging
- Optional notes field
- Form validation and user feedback

### 2. **Data Management**
- Interactive data table showing all entries
- Date range filtering
- Row selection and deletion
- Real-time data updates
- Sortable columns

### 3. **Analytics Dashboard**
- **Key Performance Indicators (KPIs)**:
  - Total hours worked
  - Sick days taken
  - Vacation days used
  - Number of active projects
- **Interactive Charts**:
  - Hours by project (bar chart)
  - Activity distribution (pie chart)
- Employee-specific filtering

### 4. **CSV Export**
- Generate summary reports in standardized format
- Aggregates daily logs into project-based summaries
- Compatible with external analysis tools
- Downloadable with proper file naming

## 📊 Data Structure

### Employee Profiles
```r
EmployeeID: "EMP1001", "EMP1002", etc.
EmployeeName: "John Smith", "Sarah Johnson", etc.
Department: "Finance", "Marketing", "Sales", "Engineering", "HR"
Vacation/Sick Allowances: Configurable limits
```

### Activity Records
```r
RecordID: Unique identifier
EmployeeID: Links to employee profile
Date: Activity date
Activity: "Project Work", "Sick Leave", "Vacation"
Project: Project name (for work activities)
Hours: Hours worked (for work activities)
Notes: Optional additional information
```

### CSV Export Format
Matches standard employee work history format:
```
employee_id, employee_name, project_name, start_date, end_date,
hours_worked, sick_days, vacation_days, department
```

## 🔧 Technical Details

### Dependencies
- `shiny`: Core framework
- `shinyjs`: UI enhancements
- `DT`: Interactive tables
- `dplyr`: Data manipulation
- `plotly`: Interactive charts
- `readr`: File operations
- `lubridate`: Date handling

### Architecture
- **UI**: Sidebar layout with tabbed main panel
- **Server**: Reactive programming with event handlers
- **Data**: In-memory storage with reactive values
- **Validation**: Comprehensive input validation and error handling

## 🛠️ Customization

### Adding New Employees
Modify the `employee_profiles` data frame:
```r
employee_profiles <- rbind(employee_profiles, 
  data.frame(
    EmployeeID = "EMP1006",
    EmployeeName = "New Employee",
    Department = "Department Name",
    YearlyVacationAllowance = 25,
    YearlySickDayAllowance = 10
  )
)
```

### Adding New Projects
Update the `available_projects` vector:
```r
available_projects <- c(available_projects, "New Project Name")
```

## ✅ Fixes and Improvements Applied

### Variable Binding Issues
- Added proper `.data$` notation for all dplyr operations
- Fixed column references in data manipulation functions
- Resolved R CMD check warnings

### Error Handling
- Added `tryCatch()` blocks around critical functions
- Improved profile validation with fallback mechanisms
- Better user feedback with specific error messages

### Notification System
- Fixed `showNotification()` type parameters
- Valid types: `"default"`, `"message"`, `"warning"`, `"error"`
- Replaced invalid `"success"` type with `"message"`

### Data Safety
- Protected against NULL values and empty data frames
- Added validation for form inputs
- Ensured single value extraction from data frames

## 🐛 Troubleshooting

### Common Issues

**App won't start**
- Check that all required packages are installed
- Verify R version compatibility (R ≥ 3.6.0 recommended)

**Port conflicts**
- Change port in `run_app.R`: `shiny::runApp("app.R", port = 3841)`

**Form submission errors**
- Ensure employee and project selections are valid
- Check date format compatibility

**Empty charts**
- Verify data entries exist for selected employee and date range
- Check activity types match expected values

### Error Messages
- **"No data found"**: Adjust date range or employee selection
- **"Please select rows"**: Select table rows before attempting deletion
- **Package loading errors**: Install missing dependencies

## 🔮 Future Enhancements

1. **Database Integration**: Replace in-memory storage with persistent database
2. **User Authentication**: Multi-user support with login system
3. **Advanced Analytics**: More sophisticated reporting and visualizations
4. **Calendar View**: Visual calendar interface for activity management
5. **Mobile Responsiveness**: Improved mobile device compatibility
6. **Batch Operations**: Bulk data entry and management features
7. **Email Notifications**: Automated reporting and alerts

## 📞 Support

For technical issues or feature requests:
1. Check this README for common solutions
2. Review the original pseudocode specifications
3. Examine the application logs for detailed error information

## 📄 License

This project was developed as an educational exercise based on pseudocode specifications.

---

**Last Updated**: June 2025  
**Version**: 1.0 (Cleaned & Stable)  
**Access URL**: http://localhost:3838 (default) or configured port
