variable "stage" {
  type        = string
  description = "stage: dev, prd"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR, e.g. 10.0.0.0/16"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway"
}

variable "one_nat_gateway_per_az" {
  type        = bool
  description = "One NAT Gateway per AZ (AZ ごとに一つの NAT Gateway を設置するか否か)"
  default     = false
}
