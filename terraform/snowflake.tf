provider "snowflake" {
  account  = "your_snowflake_account"
  user     = "your_username"
  password = "your_password"
  role     = "ACCOUNTADMIN"
  region   = "your_region"
}

resource "snowflake_database" "etl_db" {
  name = "ETL_DATABASE"
}
