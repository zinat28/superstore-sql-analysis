import os
import re
import sqlite3
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

os.makedirs('results', exist_ok=True)
os.makedirs('images', exist_ok=True)
sns.set_theme(style='whitegrid')

conn = sqlite3.connect('superstore.db')
sql = open('queries.sql', encoding='utf-8').read()

# Run every query in queries.sql, print it, and save it as a CSV
results = {}
for block in sql.split(';'):
    block = block.strip()
    if not block:
        continue
    name = re.match(r'--\s*(\w+)', block).group(1)
    df = pd.read_sql_query(block, conn)
    results[name] = df
    df.to_csv(f'results/{name}.csv', index=False)
    print(f'\n=== {name} ===')
    print(df.head(10).to_string(index=False))

def save(name):
    plt.tight_layout()
    plt.savefig(f'images/{name}.png', dpi=150)
    plt.close()

# Chart 1: sales and profit per year
results['yearly_sales'].plot(x='year', y=['sales', 'profit'], kind='bar', figsize=(8, 5))
plt.title('Sales and Profit per Year')
plt.xlabel('Year')
plt.ylabel('Amount ($)')
plt.xticks(rotation=0)
save('yearly_sales')

# Chart 2: profit by sub-category (losses show as bars going left)
plt.figure(figsize=(8, 6))
sns.barplot(data=results['profit_by_subcategory'], x='profit', y='sub_category', color='#1f77b4')
plt.title('Profit by Sub-Category')
plt.xlabel('Profit ($)')
plt.ylabel('')
save('profit_by_subcategory')

# Chart 3: average profit by discount level
plt.figure(figsize=(7, 5))
sns.barplot(data=results['discount_impact'], x='discount_band', y='avg_profit', color='#d62728')
plt.title('Average Profit by Discount Level')
plt.xlabel('Discount band')
plt.ylabel('Average profit per order line ($)')
plt.xticks(rotation=15)
save('discount_impact')

conn.close()