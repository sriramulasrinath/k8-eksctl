variable "zone_name" {
  default = "srinath.online"
}
variable "volume_tags" {
  default = {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = false
  }
}