variable "aws_region" {
  description = "AWS region that we are going to deploy to"
  default     = "ap-southeast-2"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  default     = "10.1.0.0/24"
  type        = string
}

variable "rcon_password" {
  description = "RCON Password"
  type        = string
}

variable "pavlov_api_key" {
  description = "Pavlov API Key - get one from https://pavlov-ms.vankrupt.com/servers/v1/key"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "z1d.large"
}

variable "server_name" {
  description = "Server Name"
  type        = string
  default     = "A Random Server"
}

variable "moderators" {
  description = "A multi-line string of moderators"
  type        = string
  default     = ""
}

variable "maprotations" {
  description = "A multi-line string of maprotations"
  type        = string
  default     = <<-EOS
MapRotation=(MapId="haguenau", GameMode="TDM")
MapRotation=(MapId="bunker", GameMode="TDM")
EOS
}