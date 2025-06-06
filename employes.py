import csv
import random
from datetime import datetime, timedelta

# Generate sample employee work history data
def create_employee_data():
    employees = []
    
    # Sample employee names
    names = ["John Smith", "Sarah Johnson", "Mike Davis", "Lisa Wilson", "David Brown", 
             "Emma Taylor", "James Anderson", "Maria Garcia", "Robert Miller", "Jennifer White"]
    
    # Sample projects
    projects = ["Website Redesign", "Mobile App Development", "Database Migration", 
                "API Integration", "Security Audit", "Data Analytics Dashboard",
                "Cloud Infrastructure", "E-commerce Platform", "CRM System", "AI Chatbot"]
    
    for i, name in enumerate(names):
        employee_id = f"EMP{1001 + i}"
        
        # Generate 3-5 project entries per employee
        for j in range(random.randint(3, 5)):
            start_date = datetime(2023, 1, 1) + timedelta(days=random.randint(0, 300))
            end_date = start_date + timedelta(days=random.randint(30, 120))
            
            employees.append({
                "employee_id": employee_id,
                "employee_name": name,
                "project_name": random.choice(projects),
                "start_date": start_date.strftime("%Y-%m-%d"),
                "end_date": end_date.strftime("%Y-%m-%d"),
                "hours_worked": random.randint(40, 200),
                "sick_days": random.randint(0, 8),
                "vacation_days": random.randint(0, 15),
                "department": random.choice(["Engineering", "Marketing", "Sales", "HR", "Finance"])
            })
    
    return employees

# Create CSV file
def create_csv():
    data = create_employee_data()
    
    with open('employee_work_history.csv', 'w', newline='', encoding='utf-8') as file:
        fieldnames = ["employee_id", "employee_name", "project_name", "start_date", 
                     "end_date", "hours_worked", "sick_days", "vacation_days", "department"]
        
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(data)
    
    print(f"CSV file created with {len(data)} records")
    print("File saved as: employee_work_history.csv")

if __name__ == "__main__":
    create_csv()