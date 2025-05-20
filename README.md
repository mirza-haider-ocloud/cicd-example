#### FastAPI project with basic DB CRUD operations. Infrastructure provisioning through Terraform. CI/CD pipeline configured via Github Actions.

CI/CD has been set up for this repository via github actions. However, we do need to set up infrastructure for the app. Then, we also need to set respective secret keys so github actions can proceed successfully.

## Infrastructure Provision
Set up an AWS IAM user and get its access key & secret access key.
Then open a terminal session and add AWS credentials as environment variables. This way Terraform will be able to use them.

```
export AWS_ACCESS_KEY="{your access key}" 
export AWS_SECRET_ACCESS_KEY="{your secret access key}"
```

Now we'll use terraform to launch the ec2 instance to host the app
```
cd cicd-example/infra
terraform init
terraform apply
```

## Set secret keys on Github
CI/CD pipeline will require following secret keys to work:
```
- EC2_HOST
- EC2_KEY
- DB_ENDPOINT
```

Once terraform has set up the infrastructure, it will output `public_ip` of the ec2 instance and `db_address` of the MySQL database that has been launched. 
Terraform will also create `terraform-key.pem` file in _infra_ directory.
Take note of these environment variables as they will be required.

Now go to Github repository settings, and replace the secret keys with these values.

Push to the main branch, or manually trigger deployment workflow to ensure everything is working great!
