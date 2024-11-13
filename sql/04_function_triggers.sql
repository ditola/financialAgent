-- Function to calculate financial metrics based on data in FinancialStatements
CREATE OR REPLACE FUNCTION calculate_financial_metrics(p_statement_id INT) 
RETURNS JSONB AS $$
DECLARE
    v_metrics JSONB;
BEGIN
    -- Perform calculations with error handling for division by zero
    WITH calculations AS (
        SELECT 
            -- Liquidity Ratios
            COALESCE((fs.assets->'current_assets'->>'total')::numeric / 
                     NULLIF((fs.liabilities->'current_liabilities'->>'total')::numeric, 0), 0) AS current_ratio,
            COALESCE(((fs.assets->'current_assets'->>'cash')::numeric + 
                     (fs.assets->'current_assets'->>'accounts_receivable')::numeric) / 
                     NULLIF((fs.liabilities->'current_liabilities'->>'total')::numeric, 0), 0) AS quick_ratio,
            -- Profitability Ratios
            COALESCE((fs.income_statement->'metrics'->>'gross_margin')::numeric, 0) AS gross_margin,
            COALESCE((fs.income_statement->'metrics'->>'operating_margin')::numeric, 0) AS operating_margin,
            COALESCE((fs.income_statement->'metrics'->>'net_margin')::numeric, 0) AS net_margin,
            -- Efficiency Ratios
            COALESCE((fs.income_statement->'revenue'->>'net_sales')::numeric / 
                     NULLIF((fs.assets->'total_assets')::numeric, 0), 0) AS asset_turnover,
            -- Cash Flow Metrics
            COALESCE((fs.cash_flow->'operating_activities'->>'total')::numeric / 
                     NULLIF((fs.liabilities->'current_liabilities'->>'total')::numeric, 0), 0) AS operating_cash_ratio,
            COALESCE((fs.cash_flow->'operating_activities'->>'total')::numeric - 
                     (fs.cash_flow->'investing_activities'->>'capex')::numeric, 0) AS free_cash_flow
        FROM 
            FinancialStatements fs
        WHERE 
            fs.statement_id = p_statement_id
    )
    SELECT jsonb_build_object(
        'liquidity_ratios', jsonb_build_object(
            'current_ratio', current_ratio,
            'quick_ratio', quick_ratio
        ),
        'profitability_ratios', jsonb_build_object(
            'gross_margin', gross_margin,
            'operating_margin', operating_margin,
            'net_margin', net_margin
        ),
        'efficiency_ratios', jsonb_build_object(
            'asset_turnover', asset_turnover
        ),
        'cash_flow_metrics', jsonb_build_object(
            'operating_cash_ratio', operating_cash_ratio,
            'free_cash_flow', free_cash_flow
        )
    ) INTO v_metrics
    FROM calculations;

    RETURN v_metrics;
END;
$$ LANGUAGE plpgsql;


-- Trigger function to generate financial analysis and update key metrics
CREATE OR REPLACE FUNCTION generate_financial_narrative() 
RETURNS TRIGGER AS $$
DECLARE
    v_metrics JSONB;
BEGIN
    -- Calculate and store financial metrics in the JSONB key_metrics field
    v_metrics := calculate_financial_metrics(NEW.statement_id);
    NEW.key_metrics := v_metrics;
    
    -- Placeholder for narrative analysis generation (can be integrated with LLM or AI API)
    NEW.narrative_analysis := 'Generated financial narrative based on statement metrics...';

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Trigger to automatically calculate and store financial metrics upon inserting or updating FinancialStatements
CREATE TRIGGER calculate_and_store_metrics
    BEFORE INSERT OR UPDATE ON FinancialStatements
    FOR EACH ROW
    EXECUTE FUNCTION generate_financial_narrative();


-- Function to update FinancialMetrics table based on calculated metrics
CREATE OR REPLACE FUNCTION update_financial_metrics(p_statement_id INT) 
RETURNS VOID AS $$
DECLARE
    v_division_id INT;
    v_date DATE;
    v_metrics JSONB;
BEGIN
    -- Retrieve the division_id and date for consistency in FinancialMetrics
    SELECT 
        division_id, date 
    INTO 
        v_division_id, v_date
    FROM 
        FinancialStatements 
    WHERE 
        statement_id = p_statement_id;

    -- Calculate metrics and extract values
    v_metrics := calculate_financial_metrics(p_statement_id);

    -- Insert or update metrics in FinancialMetrics table
    INSERT INTO FinancialMetrics (statement_id, date, division_id, 
                                  current_ratio, quick_ratio, gross_margin, 
                                  operating_margin, net_margin, asset_turnover, 
                                  operating_cash_ratio, free_cash_flow)
    VALUES (
        p_statement_id, 
        v_date, 
        v_division_id,
        (v_metrics->'liquidity_ratios'->>'current_ratio')::numeric,
        (v_metrics->'liquidity_ratios'->>'quick_ratio')::numeric,
        (v_metrics->'profitability_ratios'->>'gross_margin')::numeric,
        (v_metrics->'profitability_ratios'->>'operating_margin')::numeric,
        (v_metrics->'profitability_ratios'->>'net_margin')::numeric,
        (v_metrics->'efficiency_ratios'->>'asset_turnover')::numeric,
        (v_metrics->'cash_flow_metrics'->>'operating_cash_ratio')::numeric,
        (v_metrics->'cash_flow_metrics'->>'free_cash_flow')::numeric
    )
    ON CONFLICT (statement_id) 
    DO UPDATE SET
        current_ratio = EXCLUDED.current_ratio,
        quick_ratio = EXCLUDED.quick_ratio,
        gross_margin = EXCLUDED.gross_margin,
        operating_margin = EXCLUDED.operating_margin,
        net_margin = EXCLUDED.net_margin,
        asset_turnover = EXCLUDED.asset_turnover,
        operating_cash_ratio = EXCLUDED.operating_cash_ratio,
        free_cash_flow = EXCLUDED.free_cash_flow,
        updated_at = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;


-- Trigger to update FinancialMetrics table upon insert or update in FinancialStatements
CREATE TRIGGER update_metrics_on_statement_change
    AFTER INSERT OR UPDATE ON FinancialStatements
    FOR EACH ROW
    EXECUTE FUNCTION update_financial_metrics(NEW.statement_id);
