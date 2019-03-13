# Build Infrastructure
### About
>This is a POC of building a test infrastructure in AWS using Terraform.

### Prerequisites
* Terraform [installed](https://learn.hashicorp.com/terraform/getting-started/install) on your machine
* AWS Credentials in [place](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html)
* EC2 Key Pairs for accessing machine(s)
* AWS [IAM Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) with permissions for resources that we will create using [main.tf](./main.tf).

### Preparation
> this is done once!

a) clone the repository
```shell
$ git clone https://github.com/awesome-accelerators/build-infrastructure
```

b) create a new Amazon Key Pairs
> see [guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)
> copy to ./secrets folder
> update `private_key_file` from [variables.tf](./variables.tf) to point to this key.

c) Initialize the Terraform working directory
```shell
$ terraform init
```

d) Generate and show the execution plan
```shell
$ terraform plan
```
> You should see now the execution plan of Terraform with all services/resources that will be created. 

### Building
a) starting the build Infrastructure up
```shell
$ make build
```

b) deleting the entire infrastructure
```shell
$ make destroy
```
