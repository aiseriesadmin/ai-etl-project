import pandas as pd
from sklearn.ensemble import IsolationForest
import snowflake.connector

ctx = snowflake.connector.connect(
    user='your_username',
    password='your_password',
    account='your_account',
    warehouse='your_warehouse',
    database='your_database',
    schema='staging'
)

query = "SELECT transaction_id, transaction_amount, product_price, discount_applied FROM staging.transactions"
df = pd.read_sql(query, ctx)

model = IsolationForest(n_estimators=100, contamination=0.01, random_state=42)
df['anomaly_score'] = model.fit_predict(df[['transaction_amount', 'product_price', 'discount_applied']])

anomalies = df[df['anomaly_score'] == -1]
anomalies.to_csv('anomalies.csv', index=False)
