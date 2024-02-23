select EnvironmentSatisfaction, count(*) as "qty"
                            from employee_survey 
            group by EnvironmentSatisfaction;
            