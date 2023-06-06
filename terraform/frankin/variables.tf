// globally unique bucket name
variable "bucket_name" {
  type    = string
  default = "msjaison-testing-bucket"
}
// backup types
variable "backup_types" {
  type = list(string)
}
// name of your landing zone
variable "lz_code" {
  type = string
}
// subnets
variable "subnets" {
  type = list(string)
}


// pg, dev, test, uat, staging, prod
variable "env" {
  type = string
}
// VPC

variable "vpc_id" {
  type = string
}
// CIDR blocks
variable "cidrs" {
  type = list(string)
}
// security group
variable "sg_id" {
  type = string
}
// account id
variable "acc_id" {
  type = string
}
variable "required_tags" {
  type = object({
    LineOfBusiness = string
  })
}

variable "kms_deletion_window_day" {
  type    = number
  default = 30
}

