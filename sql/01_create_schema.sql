-- Drop tables if they already exist
DROP TABLE IF EXISTS Sales CASCADE;
DROP TABLE IF EXISTS FinancialMetrics CASCADE;
DROP TABLE IF EXISTS FinancialStatements CASCADE;
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Products CASCADE;
DROP TABLE IF EXISTS Categories CASCADE;
DROP TABLE IF EXISTS Divisions CASCADE;
DROP TABLE IF EXISTS Regions CASCADE;
DROP TABLE IF EXISTS Promotions CASCADE;

-- Drop indexes if they already exist
DROP INDEX IF EXISTS idx_financial_metrics_date;
DROP INDEX IF EXISTS idx_financial_metrics_division;
DROP INDEX IF EXISTS idx_financial_metrics_statement;
DROP INDEX IF EXISTS idx_financial_statements_date_type;
DROP INDEX IF EXISTS idx_financial_statements_division_date;

-- Create Regions table to normalize and organize region data
CREATE TABLE Regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Divisions table to manage different business divisions and link to regions
CREATE TABLE Divisions (
    division_id SERIAL PRIMARY KEY,
    division_name VARCHAR(255) NOT NULL UNIQUE,
    region_id INT REFERENCES Regions(region_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Categories table to categorize products for better data organization
CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Products table with inventory
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    division_id INT REFERENCES Divisions(division_id),
    category_id INT REFERENCES Categories(category_id),
    product_name VARCHAR(255) NOT NULL,
    sku VARCHAR(255) UNIQUE NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    inventory INT DEFAULT 0,  -- New column for inventory
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- FinancialStatements table to store financial statements data for each division
CREATE TABLE FinancialStatements (
    statement_id SERIAL PRIMARY KEY,
    division_id INT REFERENCES Divisions(division_id),
    date DATE NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('Income Statement', 'Balance Sheet', 'Cash Flow')),
    assets JSONB NOT NULL DEFAULT '{
        "current_assets": {
            "cash": 0,
            "accounts_receivable": 0,
            "inventory": 0,
            "prepaid_expenses": 0,
            "total": 0
        },
        "non_current_assets": {
            "property_plant_equipment": 0,
            "intangible_assets": 0,
            "investments": 0,
            "total": 0
        },
        "total_assets": 0
    }',
    liabilities JSONB NOT NULL DEFAULT '{
        "current_liabilities": {
            "accounts_payable": 0,
            "short_term_debt": 0,
            "accrued_expenses": 0,
            "total": 0
        },
        "non_current_liabilities": {
            "long_term_debt": 0,
            "deferred_tax": 0,
            "total": 0
        },
        "total_liabilities": 0
    }',
    income_statement JSONB NOT NULL DEFAULT '{
        "revenue": {
            "gross_sales": 0,
            "returns": 0,
            "discounts": 0,
            "net_sales": 0
        },
        "expenses": {
            "cogs": 0,
            "operating_expenses": 0,
            "depreciation": 0,
            "interest": 0,
            "taxes": 0,
            "total": 0
        },
        "metrics": {
            "gross_margin": 0,
            "operating_margin": 0,
            "net_margin": 0,
            "ebitda": 0,
            "ebit": 0,
            "net_income": 0
        }
    }',
    cash_flow JSONB NOT NULL DEFAULT '{
        "operating_activities": {
            "net_income": 0,
            "depreciation": 0,
            "working_capital_changes": 0,
            "total": 0
        },
        "investing_activities": {
            "capex": 0,
            "acquisitions": 0,
            "investments": 0,
            "total": 0
        },
        "financing_activities": {
            "debt_issuance": 0,
            "debt_repayment": 0,
            "dividends": 0,
            "total": 0
        },
        "net_cash_flow": 0
    }',
    narrative_analysis TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create FinancialMetrics table for storing calculated metrics
