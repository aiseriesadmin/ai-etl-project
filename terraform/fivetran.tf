provider "fivetran" {}

resource "fivetran_connector" "postgres_snowflake" {
  service = "postgres"
  destination_id = "your_snowflake_destination_id"
  paused = false
  sync_frequency = 5
  config = {
    host = "your_database_host"
    port = 5432
    database = "transactions_db"
    user = "your_db_user"
    password = "your_db_password"
    schemas = ["public"]
  }
}
