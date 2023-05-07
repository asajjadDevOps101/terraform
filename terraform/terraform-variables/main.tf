resource "local_file" "test_file1"{
	filename="/home/ubuntu/terraform/terraform-variables/test_file1.txt"
	content = " This file is test1_file"
}
resource "local_file" "test_file2_var"{
	filename=var.filename1
	content="this is file 2"
}
output "var2"{
	value=var.var2
}
output "variables_map"{
	value=var.content_map["index1"]
}
output "varibale_list_map"{

	value=var.content_list[1]

}

output "ec2_ami"{
	value=var.aws_ec2_object
}

output "json_var_output"{
	value=var.instances
}
