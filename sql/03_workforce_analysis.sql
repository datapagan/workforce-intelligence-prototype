-- Workforce Gap Analysis

SELECT
    hp.business_unit,
    hp.function,
    hp.planning_period,

    hp.required_headcount,
    ea.active_headcount AS available_headcount,

    ap.attrition_rate,
    (ea.active_headcount * ap.attrition_rate) AS projected_attrition,

    -- Hiring Need Calculation
    hp.required_headcount 
        - ea.active_headcount 
        + (ea.active_headcount * ap.attrition_rate) AS hiring_needed

FROM headcount_plan hp

LEFT JOIN employee_actuals ea
    ON hp.business_unit = ea.business_unit
    AND hp.function = ea.function

LEFT JOIN attrition_plan ap
    ON hp.business_unit = ap.business_unit
    AND hp.function = ap.function
    AND hp.planning_period = ap.planning_period;