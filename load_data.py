import sqlite3
import pandas as pd

df= pd.read_csv('data/superstore.csv', encoding='latin-1')

df.columns  = (df.columns.str.strip().str.lower().str.replace(' ','_').str.replace('-','_'))
print(df.columns.tolist())

df['order_date']= pd.to_datetime(df['order_date']).dt.strftime('%Y-%m-%d')
df['order_date']= pd.to_datetime(df['ship_date']).dt.strftime('%Y-%m-%d')

conn = sqlite3.connect('superstore.db')

df.to_sql('orders',conn, if_exists='replace', index=False)
print('Rows loaded', len(df))
conn.close()