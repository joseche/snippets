# Terraform Snippets

## Example Providers

```sh
terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4,<=5"
    }
  }
  backend "s3" {
    bucket = "my-terraform-backend"
    key    = "thisproject/envqa.tfstate"
    region = "us-east-1"
    # if state locking is required
    # dynamodb_table = "terraform-state-locking"
  }
}
```

## Example Ami data

```sh
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]  # encripted
    # values = ["amzn2-ami-hvm*"]  - not encripted
  }
}

data "aws_region" "current" {}

resource "aws_instance" "someapp" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_groups
  iam_instance_profile   = var.instance_profile
  subnet_id              = var.instance_subnet_id
  tags = merge(var.additional_tags, {
    Name = "${var.resource_prefix}-someapp"
  })

  root_block_device {
    volume_type = "gp3"
    volume_size = "500"
  }
}
```

## Commands, Environment Variables, Log, Graph, State

```sh
# Declare variables
export TF_VAR_instancetype t2.nano
terraform plan -var="instancetype=t2.small"
terraform plan -var-file="custom.tfvars"

# set trace log
export TF_LOG_PATH=/tmp/crash.log

# TRACE, DEBUG, INFO, WARN, ERROR
export TF_LOG=TRACE

# generate dependencies graph
terraform graph > graph.dot
yum install graphviz
cat graph.dot | dot -Tsvg > graph.svg

# Save a plan, apply a plan
terraform plan -out=demopath
terraform apply demopath

# Formatting
terraform fmt

# Validation
terraform validate
```

## State Management

```sh
terraform state list
terraform state mv aws_instance.webapp aws_instance.myec2
terraform state pull
terraform state rm aws_instance.myec2

# import existing resources
terraform import aws_instance.myec2 i-041886ebb7e9bd20

# taints
terraform taint aws_instance.myec2

```

## Conditional resource count

```sh
resource "aws_instance" "dev" {
   ami = "ami-082b5a644766e0e6f"
   instance_type = "t2.micro"
   count = var.istest == true ? 3 : 0
}
```

## Count List

```sh
variable "elb_names" {
  type = list
  default = ["dev", "stage","prod"]
}
resource "aws_iam_user" "lb" {
  name = var.elb_names[count.index]
  count = 3
  path = "/system/"
} 
```

## Dynamic Blocks

```sh
variable "sg_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [8200, 8201,8300, 9200, 9500]
}

resource "aws_security_group" "dynamicsg" {
  name        = "dynamic-sg"
  description = "Ingress for Vault"

  dynamic "ingress" {
    for_each = var.sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

## Lookup

lookup(map, key, default)

```sh
variable "ami" {
  type = map
  default = {
    "us-east-1" = "ami-0323c3dd2da7fb37d"
    "us-west-2" = "ami-0d6621c01e8c2de2c"
    "ap-south-1" = "ami-0470e33cd681b2476"
  }
}
resource "aws_instance" "app-dev" {
   ami = lookup(var.ami,var.region)
   instance_type = "t2.micro"
}
```

## Common tags

```sh
locals {
  common_tags = {
    Owner = "DevOps Team"
    service = "backend"
  }
}
resource "aws_instance" "app-dev" {
   ami = "ami-082b5a644766e0e6f"
   instance_type = "t2.micro"
   tags = local.common_tags
}
```

## zipmap

```sh
zipmap(["pineapple","oranges","strawberry"], ["yellow","orange","red"])
output "zipmap" {
  value = zipmap(aws_iam_user.lb[*].name, aws_iam_user.lb[*].arn)
}
```

## Instance Provisioners

```sh
resource "aws_instance" "myec2" {
   ami = "ami-0b1e534a4ff9019e0"
   instance_type = "t2.micro"
   key_name = "ec2-key"
   vpc_security_group_ids  = [aws_security_group.allow_ssh.id]

   provisioner "remote-exec" {
     on_failure = continue
     inline = [
       "sudo yum -y install nano"
     ]
   }
   provisioner "remote-exec" {
     when    = destroy
     inline = [
       "sudo yum -y remove nano"
     ]
   }
   connection {
     type = "ssh"
     user = "ec2-user"
     private_key = file("./ec2-key.pem")
     host = self.public_ip
   }

  provisioner "local-exec" {
    command = "echo ${aws_instance.myec2.private_ip} >> private_ips.txt"
  }
}
```

## Null Resource

A null resource is a resource that checks the `triggers` and runs the provisioners when any value of the triggers changes

```sh
resource "null_resource" "ips_check" {
 triggers = {
    latest_ips = join(",", aws_eip.lb[*].public_ip)
 }
 provisioner "local-exec" {
   command = "echo Latest IPs are ${null_resource.ip_check.triggers.latest_ips}"
  }
}
```

## Sensitive values

```sh
output "db_password" {
  value = local.db_password
  sensitive   = true
}
```

## Vault

```sh
provider "vault" {
  address = "http://127.0.0.1:8200"
}

