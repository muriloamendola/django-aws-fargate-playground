# django-aws-fargate-playground
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

Scalability is an essential software component. Prioritizing it from the start leads to lower maintenance costs, better user experience, and higher agility. 

Thinking in that one of the biggest problem when talking about scalability is the database.

This project is an study case where we will build a very simple API with Django Rest Framework, which consumes data from a serverless postgres database provided by AWS. Then we will dockerize our app and deploy it in an "production environment" using AWS Fargate.

## Requirements

* Django Rest Framework >= 3.11.0 (powerful and flexible toolkit for building Web APIs)
* AWS Account (You need to have an AWS account to deploy the application and to create the database)
* [Docker](https://www.docker.com/) (We will deploy our app using docker containers for this reason you should know docker concepts to understand how things are working).

## Running project locally

After clone or download this repository you must configure a file called `.env` inside the main folder `tutorial`. As you can see, inside this folder there is a sample file called `.env.example` that you can copy or rename to `.env`.

This file is where we can configure our environments variables using keys.

| WARNING: be careful in production environment you must configure this variables using other aproach! |
| --- |

For running this project locally, just keep the file with two keys:

```
DEBUG=True
SECRET_KEY=${Put same random and unique value here}
```

When you don't configure a `DATABASE_URL` key by default the app will use Sqlite DB Engine.

After create the `.env` file just run the following command:

```bash
docker-compose up
```

If the command was successful your terminal will show:
![server running locally](./docs/fargate/server-local.png)

The server will be available on http://0.0.0.0:8800/.
![server running locally on http://0.0.0.0:8800](./docs/fargate/server-local-available.png)

## Running project in AWS

To create and activate a new AWS Account, please follow the steps covered by this article: [How do I create and activate a new Amazon Web Services account?](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/).

After that is it important to install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) which will allow us to do changes at our AWS Account from command line.

Finally, you can [configure your aws credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

### Creating AWS Fargate Cluster

To know more about AWS Fargate you should read the oficial [documentation](https://aws.amazon.com/fargate/).

This chapter will cover the configuration of a AWS Fargate Cluster where we will deploy our application. 

As you have read AWS Fargate is a serverless compute engine for containers so we need to configure the container that will run our application.

#### Elastic Container Repository (ECR)

To do this we have created the [Dockerfile](./Dockerfile) that contains the instructions to build a docker image thar can be used to create containeres to run our application.

We will store this docker image in a Elastic Container Repository (ECR). To create this repository you can run the following command:

```bash
aws ecr create-repository --repository-name django-aws-fargate-playground --region us-east-1
```

If the command is successful we should see:

```json
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-east-1:${accountId}:repository/django-aws-fargate-playground",
        "registryId": "${accountId}",
        "repositoryName": "django-aws-fargate-playground",
        "repositoryUri": "${accountId}.dkr.ecr.us-east-1.amazonaws.com/django-aws-fargate-playground",
        "createdAt": 1550555101.0
    }
}
```

In AWS console you will see something like this:
![ECR Repository](./docs/fargate/ecr.png)

After click on the repository name you will see all the images inside that repository. Click on `View push commands` to see a list of commands that we need to run to be able to push our image to ECR. Follow the steps as they are given.

Now we have pushed our image in ECR.

![ECR Repository list of images and push commands](./docs/fargate/ecr-after-push-image.png)

After pushing the image you can see the second column called Image URI (we will use this info to configure the Task container in AWS Fargate).

### AWS Fargate

Now, let us go to the link https://console.aws.amazon.com/ecs/home?region=us-east-1#/getStarted and create a new Fargate Application. Click on `Get Started`.

Now select under the container definition choose Custom and click on Configure.
![AWS Fargate configure custom container](./docs/fargate/aws-fargate-get-started.png)

In the popup, enter a name for the container (django-aws-fargate-playground-container) and add the URL to the container image we have pushed to ECR in the step before.

![AWS Fargate custom container configuration](./docs/fargate/fargate-edit-custom-container.png)
![AWS Fargate custom container creation](./docs/fargate/fargate-edit-custom-container-step2.png)
![AWS Fargate service definition](./docs/fargate/fargate-define-your-service.png)
![AWS Fargate cluster definition](./docs/fargate/fargate-configure-your-cluster.png)
![AWS Fargate cluster review](./docs/fargate/fargate-review.png)
![AWS Fargate cluster created](./docs/fargate/fargate-cluster-created.png)

Now we can see the status of the service we just created.After the steps being completed click on `View Service` button.

Now we can test our fargate cluster. For that on the services page, click on the Tasks tab (as ilustrated in the image below) to see the different tasks running for our application. Click on the task id to see details about that task.
![AWS Fargate service details](./docs/fargate/service-details.png)
![AWS Fargate task details](./docs/fargate/task-details.png)

As you can see a public IP was atributed to our cluster so you can access the application going to the url http://52.91.33.228:8800
![AWS Fargate application successful](./docs/fargate/application-successful.png)

A last important point in this topic is about `VPC`. AWS Fargate creates a new VPC, subnets and security group for our cluster. In the next topic we will see how to create Aurora Serverless Database and we have to run this database inside the same VPC of our AWS Fargate Cluster because that is the only way to grant access to the database to our container.

You can see the VPC created under service details tab:
![AWS Fargate service details](./docs/fargate/service-network-details.png)

### Creating Aurora Serverless Database

Inside AWS Console go to RDS and create a new Database.
![AWS RDS create database](./docs/rds/create-database.png)

We choose postgres compatibility, but, you can choose mysql if you prefer.

In this project we will use Serveless database to delegate to AWS the responsibility to scale our infrastructure when it is necessary and we will pay only for the effective resources use.
![AWS RDS database features](./docs/rds/database-features.png)

And finally the point about VPC that we have commented, don't forget to choose the VPC created by AWS Fargate in the step before.
![AWS RDS database connectivity](./docs/rds/connectivity.png)

After that click on Create Database and wait until the creation process ends.
![AWS RDS database list](./docs/rds/databases-list.png)

Click on DB Identifier to see database details. Inside this page you will see the instructions to connect to your database.
![AWS RDS database details](./docs/rds/database-details.png)

To see the oficial docs about how to connect to an Amazon Aurora DB Cluster access the url: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Connecting.html

Now that we can build the connection string to the database and configure the key `DATABASE_URL` in the .env file, then generate a new docker image with the new version of the application and push to ECR.

In our case we can build the postgres connection url in the following way:

```
DATABASE_URL=psql://urser:password@host:5432/database_name
```

By default `database_name` is `postgres`. Unless you have specified a different name during the process of database creation.

After create this key into the file .env, repeat the steps to generate a new image and to push it to ECR repository we have created. You could review the steps [clicking here](https://github.com/muriloamendola/django-aws-fargate-playground#elastic-container-repository-ecr)

### Allow container to access the database

Now we have all the configurations necessary to run our application in AWS, but, we need to allow our container to access the database.

To do it we need to insert our container security group into the Inbound configuration of the database security group as you can see in the image below:

![AWS RDS database details security group](./docs/rds/database-details-sg.png)
![AWS RDS database details security group](./docs/rds/db-security-group-inbound.png)

After that your container will have the grants to access the database.

## Contributing

Yes, please!
This project was created just for study and to guide other developers who would like to use this tecnologies. Any other suggestion will be kindly accepted!

Any doubts or suggestions please contact me muriloamendola@gmail.com.