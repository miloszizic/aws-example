## _Demonstration/exercise_ project for AWS, Lambda, Python, Go, Terraform, and more



#### This project is using  public AWS modules from the Terraform Registry for infrastructure shown in the diagram below. GitHub Actions is used to compile new committed script code to S3. Terrateam is used to deploy new IaC changes


AWS services used:
* VPC
* S3
* RDS
* ASG
* EC2
* Lambda
* EventBridge

Scripts used for Lambda:
* Python (up-scaling and downscaling, AMI cleanup)
* Go (AMI backup)


![](img/demonstration.png)

#### Usage on a different AWS account:

1. Clone this repository

2. Navigate to provider.tf file and change values of backend "s3" to your S3 bucket
   that will be used for storing the state and make sure you init the state of the project

   3. Configure AWS to allow GitHub Actions to communicate using OpenID Connect
      * Sign in to the AWS Management Console and navigate to the IAM console
      * Select Access management → Identity providers
      * Select Add provider
      * Select OpenID Connect
      * Provider URL: https://token.actions.githubusercontent.com → Get thumbprint
        Audience: sts.amazonaws.com
      * Select Add provider

      4. Create the IAM role using this repository
         * Copy the ARN of GitHub federated identity that you made in first step
         * Navigate to test.tfvars (testing env) and set it as a value for **github_federated_identity**
         * Also in the **test.tfvars** change the **github_repo** and **lambda_s3_name** wich will represent your S3 bucket name
         and the name of the repository you want to use for the project
         * In your repo directory using terminal run :

             `terraform apply -target=module.github_role -target=module.lambda_s3 -var-file=test.tfvars -auto-approve`

              This command will create the IAM role and S3 bucket for you to use
         in the next steps
         * When the apply is finished navigate to your repo and add the folowing secrets:
           * **AWS_ROLE** with the value of github_role_arn in the output from revius command
           * **AWS_S3** with the value of **s3_lambda_bucket_id** in the output from previus command

**_Note_** : Only changes to terraform code will trigger Terrateam. Changes to `scripts` will only trigger GitHub action.

#### TODO:
* Add more infrastructure to get more hands-on experience with AWS resources.
* Add aquasecurity/tfsec
* Use Terragrunt to make the project more modular and DRY.
* Add more documentation.
