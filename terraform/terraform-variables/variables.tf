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
