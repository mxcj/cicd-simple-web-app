***
# Simple Web APP #

This project is an example that shows us the CI / CD implementation with AWS tools, CodePipeline, Code Build, Code Deploy, and connected to a Github repository.
The infrastructure used was implemented with terraform and deploys an application in NodeJS to ECS with Fargate, using load balancer.
***
## Install process ##

### Install Node Project ###
```sh
$ npm install
```

### Install Terraform ###

First, let's [install terraform](https://www.terraform.io/downloads.html) 

Then, we must configure the connection to the provider with which we are going to work, for this project we use AWS.

Make sure [AWS CLI is installed](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and you have [configured authorization](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) properly.

Then we initialize terraform with the command.

```sh
$ cd terraform_infraestructure
$ terraform init
```
To start our infrastructure we are going to execute the command

```sh
$ terraform plan
```
This command allows you to see the planning that is going to be deployed in our cloud.

Finalmente, para desplegar la infraestructura, ejecutamos el siguiente comando.
```sh
$ terraform apply
```
## License

MIT