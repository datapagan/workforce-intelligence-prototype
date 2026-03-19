from pathlib import Path
import csv
import random

random.seed(42)

base_dir = Path(__file__).resolve().parents[1]
inbound_dir = base_dir / "data" / "inbound_sftp"
reference_dir = base_dir / "data" / "reference"

inbound_dir.mkdir(parents=True, exist_ok=True)
reference_dir.mkdir(parents=True, exist_ok=True)

months = [
    "2025-07-01",
    "2025-08-01",
    "2025-09-01",
    "2025-10-01",
    "2025-11-01",
    "2025-12-01",
]

business_structure = {
    "Space Systems": ["Satellite Engineering", "Mission Operations"],
    "Aviation Systems": ["Aircraft Systems", "Maintenance & Repair"],
    "Digital Security": ["Cybersecurity", "Software Engineering"],
}

locations = [
    ("Hartford", "CT", "USA", "Northeast"),
    ("Tampa", "FL", "USA", "Southeast"),
    ("Tucson", "AZ", "USA", "West"),
]

job_families = [
    "Systems Engineer",
    "Software Engineer",
    "Program Manager",
]

scenarios = ["Budget", "Forecast"]

org_dimension_rows = [
    ["Space Systems", "Satellite Engineering", "SS100", "Elena Martinez"],
    ["Space Systems", "Mission Operations", "SS200", "David Kim"],
    ["Aviation Systems", "Aircraft Systems", "AS100", "Robert Chen"],
    ["Aviation Systems", "Maintenance & Repair", "AS200", "Michael Torres"],
    ["Digital Security", "Cybersecurity", "DS100", "Anita Patel"],
    ["Digital Security", "Software Engineering", "DS200", "James Walker"],
]

location_dimension_rows = [
    ["Hartford", "CT", "USA", "Northeast"],
    ["Tampa", "FL", "USA", "Southeast"],
    ["Tucson", "AZ", "USA", "West"],
]

base_headcount_ranges = {
    "Space Systems": (1200, 2600),
    "Aviation Systems": (1500, 3200),
    "Digital Security": (700, 1800),
}

def get_headcount(business_unit, department, location, job_family, month_index):
    low, high = base_headcount_ranges[business_unit]
    base = random.randint(low, high)

    # department adjustments
    if department in ["Satellite Engineering", "Aircraft Systems", "Software Engineering"]:
        base = int(base * 1.10)
    elif department in ["Mission Operations", "Maintenance & Repair", "Cybersecurity"]:
        base = int(base * 0.90)

    # job family adjustments
    if job_family == "Program Manager":
        base = int(base * 0.35)
    elif job_family == "Systems Engineer":
        base = int(base * 1.00)
    elif job_family == "Software Engineer":
        base = int(base * 0.85)

    # location adjustments
    if location == "Hartford":
        base = int(base * 1.10)
    elif location == "Tampa":
        base = int(base * 1.00)
    elif location == "Tucson":
        base = int(base * 0.92)

    # slight monthly trend
    base = int(base * (1 + (month_index * 0.01)))

    return max(base, 100)

employee_actuals = []
headcount_plan = []
hiring_plan = []
attrition_plan = []

for month_index, month in enumerate(months):
    for business_unit, departments in business_structure.items():
        for department in departments:
            for location, state, country, region in locations:
                for job_family in job_families:
                    actual_headcount = get_headcount(
                        business_unit, department, location, job_family, month_index
                    )

                    actual_hires = max(1, int(actual_headcount * random.uniform(0.01, 0.04)))
                    actual_attrition = max(0, int(actual_headcount * random.uniform(0.005, 0.025)))

                    for i in range(actual_headcount):
                        employee_actuals.append([
                            f"E{month_index:02d}{i:05d}",   # employee_id
                            month,
                            business_unit,
                            department,
                            location,
                            state,
                            job_family,
                        ])

                    for scenario in scenarios:
                        hc_adjust = random.randint(-120, 120)
                        hire_adjust = random.randint(-10, 10)
                        attr_adjust = random.randint(-6, 6)

                        if scenario == "Budget":
                            planned_headcount = actual_headcount + hc_adjust
                            planned_hires = max(0, actual_hires + hire_adjust)
                            planned_attrition = max(0, actual_attrition + attr_adjust)
                        else:  # Forecast
                            planned_headcount = actual_headcount + int(hc_adjust * 0.6)
                            planned_hires = max(0, actual_hires + int(hire_adjust * 0.6))
                            planned_attrition = max(0, actual_attrition + int(attr_adjust * 0.6))

                        headcount_plan.append([
                            month,
                            business_unit,
                            department,
                            location,
                            state,
                            job_family,
                            scenario,
                            planned_headcount,
                        ])

                        hiring_plan.append([
                            month,
                            business_unit,
                            department,
                            location,
                            state,
                            job_family,
                            scenario,
                            planned_hires,
                        ])

                        attrition_plan.append([
                            month,
                            business_unit,
                            department,
                            location,
                            state,
                            job_family,
                            scenario,
                            planned_attrition,
                        ])

def write_csv(path, headers, rows):
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(rows)

write_csv(
    inbound_dir / "employee_actuals.csv",
    [
    "employee_id",
    "snapshot_date",
    "business_unit",
    "department",
    "location_city",
    "location_state",
    "job_role"
    ],
    employee_actuals,
)

write_csv(
    inbound_dir / "headcount_plan.csv",
    [
        "month", "business_unit", "department", "location", "state",
        "job_family", "scenario_name", "planned_headcount"
    ],
    headcount_plan,
)

write_csv(
    inbound_dir / "hiring_plan.csv",
    [
        "month", "business_unit", "department", "location", "state",
        "job_family", "scenario_name", "planned_hires"
    ],
    hiring_plan,
)

write_csv(
    inbound_dir / "attrition_plan.csv",
    [
        "month", "business_unit", "department", "location", "state",
        "job_family", "scenario_name", "planned_attrition"
    ],
    attrition_plan,
)

write_csv(
    reference_dir / "org_dimension.csv",
    ["business_unit", "department", "cost_center", "manager_name"],
    org_dimension_rows,
)

write_csv(
    reference_dir / "location_dimension.csv",
    ["location", "state", "country", "region"],
    location_dimension_rows,
)

print("Mock data files generated successfully.")
print(f"employee_actuals rows: {len(employee_actuals)}")
print(f"headcount_plan rows: {len(headcount_plan)}")
print(f"hiring_plan rows: {len(hiring_plan)}")
print(f"attrition_plan rows: {len(attrition_plan)}")