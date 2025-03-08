provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "airflow" {
  name = "airflow-cluster"
}

resource "aws_ecs_task_definition" "airflow" {
  family = "airflow-task"
  container_definitions = jsonencode([
    {
      "name": "airflow",
      "image": "apache/airflow:latest",
      "memory": 1024,
      "cpu": 512,
      "essential": true
    }
  ])
}
