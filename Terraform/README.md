# Comprehensive Terraform Guide

## Table of Contents
1. [Introduction to Terraform](#introduction-to-terraform)
2. [Installation and Setup](#installation-and-setup)
3. [Terraform CLI Commands](#terraform-cli-commands)
4. [Configuration Syntax](#configuration-syntax)
5. [Providers](#providers)
6. [Resources](#resources)
7. [Variables](#variables)
8. [Outputs](#outputs)
9. [Modules](#modules)
10. [Backend Configuration](#backend-configuration)
11. [State Management](#state-management)
12. [Data Sources](#data-sources)
13. [Functions](#functions)
14. [Conditionals and Loops](#conditionals-and-loops)
15. [Workspaces](#workspaces)
16. [Best Practices](#best-practices)
17. [Troubleshooting](#troubleshooting)

## Introduction to Terraform

Terraform is an Infrastructure as Code (IaC) tool developed by HashiCorp that allows you to define, provision, and manage infrastructure using declarative configuration files. It supports multiple cloud providers and on-premises infrastructure.

### Key Benefits
- **Infrastructure as Code**: Version control your infrastructure
- **Platform Agnostic**: Works with multiple cloud providers
- **State Management**: Tracks infrastructure state
- **Declarative Configuration**: Describe desired state, not steps
- **Plan and Apply**: Preview changes before execution

## Installation and Setup

### Installing Terraform

#### Linux (Ubuntu/Debian)
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

#### macOS
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Verify Installation
```bash
terraform version
```

## Terraform CLI Commands

### Basic Commands

#### terraform init
Initializes a Terraform working directory
```bash
terraform init
terraform init -upgrade          # Upgrade providers
terraform init -backend=false    # Skip backend initialization
```

#### terraform plan
Creates an execution plan
```bash
terraform plan
terraform plan -out=plan.out     # Save plan to file
terraform plan -var="key=value"  # Pass variables
terraform plan -target=resource  # Target specific resource
```

#### terraform apply
Applies the changes required to reach desired state
```bash
terraform apply
terraform apply plan.out         # Apply saved plan
terraform apply -auto-approve    # Skip confirmation
terraform apply -target=resource # Apply specific resource
```

#### terraform destroy
Destroys managed infrastructure
```bash
terraform destroy
terraform destroy -auto-approve
terraform destroy -target=resource
```

### State Management Commands

#### terraform state
Manage Terraform state
```bash
terraform state list                    # List resources in state
terraform state show resource_name      # Show resource details
terraform state mv old_name new_name    # Rename resource
terraform state rm resource_name        # Remove resource from state
terraform state pull                    # Download remote state
terraform state push                    # Upload state to remote
```

#### terraform import
Import existing infrastructure
```bash
terraform import resource_type.name resource_id
terraform import aws_instance.example i-1234567890abcdef0
```

### Validation and Formatting

#### terraform validate
Validates configuration files
```bash
terraform validate
```

#### terraform fmt
Formats configuration files
```bash
terraform fmt
terraform fmt -recursive    # Format all files recursively
terraform fmt -check        # Check if files are formatted
```

### Output Commands

#### terraform output
Display output values
```bash
terraform output
terraform output output_name
terraform output -json
```

### Other Useful Commands

#### terraform show
Display current state or saved plan
```bash
terraform show
terraform show plan.out
terraform show -json
```

#### terraform refresh
Update state with real infrastructure
```bash
terraform refresh
```

#### terraform graph
Generate visual representation
```bash
terraform graph | dot -Tpng > graph.png
```

## Configuration Syntax

Terraform uses HashiCorp Configuration Language (HCL) for configuration files.

### Basic Syntax Structure

```hcl
# Single line comment
/* Multi-line
   comment */

# Block structure
block_type "block_label" "block_name" {
  argument_name = argument_value
  
  nested_block {
    nested_argument = "value"
  }
}
```

### File Structure
- **main.tf**: Primary configuration
- **variables.tf**: Input variables
- **outputs.tf**: Output values
- **terraform.tf**: Terraform settings
- **terraform.tfvars**: Variable values

### Data Types

#### Primitive Types
```hcl
# String
variable "name" {
  type    = string
  default = "example"
}

# Number
variable "count" {
  type    = number
  default = 3
}

# Boolean
variable "enabled" {
  type    = bool
  default = true
}
```

#### Complex Types
```hcl
# List
variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

# Map
variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "example"
  }
}

# Object
variable "server_config" {
  type = object({
    name     = string
    size     = string
    port     = number
    enabled  = bool
  })
}

# Tuple
variable "mixed_list" {
  type    = tuple([string, number, bool])
  default = ["example", 42, true]
}

# Set
variable "unique_items" {
  type    = set(string)
  default = ["item1", "item2", "item3"]
}
```

## Providers

Providers are plugins that interact with APIs of cloud providers and other services.

### Provider Configuration

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Azure Provider
provider "azurerm" {
  features {}
}

# Multiple Provider Instances
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"
}
```

### Using Provider Aliases
```hcl
resource "aws_instance" "west_server" {
  provider = aws.west
  # ... configuration
}

resource "aws_instance" "east_server" {
  provider = aws.east
  # ... configuration
}
```

## Resources

Resources are the most important element in Terraform configuration.

### Resource Syntax
```hcl
resource "resource_type" "local_name" {
  argument1 = value1
  argument2 = value2
  
  nested_block {
    nested_argument = value
  }
  
  # Meta-arguments
  depends_on = [other_resource.name]
  count      = 2
  for_each   = var.items
  provider   = aws.west
  lifecycle {
    create_before_destroy = true
  }
}
```

### Common AWS Resources

#### EC2 Instance
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF
}
```

#### VPC and Networking
```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "main-igw"
  }
}
```

#### S3 Bucket
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-name"
  
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
```

### Meta-Arguments

#### count
```hcl
resource "aws_instance" "server" {
  count         = 3
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  
  tags = {
    Name = "Server-${count.index + 1}"
  }
}
```

#### for_each
```hcl
variable "users" {
  type = set(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "users" {
  for_each = var.users
  name     = each.value
}
```

#### depends_on
```hcl
resource "aws_instance" "app" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  
  depends_on = [aws_security_group.app_sg]
}
```

#### lifecycle
```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags]
  }
}
```

## Variables

Variables allow you to parameterize your Terraform configurations.

### Variable Declaration
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition = contains([
      "t2.micro", 
      "t2.small", 
      "t2.medium"
    ], var.instance_type)
    error_message = "Instance type must be t2.micro, t2.small, or t2.medium."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "example"
  }
}

variable "server_config" {
  description = "Server configuration object"
  type = object({
    name    = string
    size    = string
    port    = number
    enabled = bool
  })
  default = {
    name    = "web-server"
    size    = "small"
    port    = 80
    enabled = true
  }
}
```

### Variable Assignment

#### terraform.tfvars
```hcl
instance_type = "t2.small"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
tags = {
  Environment = "production"
  Owner       = "devops-team"
}
```

#### Environment Variables
```bash
export TF_VAR_instance_type="t2.medium"
export TF_VAR_region="us-east-1"
```

#### Command Line
```bash
terraform apply -var="instance_type=t2.large" -var="region=us-east-1"
terraform apply -var-file="production.tfvars"
```

### Local Values
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = "devops-team"
  }
  
  instance_name = "${var.environment}-${var.project_name}-server"
  
  # Complex expressions
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = merge(local.common_tags, {
    Name = local.instance_name
  })
}
```

## Outputs

Outputs expose information about your infrastructure.

### Output Declaration
```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
  sensitive   = false
}

output "database_password" {
  description = "Database password"
  value       = aws_db_instance.database.password
  sensitive   = true
}

output "vpc_info" {
  description = "VPC information"
  value = {
    vpc_id     = aws_vpc.main.id
    cidr_block = aws_vpc.main.cidr_block
    dns_support = aws_vpc.main.enable_dns_support
  }
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}
```

### Using Outputs in Other Configurations
```hcl
# In another configuration
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = data.terraform_remote_state.network.outputs.private_subnet_ids[0]
}
```

## Modules

Modules are containers for multiple resources that are used together.

### Module Structure
```
modules/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── ec2/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

### Creating a Module

#### modules/vpc/main.tf
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(var.tags, {
    Name = "${var.name}-public-${count.index + 1}"
    Type = "public"
  })
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(var.tags, {
    Name = "${var.name}-private-${count.index + 1}"
    Type = "private"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}
```

#### modules/vpc/variables.tf
```hcl
variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

#### modules/vpc/outputs.tf
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
```

### Using a Module
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  name               = "production"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b"]
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  
  tags = {
    Environment = "production"
    Project     = "web-app"
  }
}

# Reference module outputs
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_ids[0]
  
  tags = {
    Name = "web-server"
  }
}
```

### Module Sources

#### Local Modules
```hcl
module "vpc" {
  source = "./modules/vpc"
}
```

#### Git Repository
```hcl
module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
}

# Specific branch/tag
module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v3.0.0"
}
```

#### Terraform Registry
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
}
```

## Backend Configuration

Backends determine where Terraform stores its state data.

### Local Backend (Default)
```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

### S3 Backend
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "path/to/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### Azure Storage Backend
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "myResourceGroup"
    storage_account_name = "mystorageaccount"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

### Google Cloud Storage Backend
```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state-bucket"
    prefix = "terraform/state"
  }
}
```

### Backend Configuration File
Create `backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-west-2"
  }
}
```

### Partial Backend Configuration
```hcl
terraform {
  backend "s3" {}
}
```

Initialize with backend config:
```bash
terraform init \
  -backend-config="bucket=my-terraform-state" \
  -backend-config="key=path/terraform.tfstate" \
  -backend-config="region=us-west-2"
```

## State Management

Terraform state tracks the mapping between configuration and real infrastructure.

### State File Structure
```json
{
  "version": 4,
  "terraform_version": "1.0.0",
  "serial": 1,
  "lineage": "uuid",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "example",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "id": "i-1234567890abcdef0",
            "ami": "ami-0c02fb55956c7d316",
            "instance_type": "t2.micro"
          }
        }
      ]
    }
  ]
}
```

### State Locking
When using remote backends that support locking:
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

DynamoDB table for locking:
```hcl
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### State Commands

#### Move Resources
```bash
terraform state mv aws_instance.old aws_instance.new
```

#### Remove Resources
```bash
terraform state rm aws_instance.example
```

#### Import Resources
```bash
terraform import aws_instance.example i-1234567890abcdef0
```

#### Replace Resources
```bash
terraform apply -replace=aws_instance.example
```

## Data Sources

Data sources fetch information from existing infrastructure.

### Basic Data Source Usage
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}
```

### Common Data Sources

#### AWS Availability Zones
```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "example" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}
```

#### AWS VPC
```hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
```

#### AWS Caller Identity
```hcl
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```

## Functions

Terraform provides built-in functions for transforming and combining values.

### String Functions
```hcl
locals {
  # String manipulation
  upper_name    = upper("hello world")           # "HELLO WORLD"
  lower_name    = lower("HELLO WORLD")           # "hello world"
  title_name    = title("hello world")           # "Hello World"
  trimmed       = trim("  hello world  ", " ")   # "hello world"
  
  # String formatting
  formatted     = format("Hello, %s!", "world")  # "Hello, world!"
  interpolated  = "Hello, ${var.name}!"
  
  # String replacement
  replaced      = replace("hello world", "world", "terraform")  # "hello terraform"
  
  # String splitting and joining
  split_string  = split(",", "a,b,c")            # ["a", "b", "c"]
  joined_string = join(",", ["a", "b", "c"])     # "a,b,c"
  
  # Regular expressions
  regex_result  = regex("[0-9]+", "abc123def")   # "123"
}
```

### Numeric Functions
```hcl
locals {
  # Math operations
  absolute    = abs(-5)           # 5
  ceiling     = ceil(4.3)         # 5
  floor_val   = floor(4.7)        # 4
  maximum     = max(1, 2, 3)      # 3
  minimum     = min(1, 2, 3)      # 1
  
  # Random values
  random_id   = random_id.example.hex
  random_int  = random_integer.example.result
}

resource "random_id" "example" {
  byte_length = 8
}

resource "random_integer" "example" {
  min = 1
  max = 100
}
```

### Collection Functions
```hcl
variable "users" {
  type = list(object({
    name = string
    role = string
    age  = number
  }))
  default = [
    { name = "alice", role = "admin", age = 30 },
    { name = "bob", role = "user", age = 25 },
    { name = "charlie", role = "admin", age = 35 }
  ]
}

locals {
  # List operations
  user_names     = [for user in var.users : user.name]
  admin_users    = [for user in var.users : user if user.role == "admin"]
  user_ages      = { for user in var.users : user.name => user.age }
  
  # Collection functions
  length_count   = length(var.users)                    # 3
  contains_admin = contains(local.user_names, "admin")  # false
  index_of_bob   = index(local.user_names, "bob")       # 1
  
  # Set operations
  unique_roles   = toset([for user in var.users : user.role])
  
  # Merging
  merged_tags    = merge(var.common_tags, var.specific_tags)
  
  # Flattening
  nested_list    = [["a", "b"], ["c", "d"]]
  flattened      = flatten(local.nested_list)           # ["a", "b", "c", "d"]
}
```

### Date and Time Functions
```hcl
locals {
  current_time = timestamp()
  formatted_time = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
}
```

### Encoding Functions
```hcl
locals {
  # Base64 encoding/decoding
  encoded = base64encode("hello world")
  decoded = base64decode(local.encoded)
  
  # JSON encoding/decoding
  json_encoded = jsonencode({
    name = "example"
    tags = ["tag1", "tag2"]
  })
  json_decoded = jsondecode(local.json_encoded)
  
  # URL encoding
  url_encoded = urlencode("hello world")
}
```

### File Functions
```hcl
locals {
  # Read files
  file_content = file("${path.module}/config.txt")
  template_content = templatefile("${path.module}/template.tpl", {
    name = var.name
    port = var.port
  })
  
  # File paths
  module_path = path.module
  root_path   = path.root
  current_dir = path.cwd
}
```

## Conditionals and Loops

### Conditional Expressions
```hcl
variable "environment" {
  type = string
}

locals {
  # Ternary operator
  instance_type = var.environment == "production" ? "t3.large" : "t2.micro"
  
  # Complex conditions
  enable_monitoring = var.environment == "production" || var.enable_debug
  
  # Null checks
  database_name = var.db_name != null ? var.db_name : "default-db"
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = local.instance_type
  
  # Conditional resource creation
  count = var.create_instance ? 1 : 0
  
  # Conditional blocks
  dynamic "ebs_block_device" {
    for_each = var.ebs_volumes
    content {
      device_name = ebs_block_device.value.device_name
      volume_size = ebs_block_device.value.volume_size
      volume_type = ebs_block_device.value.volume_type
    }
  }
}
```

### For Expressions
```hcl
variable "users" {
  type = list(object({
    name = string
    role = string
  }))
}

locals {
  # List comprehension
  user_names = [for user in var.users : user.name]
  admin_users = [for user in var.users : user.name if user.role == "admin"]
  
  # Map comprehension
  user_roles = { for user in var.users : user.name => user.role }
  
  # Complex transformations
  user_configs = {
    for user in var.users : user.name => {
      role = user.role
      is_admin = user.role == "admin"
      config_file = "${user.name}-config.json"
    }
  }
}
```

### Dynamic Blocks
```hcl
variable "security_group_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

resource "aws_security_group" "example" {
  name_prefix = "example-"
  
  dynamic "ingress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  
  dynamic "egress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "egress"]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
```

## Workspaces

Workspaces allow you to manage multiple environments with the same configuration.

### Workspace Commands
```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# Switch workspace
terraform workspace select development

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete development
```

### Using Workspaces in Configuration
```hcl
locals {
  environment = terraform.workspace
  
  # Environment-specific configurations
  instance_type = {
    default    = "t2.micro"
    staging    = "t2.small"
    production = "t3.large"
  }
  
  instance_count = {
    default    = 1
    staging    = 2
    production = 5
  }
}

resource "aws_instance" "web" {
  count         = local.instance_count[terraform.workspace]
  ami           = var.ami_id
  instance_type = local.instance_type[terraform.workspace]
  
  tags = {
    Name = "${terraform.workspace}-web-${count.index + 1}"
    Environment = terraform.workspace
  }
}
```

### Workspace State Files
When using workspaces, Terraform creates separate state files:
```
terraform.tfstate.d/
├── development/
│   └── terraform.tfstate
├── staging/
│   └── terraform.tfstate
└── production/
    └── terraform.tfstate
```

## Best Practices

### Project Structure
```
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   └── prod/
├── modules/
│   ├── vpc/
│   ├── ec2/
│   └── rds/
├── global/
│   ├── iam/
│   └── s3/
└── scripts/
    ├── deploy.sh
    └── destroy.sh
```

### Naming Conventions
```hcl
# Resources
resource "aws_instance" "web_server" {}           # snake_case
resource "aws_s3_bucket" "app_logs" {}

# Variables
variable "instance_type" {}                       # snake_case
variable "availability_zones" {}

# Locals
locals {
  common_tags = {}                                # snake_case
  instance_name = "${var.environment}-web"
}

# Outputs
output "instance_id" {}                           # snake_case
output "public_ip_address" {}
```

### Security Best Practices

#### Sensitive Data Management
```hcl
# Use sensitive variables
variable "database_password" {
  type      = string
  sensitive = true
}

# Mark outputs as sensitive
output "database_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}

# Use AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

#### Resource Tagging
```hcl
locals {
  common_tags = {
    Environment   = var.environment
    Project       = var.project_name
    Owner         = var.owner
    ManagedBy     = "terraform"
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
  }
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = merge(local.common_tags, {
    Name = "${var.environment}-web-server"
    Type = "web-server"
  })
}
```

### Code Organization

#### Use Modules
```hcl
# Instead of repeating configuration
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block = var.vpc_cidr
  name       = var.vpc_name
  tags       = local.common_tags
}

module "web_servers" {
  source = "./modules/ec2"
  
  count           = var.web_server_count
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids
  instance_type   = var.instance_type
  tags            = local.common_tags
}
```

#### Version Constraints
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
```

## Troubleshooting

### Common Issues and Solutions

#### State Lock Issues
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID

# Check lock status
terraform state list
```

#### Provider Issues
```bash
# Upgrade providers
terraform init -upgrade

# Reinstall providers
rm -rf .terraform
terraform init
```

#### State Drift
```bash
# Refresh state
terraform refresh

# Import existing resources
terraform import aws_instance.example i-1234567890abcdef0

# Plan to see differences
terraform plan
```

#### Debugging
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH="terraform.log"

# Different log levels
export TF_LOG=TRACE    # Most verbose
export TF_LOG=DEBUG
export TF_LOG=INFO
export TF_LOG=WARN
export TF_LOG=ERROR
```

### Validation and Testing

#### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
```

#### Testing with Terratest
```go
// test/terraform_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformExample(t *testing.T) {
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "instance_type": "t2.micro",
        },
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    instanceID := terraform.Output(t, terraformOptions, "instance_id")
    assert.NotEmpty(t, instanceID)
}
```

### Performance Optimization

#### Parallelism
```bash
# Increase parallelism
terraform apply -parallelism=20

# Decrease for resource limits
terraform apply -parallelism=5
```

#### Target Specific Resources
```bash
# Apply only specific resources
terraform apply -target=aws_instance.web
terraform apply -target=module.vpc

# Plan specific resources
terraform plan -target=aws_instance.web
```

This comprehensive guide covers all major aspects of Terraform. Use it as a reference for your Infrastructure as Code projects.