data "vault_generic_secret" "demo" {
  path = "secret/db_creds"
}

output "vault_secrets" {
  value = data.vault_generic_secret.demo.data_json
  sensitive = "true"
}
```

## Sleep / Delay for a resource
This is useful to wait for resources to come up

```sh
resource "time_sleep" "wait_300_seconds" {
  create_duration = "300s"
}
```

## Remote state

### network_project

```sh
terraform {
  backend "s3" {
    bucket = "my-terraform-backend"
    key    = "network/eip.tfstate"
    region = "us-east-1"
  }
}
resource "aws_eip" "lb" {
  vpc      = true
}
output "eip_addr" {
  value = aws_eip.lb.public_ip
}
```

### security_project

```sh
data "terraform_remote_state" "eip" {
  backend = "s3"
  config = {
    bucket = "kplabs-terraform-backend"
    key    = "network/eip.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["${data.terraform_remote_state.eip.outputs.eip_addr}/32"]
  }
}
```

## Terraform Workspaces

Allows to have different variables for multiple environments

```sh
terraform workspace show
terraform workspace new dev
terraform workspace new qa
terraform workspace list
terraform workspace select qa
```

Apply different instance type per workspace

```sh
variable "instance_type" {
  type = "map"

  default = {
    default = "t2.nano"
    dev     = "t2.micro"
    prd     = "t2.large"
  }
}
resource "aws_instance" "myec2" {
   ami = "ami-082b5a644766e0e6f"
   instance_type = lookup(var.instance_type,terraform.workspace)
}
```

## gitignore

```sh
.terraform
terraform.tfvars
terraform.tfstate
crash.log
```

## Functions

### Numeric

abs, ceil, floor, log, max, min, parseint, pow, signum

### Strings

chomp, format, formatlist, indent, join, lower, regex, regexall, replace, split, strrev, substr, title, trim, trimprefix, trimsuffix, trimspace, upper

### Collections

alltrue, anytrue, chunklist, coalesce, coalescelist, compact, concat, contains, distinct, element, flatten, index, keys, lenght, lookup, merge, one, reverse, setintersection, setproduct, setsubtract, setunion, slice, sort, sum, transpose, values, zipmap

### Encodings

base64decode, base64encode, base64gzip, csvdecode, jsondecode, jsonencode, textdecodebase64, textencodebase64, urlencode, yamldecode, yamldecode

### Filesystem

abspath, dirname, pathexpand, basename, file, fileexists, fileset, filebase64, templatefile

### Date & Time

formatdate, timeadd, timestamp

### Hash & Crypto

base64sha256, base64sha512, bcrypt, filebase64sha256, filebase64sha512, filemd5, filesha1, filesha256, filesha512, md5, rsadecrypt, sha1, sha256, sha512, uuid, uuidv5

### IP functions

cidrhost, cidrnetmask, cidrsubnet, cidrsubnets

### Type Conversion

can, defaults, nonsensitive, sensitive, tobool, tolist, tomap, tonumber, toset, tostring, try, type