CREATE TABLE FinancialMetrics (
    metric_id SERIAL PRIMARY KEY,
    statement_id INT REFERENCES FinancialStatements(statement_id),
    date DATE NOT NULL,
    division_id INT REFERENCES Divisions(division_id),
    -- Liquidity Ratios
    current_ratio DECIMAL(10, 4),
    quick_ratio DECIMAL(10, 4),
    cash_ratio DECIMAL(10, 4),
    -- Profitability Ratios
    gross_margin DECIMAL(10, 4),
    operating_margin DECIMAL(10, 4),
    net_margin DECIMAL(10, 4),
    ebitda_margin DECIMAL(10, 4),
    -- Efficiency Ratios
    asset_turnover DECIMAL(10, 4),
    inventory_turnover DECIMAL(10, 4),
    receivables_turnover DECIMAL(10, 4),
    -- Leverage Ratios
    debt_to_equity DECIMAL(10, 4),
    debt_to_assets DECIMAL(10, 4),
    interest_coverage DECIMAL(10, 4),
    -- Cash Flow Metrics
    operating_cash_ratio DECIMAL(10, 4),
    free_cash_flow DECIMAL(15, 2),
    cash_conversion_cycle INT,
    -- Additional Metrics
    working_capital DECIMAL(15, 2),
    return_on_equity DECIMAL(10, 4),
    return_on_assets DECIMAL(10, 4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table to store data about managers or employees for accountability tracking
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    division_id INT REFERENCES Divisions(division_id),
    location VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Promotions table before the Sales table
CREATE TABLE Promotions (
    promo_id SERIAL PRIMARY KEY,
    promo_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    discount_type VARCHAR(50) NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Sales table with accounts receivable and accounts payable
CREATE TABLE Sales (
    sales_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES Products(product_id),
    date DATE NOT NULL,
    channel VARCHAR(50) NOT NULL,
    units_sold INT NOT NULL CHECK (units_sold > 0),
    gross_sales DECIMAL(15, 2) NOT NULL CHECK (gross_sales >= 0),
    discount DECIMAL(15, 2) DEFAULT 0 CHECK (discount >= 0),
    return_amount DECIMAL(15, 2) DEFAULT 0 CHECK (return_amount >= 0),
    return_units INT DEFAULT 0 CHECK (return_units >= 0),
    cost_of_goods_sold DECIMAL(15, 2) DEFAULT 0,
    accounts_receivable DECIMAL(15, 2) DEFAULT 0,
    accounts_payable DECIMAL(15, 2) DEFAULT 0,
    net_sales DECIMAL(15, 2),
    net_sales_after_returns DECIMAL(15, 2),
    gross_profit DECIMAL(15, 2),
    gross_profit_margin DECIMAL(10, 4),
    net_weight_tm DECIMAL(10, 2) NOT NULL CHECK (net_weight_tm > 0),
    price_per_kg DECIMAL(10, 4),
    profit_per_kg DECIMAL(10, 4),
    transaction_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger function to calculate values
CREATE OR REPLACE FUNCTION calculate_sales_metrics()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate net_sales
    NEW.net_sales := NEW.gross_sales - NEW.discount;
    
    -- Calculate net_sales_after_returns
    NEW.net_sales_after_returns := NEW.net_sales - NEW.return_amount;
    
    -- Calculate gross_profit
    NEW.gross_profit := NEW.net_sales - NEW.cost_of_goods_sold;
    
    -- Calculate gross_profit_margin
    NEW.gross_profit_margin := CASE 
        WHEN NEW.net_sales = 0 THEN 0 
        ELSE NEW.gross_profit / NEW.net_sales 
    END;
    
    -- Calculate price_per_kg
    NEW.price_per_kg := CASE 
        WHEN NEW.net_weight_tm = 0 THEN 0 
        ELSE NEW.net_sales_after_returns / (NEW.net_weight_tm * 1000) 
    END;
    
    -- Calculate profit_per_kg
    NEW.profit_per_kg := CASE 
        WHEN NEW.net_weight_tm = 0 THEN 0 
        ELSE NEW.gross_profit / (NEW.net_weight_tm * 1000) 
    END;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trg_calculate_sales_metrics
    BEFORE INSERT OR UPDATE ON Sales
    FOR EACH ROW
    EXECUTE FUNCTION calculate_sales_metrics();

-- Function to calculate and store financial metrics
CREATE OR REPLACE FUNCTION calculate_and_store_financial_metrics(
    p_statement_id INT
) RETURNS VOID AS $$
DECLARE
    v_metrics record;
    v_division_id INT;
    v_date DATE;
BEGIN
    -- Get basic info
    SELECT division_id, date 
    INTO v_division_id, v_date
    FROM FinancialStatements 
    WHERE statement_id = p_statement_id;

    -- Calculate metrics with error handling
    BEGIN
        WITH calculations AS (
            SELECT 
                fs.statement_id,
                -- Liquidity Ratios
                COALESCE((fs.assets->'current_assets'->>'total')::numeric / 
                    NULLIF((fs.liabilities->'current_liabilities'->>'total')::numeric, 0), 0) as current_ratio,
                COALESCE(((fs.assets->'current_assets'->>'cash')::numeric + 
                    (fs.assets->'current_assets'->>'accounts_receivable')::numeric) / 
                    NULLIF((fs.liabilities->'current_liabilities'->>'total')::numeric, 0), 0) as quick_ratio,
                -- Calculate free cash flow
                COALESCE((fs.cash_flow->'operating_activities'->>'total')::numeric - 
                    (fs.cash_flow->'investing_activities'->>'capex')::numeric, 0) as free_cash_flow
            FROM FinancialStatements fs
            WHERE fs.statement_id = p_statement_id
        )
        INSERT INTO FinancialMetrics (
            statement_id,
            date,
            division_id,
            current_ratio,
            quick_ratio,
            free_cash_flow
        )
        SELECT 
            p_statement_id,
            v_date,
            v_division_id,
            current_ratio,
            quick_ratio,
            free_cash_flow
        FROM calculations
        ON CONFLICT (statement_id) 
        DO UPDATE SET
            current_ratio = EXCLUDED.current_ratio,
            quick_ratio = EXCLUDED.quick_ratio,
            free_cash_flow = EXCLUDED.free_cash_flow,
            updated_at = CURRENT_TIMESTAMP;

    EXCEPTION 
        WHEN division_by_zero THEN
            RAISE WARNING 'Division by zero encountered while calculating metrics for statement_id: %', p_statement_id;
        WHEN others THEN
            RAISE WARNING 'Error calculating metrics for statement_id: %: %', p_statement_id, SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- Create enhanced view for financial analysis
CREATE OR REPLACE VIEW financial_analysis_view AS
SELECT 
    fs.statement_id,
    fs.date,
    d.division_name,
    r.region_name,
    fm.current_ratio,
    fm.quick_ratio,
    fm.gross_margin,
    fm.operating_margin,
    fm.net_margin,
    fm.free_cash_flow,
    jsonb_pretty(fs.assets) as formatted_assets,
    jsonb_pretty(fs.liabilities) as formatted_liabilities,
    jsonb_pretty(fs.income_statement) as formatted_income_statement,
    jsonb_pretty(fs.cash_flow) as formatted_cash_flow,
    fs.narrative_analysis
FROM FinancialStatements fs
JOIN Divisions d ON fs.division_id = d.division_id
JOIN Regions r ON d.region_id = r.region_id
LEFT JOIN FinancialMetrics fm ON fs.statement_id = fm.statement_id;

-- Create indexes for optimized performance
CREATE INDEX idx_financial_metrics_date ON FinancialMetrics(date);
CREATE INDEX idx_financial_metrics_division ON FinancialMetrics(division_id);
CREATE UNIQUE INDEX idx_financial_metrics_statement ON FinancialMetrics(statement_id);
CREATE INDEX idx_financial_statements_date_type ON FinancialStatements(date, type);
CREATE INDEX idx_financial_statements_division_date ON FinancialStatements(division_id, date);
CREATE INDEX idx_sales_date_product ON Sales(date, product_id);
CREATE INDEX idx_sales_channel ON Sales(channel);