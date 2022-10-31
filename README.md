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

#### TODO:
* Add more infrastructure to get more hands-on experience with AWS resources.
* Use Terragrunt to make the project more modular and DRY.
* Add more documentation.
