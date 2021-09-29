provider "google" {
  project = var.project_id
  region  = var.provider_region
}

locals {  
  cloud_run_url = google_cloud_run_service.events-api.status[0].url
}

resource "google_cloud_run_service" "events-api" {
  name     = "events-api"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/roi-takeoff-user3/events-api:v1.0"
        env {
          name = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
      }
    }
  }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}


resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.events-api.location
  project     = google_cloud_run_service.events-api.project
  service     = google_cloud_run_service.events-api.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

###################
# Cloud Endpoints #
###################
resource "google_endpoints_service" "events-api" {
  service_name = "${replace(local.cloud_run_url, "https://", "")}" # <--------
  openapi_config = <<EOF
    swagger: '2.0'
    host: "${replace(local.cloud_run_url, "https://", "")}"
    schemes:
    - https
    produces:
    - application/json
    x-google-backend:
      address: "https://go-api-ftbqxjavhq-ue.a.run.app"
      protocol: h2
    x-google-allow: "all"

    info:
      title: Events API
      description: API for interactions with events on the board
      version: "0.1"
  
    definitions:
      PostEvent:
        type: object
        properties:
          title:
            type: string
          location:
            type: string
          when:
            type: string
      GetEvent:
        type: object
        properties:
          id:
            type: string
          title:
            type: string
          location:
            type: string
          when:
            type: string

    paths:
      /events:
        get:
          summary: Returns a list of events.
          operationId: getListOfEvents
          produces:
            - application/json
          responses:
            '200':
              description: A JSON array of the events
              schema:
                type: array
                items: 
                  $ref: '#/definitions/GetEvent'
        post:
          summary: Create an events.
          operationId: createEvent
          consumes:
            - application/json
          parameters:
            - in: body
              name: event
              description: The event to create
              schema:
                $ref: '#/definitions/PostEvent'
          responses:
            '200':
              description: OK
      /events/{id}:
        get:
          summary: Get a Event by ID
          operationId: getEventById
          parameters:
          - in: path
            name: id
            type: string
            required: true
            description: String ID of the Event to get
          produces:
          - application/json
          responses:
            '200':
              description: A JSON array of events
              schema:
                $ref: '#/definitions/GetEvent'
        delete:
          summary: Delete an Event by ID
          operationId: deleteEventById
          parameters:
          - in: path
            name: id
            type: string
            required: true
            description: String ID of the Event to get
          produces:
          - application/json
          responses:
            '200':
              description: The Event was deleted successfully

EOF
depends_on = [google_cloud_run_service.events-api]
}