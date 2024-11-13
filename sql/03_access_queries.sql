-- Query 1: Retrieve all products with their division, category, and region details
SELECT 
    p.product_name,
    p.sku,
    p.price,
    c.category_name,
    d.division_name,
    r.region_name
FROM 
    Products p
JOIN 
    Categories c ON p.category_id = c.category_id
JOIN 
    Divisions d ON p.division_id = d.division_id
JOIN 
    Regions r ON d.region_id = r.region_id;

-- Query 2: Summarize total sales revenue and total units sold by product
SELECT 
    p.product_name,
    SUM(s.units_sold) AS total_units_sold,
    SUM(s.net_sales_after_returns) AS total_sales_revenue
FROM 
    Sales s
JOIN 
    Products p ON s.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    total_sales_revenue DESC;

-- Query 3: Calculate gross profit margin for each product
SELECT 
    p.product_name,
    s.date,
    s.net_sales_after_returns AS net_sales,
    s.gross_profit,
    s.gross_profit_margin
FROM 
    Sales s
JOIN 
    Products p ON s.product_id = p.product_id
ORDER BY 
    s.date, p.product_name;

-- Query 4: View financial statements with formatted JSON assets and liabilities
SELECT 
    fs.statement_id,
    fs.date,
    d.division_name,
    r.region_name,
    jsonb_pretty(fs.assets) AS formatted_assets,
    jsonb_pretty(fs.liabilities) AS formatted_liabilities,
    jsonb_pretty(fs.income_statement) AS formatted_income_statement,
    jsonb_pretty(fs.cash_flow) AS formatted_cash_flow
FROM 
    FinancialStatements fs
JOIN 
    Divisions d ON fs.division_id = d.division_id
JOIN 
    Regions r ON d.region_id = r.region_id
ORDER BY 
    fs.date DESC;

-- Query 5: Retrieve financial metrics for each division with selected key ratios
SELECT 
    fm.date,
    d.division_name,
    fm.current_ratio,
    fm.quick_ratio,
    fm.gross_margin,
    fm.operating_margin,
    fm.net_margin,
    fm.return_on_equity,
    fm.return_on_assets,
    fm.free_cash_flow
FROM 
    FinancialMetrics fm
JOIN 
    Divisions d ON fm.division_id = d.division_id
ORDER BY 
    fm.date DESC;

-- Query 6: Calculate return on assets (ROA) and return on equity (ROE) by division
SELECT 
    d.division_name,
    fm.date,
    fm.return_on_assets,
    fm.return_on_equity
FROM 
    FinancialMetrics fm
JOIN 
    Divisions d ON fm.division_id = d.division_id
ORDER BY 
    fm.date DESC;

-- Query 7: Analyze discount impact on sales revenue and profit erosion
SELECT 
    p.product_name,
    s.date,
    s.units_sold,
    s.gross_sales,
    s.discount,
    s.net_sales AS sales_after_discount,
    s.gross_profit,
    s.profit_erosion
FROM 
    Sales s
JOIN 
    Products p ON s.product_id = p.product_id
ORDER BY 
    s.date, p.product_name;

-- Query 8: List of sales by channel to analyze sales distribution
SELECT 
    s.channel,
    COUNT(s.sales_id) AS total_sales,
    SUM(s.net_sales_after_returns) AS total_revenue
FROM 
    Sales s
GROUP BY 
    s.channel
ORDER BY 
    total_revenue DESC;

-- Query 9: View detailed user and division information
SELECT 
    u.name AS user_name,
    u.email,
    u.location,
    d.division_name,
    r.region_name
FROM 
    Users u
JOIN 
    Divisions d ON u.division_id = d.division_id
JOIN 
    Regions r ON d.region_id = r.region_id;

-- Query 10: Calculate inventory turnover for each division
SELECT 
    fm.date,
    d.division_name,
    fm.inventory_turnover
FROM 
    FinancialMetrics fm
JOIN 
    Divisions d ON fm.division_id = d.division_id
ORDER BY 
    fm.date DESC;

-- Query 11: Calculate debt-to-equity ratio over time for financial health analysis
SELECT 
    fm.date,
    d.division_name,
    fm.debt_to_equity
FROM 
    FinancialMetrics fm
JOIN 
    Divisions d ON fm.division_id = d.division_id
ORDER BY 
    fm.date DESC;

-- Query 12: Generate a report of cash flow statements by division and date
SELECT 
    fs.statement_id,
    fs.date,
    d.division_name,
    jsonb_pretty(fs.cash_flow) AS formatted_cash_flow
FROM 
    FinancialStatements fs
JOIN 
    Divisions d ON fs.division_id = d.division_id
ORDER BY 
    fs.date DESC;

-- Query 13: Show products and their current status (active or inactive)
SELECT 
    p.product_name,
    p.sku,
    p.is_active,
    d.division_name
FROM 
    Products p
JOIN 
    Divisions d ON p.division_id = d.division_id
ORDER BY 
    d.division_name, p.product_name;

-- Query 14: Retrieve financial metrics for liquidity analysis (current and quick ratios)
SELECT 
    fm.date,
    d.division_name,
    fm.current_ratio,
    fm.quick_ratio
FROM 
    FinancialMetrics fm
JOIN 
    Divisions d ON fm.division_id = d.division_id
ORDER BY 
    fm.date DESC;

-- Query 15: Retrieve all data from FinancialMetrics for a specific date range (for example, Q1 2023)
SELECT 
    *
FROM 
    FinancialMetrics
WHERE 
    date BETWEEN '2023-01-01' AND '2023-03-31'
ORDER BY 
    date, division_id;
