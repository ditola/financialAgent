-- Populate the Regions table
INSERT INTO Regions (region_name) 
VALUES ('North America'), ('Europe'), ('Asia'), ('South America')
ON CONFLICT DO NOTHING;

-- Populate the Divisions table
INSERT INTO Divisions (division_name, region_id) 
VALUES ('Dairy', 1), ('Produce', 2), ('Bakery', 3), ('Frozen Foods', 4)
ON CONFLICT (division_name) DO NOTHING;

-- Populate the Categories table
INSERT INTO Categories (category_name) 
VALUES ('Milk Products'), ('Fruits'), ('Breads'), ('Vegetables'), ('Meats')
ON CONFLICT DO NOTHING;

-- Populate the Products table
INSERT INTO Products (division_id, category_id, product_name, sku, price, is_active) 
VALUES 
    (1, 1, 'Whole Milk', 'MILK-WHOLE-1L', 1.50, TRUE),
    (1, 1, 'Skim Milk', 'MILK-SKIM-1L', 1.40, TRUE),
    (2, 2, 'Apples', 'APPLE-1KG', 2.00, TRUE),
    (3, 3, 'Whole Wheat Bread', 'BREAD-WW-500G', 1.20, TRUE),
    (4, 4, 'Frozen Peas', 'PEAS-FROZEN-1KG', 1.80, TRUE)
ON CONFLICT (sku) DO NOTHING;

-- Populate the FinancialStatements table
INSERT INTO FinancialStatements (division_id, date, type, assets, liabilities, income_statement, cash_flow, narrative_analysis) 
VALUES (1, '2023-01-01', 'Balance Sheet', 
    '{"current_assets":{"cash":100000,"accounts_receivable":50000,"inventory":75000,"prepaid_expenses":25000,"total":250000},"non_current_assets":{"property_plant_equipment":500000,"intangible_assets":100000,"investments":150000,"total":750000},"total_assets":1000000}'::jsonb,
    '{"current_liabilities":{"accounts_payable":40000,"short_term_debt":60000,"accrued_expenses":25000,"total":125000},"non_current_liabilities":{"long_term_debt":300000,"deferred_tax":75000,"total":375000},"total_liabilities":500000}'::jsonb,
    '{"revenue":{"gross_sales":800000,"returns":20000,"discounts":30000,"net_sales":750000},"expenses":{"cogs":450000,"operating_expenses":150000,"depreciation":50000,"interest":25000,"taxes":25000,"total":700000},"metrics":{"gross_margin":0.40,"operating_margin":0.20,"net_margin":0.15,"ebitda":150000,"ebit":100000,"net_income":50000}}'::jsonb,
    '{"operating_activities":{"net_income":50000,"depreciation":50000,"working_capital_changes":25000,"total":125000},"investing_activities":{"capex":-75000,"acquisitions":0,"investments":-25000,"total":-100000},"financing_activities":{"debt_issuance":100000,"debt_repayment":-50000,"dividends":-25000,"total":25000},"net_cash_flow":50000}'::jsonb,
    'Quarterly report analysis for Dairy Division')
ON CONFLICT DO NOTHING;

-- Populate FinancialMetrics with 3 years of monthly data for each division and product
DO $$
DECLARE
    v_start_date DATE := '2021-01-01';  -- Start date for 3 years
    v_end_date DATE := '2023-12-31';    -- End date for 3 years
    v_current_date DATE;
    v_division_id INT;
    v_product_id INT;
BEGIN
    v_current_date := v_start_date;

    WHILE v_current_date <= v_end_date LOOP
        FOR v_division_id IN SELECT division_id FROM Divisions LOOP
            FOR v_product_id IN SELECT product_id FROM Products LOOP
                INSERT INTO FinancialMetrics (
                    statement_id,
                    date,
                    division_id,
                    current_ratio,
                    quick_ratio,
                    gross_margin,
                    operating_margin,
                    net_margin,
                    free_cash_flow,
                    return_on_assets,
                    return_on_equity
                )
                VALUES (
                    DEFAULT,  -- Assuming statement_id is auto-incremented
                    v_current_date,
                    v_division_id,
                    ROUND((RANDOM() * 2 + 1)::numeric, 2),  -- Random current ratio between 1 and 3
                    ROUND((RANDOM() * 1.5 + 0.5)::numeric, 2),  -- Random quick ratio between 0.5 and 2
                    ROUND((RANDOM() * 0.5)::numeric, 4),  -- Random gross margin between 0 and 0.5
                    ROUND((RANDOM() * 0.5)::numeric, 4),  -- Random operating margin between 0 and 0.5
                    ROUND((RANDOM() * 0.5)::numeric, 4),  -- Random net margin between 0 and 0.5
                    ROUND((RANDOM() * 100000)::numeric, 2),  -- Random free cash flow
                    ROUND((RANDOM() * 0.3 + 0.05)::numeric, 4),  -- Random ROA between 5% and 35%
                    ROUND((RANDOM() * 0.4 + 0.1)::numeric, 4)   -- Random ROE between 10% and 50%
                );
            END LOOP;
        END LOOP;

        v_current_date := v_current_date + INTERVAL '1 month';  -- Move to the next month
    END LOOP;
END $$;

-- Populate Users table
INSERT INTO Users (name, email, division_id, location) 
VALUES 
    ('John Doe', 'john.doe@example.com', 1, 'New York'),
    ('Jane Smith', 'jane.smith@example.com', 2, 'London'),
    ('Carlos Diaz', 'carlos.diaz@example.com', 3, 'Tokyo'),
    ('Anna Lee', 'anna.lee@example.com', 4, 'Sao Paulo')
ON CONFLICT (email) DO NOTHING;

-- Populate Sales table
INSERT INTO Sales (product_id, date, channel, units_sold, gross_sales, discount, return_amount, return_units, cost_of_goods_sold, accounts_receivable, accounts_payable, net_weight_tm, transaction_id) 
VALUES 
    (1, '2023-01-10', 'Retail', 500, 750, 50, 0, 0, 400, 100, 50, 0.5, 'TXN-001'),
    (2, '2023-01-15', 'Online', 300, 420, 20, 0, 0, 210, 80, 30, 0.3, 'TXN-002'),
    (3, '2023-01-20', 'Wholesale', 1000, 2000, 100, 50, 10, 1200, 300, 150, 1.0, 'TXN-003'),
    (4, '2023-01-25', 'Retail', 600, 720, 30, 10, 5, 500, 150, 70, 0.6, 'TXN-004'),
    (5, '2023-01-30', 'Retail', 800, 1440, 60, 20, 10, 700, 200, 100, 0.8, 'TXN-005')
ON CONFLICT DO NOTHING;
