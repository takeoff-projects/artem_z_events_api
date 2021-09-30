# go-api

Backend part of [events app](https://events-website-4kad4w6jba-uc.a.run.app/) with sample code from https://github.com/drehnstrom/go-website


Frontend here: https://github.com/takeoff-projects/artem_z_events_website

Built with `gcloud builds`. Deployed to GCP with Terraform and Cloud Run

Stores Events data in Google Firestore (Native mode)

## Build and deploy

```
./install.sh
```

## Undeploy (destroy resourses)

```
./uninstall.sh
```