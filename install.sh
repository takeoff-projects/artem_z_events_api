gcloud builds submit --tag gcr.io/roi-takeoff-user3/events-api:v1.0.1
terraform init && terraform apply -auto-approve --var="project_id=roi-takeoff-user3"
