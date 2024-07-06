module "workstation" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "workstation"
  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-00d8e884e38dae954"]
  volume_tags            = var.volume_tags
  subnet_id              = "subnet-09e5fbac6203f2585"
  ami                    = data.aws_ami.ami_info.id

  user_data = file("workstation.sh")

    
  tags = {
        Name = "workstation"
    }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "workstation"
      type    = "A"
      ttl     = 1
      records = [
        module.workstation.public_ip
      ]
    },
  ]
}


