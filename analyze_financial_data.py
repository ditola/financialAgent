import os
import psycopg2
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from dotenv import load_dotenv

load_dotenv()

# Database connection details
DB_CONFIG = {
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT")
}

# Establish database connection
def connect_db():
    conn = psycopg2.connect(**DB_CONFIG)
    return conn

# Query and plot total sales revenue, discounts, and gross profit by product
def plot_sales_performance():
    query = """
    SELECT 
        p.product_name,
        SUM(s.units_sold) AS total_units_sold,
        SUM(s.gross_sales) AS total_gross_sales,
        SUM(s.discount) AS total_discounts,
        SUM(s.net_sales_after_returns) AS total_net_sales,
        SUM(s.gross_profit) AS total_gross_profit,
        AVG(s.gross_profit_margin) AS average_gross_profit_margin
    FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
    GROUP BY p.product_name
    ORDER BY total_gross_profit DESC;
    """
    conn = connect_db()
    df = pd.read_sql_query(query, conn)
    conn.close()
    
    # Plot
    plt.figure(figsize=(10, 6))
    sns.barplot(x='total_gross_profit', y='product_name', data=df, palette="viridis")
    plt.title('Total Gross Profit by Product')
    plt.xlabel('Gross Profit')
    plt.ylabel('Product')
    plt.show()

# Query and plot promotion effectiveness
def plot_promotion_effectiveness():
    query = """
    SELECT 
        p.product_name,
        SUM(s.gross_sales) AS total_sales,
        SUM(s.discount) AS total_discount,
        SUM(s.gross_profit) AS total_profit,
        AVG(s.gross_profit_margin) AS average_profit_margin
    FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
    WHERE s.promo_id IS NOT NULL
    GROUP BY p.product_name
    ORDER BY total_profit DESC;
    """
    conn = connect_db()
    df = pd.read_sql_query(query, conn)
    conn.close()
    
    # Plot
    plt.figure(figsize=(10, 6))
    sns.barplot(x='total_profit', y='product_name', hue='product_name', data=df, palette="coolwarm", legend=False)
    plt.title('Total Promotion Profit by Product')
    plt.xlabel('Promotion Profit')
    plt.ylabel('Product')
    plt.show()

# Query and plot financial metrics by division
def plot_financial_metrics():
    query = """
    SELECT 
        d.division_name,
        fm.date,
        fm.gross_margin,
        fm.operating_margin,
        fm.net_margin,
        fm.return_on_assets,
        fm.return_on_equity,
        fm.free_cash_flow
    FROM FinancialMetrics fm
    JOIN Divisions d ON fm.division_id = d.division_id
    ORDER BY fm.date DESC;
    """
    conn = connect_db()
    df = pd.read_sql_query(query, conn)
    conn.close()
    
    # Plot financial metrics over time
    plt.figure(figsize=(12, 8))
    sns.lineplot(data=df, x='date', y='gross_margin', hue='division_name', marker="o")
    plt.title('Gross Margin Over Time by Division')
    plt.xlabel('Date')
    plt.ylabel('Gross Margin')
    plt.legend(title='Division')
    plt.show()

# Query and plot pricing efficiency by product
def plot_pricing_efficiency():
    query = """
    SELECT 
        p.product_name,
        SUM(s.units_sold) AS total_units_sold,
        SUM(s.net_weight_tm) AS total_net_weight_tm,
        AVG(s.price_per_kg) AS average_price_per_kg,
        AVG(s.profit_per_kg) AS average_profit_per_kg
    FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
    GROUP BY p.product_name
    ORDER BY average_profit_per_kg DESC;
    """
    conn = connect_db()
    df = pd.read_sql_query(query, conn)
    conn.close()
    
    # Plot
    plt.figure(figsize=(10, 6))
    sns.scatterplot(x='average_price_per_kg', y='average_profit_per_kg', size='total_units_sold', hue='product_name', data=df, sizes=(50, 500), palette="viridis", legend=False)
    plt.title('Pricing and Profitability Efficiency by Product')
    plt.xlabel('Average Price per Kg')
    plt.ylabel('Average Profit per Kg')
    plt.show()

# Query and plot channel-wise sales performance
def plot_channel_performance():
    query = """
    SELECT 
        s.channel,
        COUNT(s.sales_id) AS total_sales,
        SUM(s.net_sales_after_returns) AS total_revenue,
        AVG(s.gross_profit_margin) AS average_gross_profit_margin
    FROM Sales s
    GROUP BY s.channel
    ORDER BY total_revenue DESC;
    """
    conn = connect_db()
    df = pd.read_sql_query(query, conn)
    conn.close()
    
    # Plot
    plt.figure(figsize=(10, 6))
    sns.barplot(x='total_revenue', y='channel', data=df, palette="magma")
    plt.title('Total Revenue by Channel')
    plt.xlabel('Total Revenue')
    plt.ylabel('Channel')
    plt.show()

# Run all plots
if __name__ == "__main__":
    plot_sales_performance()
    plot_promotion_effectiveness()
    plot_financial_metrics()
    plot_pricing_efficiency()
    plot_channel_performance()
