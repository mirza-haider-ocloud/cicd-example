#### FastAPI project with basic DB CRUD operations. Infrastructure provisioning through Terraform. CI/CD pipeline configured via Github Actions.


## CI/CD overview
* Infrastructure provisioning via Terraform has been integrated as part of CI/CD pipeline.
On every push to main, CI/CD workflow sets up infrastructure _(EC2 instance, MySQL DB, etc)_ if it is not already set up.
* Build and push docker image to Docker Hub
* SSH into EC2 instance and pull the latest image during deployment


## Set secret keys on Github
CI/CD pipeline will require following secret keys to work:
```
- AWS_ACCESS_KEY
- AWS_SECRET_ACCESS_KEY
- DOCKERHUB_PASSWORD
- DOCKERHUB_USERNAME
```

`AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY` will be required by Terraform to set up AWS resources.  
`DOCKERHUB_PASSWORD` and `DOCKERHUB_USERNAME` will be used to sign in to Docker Hub and push latest image.


Once secret keys are set up, push to the main branch, or manually trigger deployment workflow to ensure everything is working great!
