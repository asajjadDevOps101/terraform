bucket_name  = "msjaison-testing-bucket"
backup_types = ["nblnx2", "nbwin2", "qorestor012", "qorestore022"]
lz_code      = "sf-research"
env          = "pg"
# pg
vpc_id  = "vpc-0837451c07e2aa64e"
subnets = ["subnet-01b96eaa0fbe0ddb3", "subnet-01033230c14f6acb5", "subnet-034962b44e4bbf18b"]
cidrs   = ["172.31.48.0/20", "172.31.80.0/20", "172.31.0.0/20"]
sg_id   = "sg-052c5172cf37847d1"
acc_id  = "649010794446"
# dev
#vpc = "vpc-0c316bfd1f5a00e56"
#subnets = ["subnet-0de291a4a81f50b74", "subnet-Ød@fe1446a516bef0", "subnet-029c2516217430b92"]
#cidrs ["100.85.246.0/26", "100.85.246.64/26", "100.85.246.128/26"]
#sg_id = "sg-05b043433ede62247"
#acc_id
required_tags = {
  LineOfBusiness = "San Francisco"
}