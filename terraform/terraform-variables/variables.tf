variable "filename1" {
	default="/home/ubuntu/terraform/terraform-variables/filename1_automated.txt"
}

variable "var2" {}


variable "content_map"{
type=map

default={
	"index1" ="Atif Sajjad"
	"index2" ="Asad Sajjad"
	}
}

variable "content_list"{
type=list
default=["content1","content2"]

}

variable "aws_ec2_object"{
type =object({
	name=string
	instances= number
	keys=list(string)
	ami=string

})

default = {
	name="ec2-terraform"
	instances=5
	keys=["key1.pem","key2.pem"]
	ami="alsjdnjsnd@ubuntujasndjsnad.com"
}
}

variable "ssh"{}
variable "instances"{}
