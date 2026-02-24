variable "vpc_cidr" {
  description = "CIDR block du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "nom_du_vpc" {
    type = string
    default = "vpc_trop_cool_de_moi"
}


variable "sub_priv1" {
    type = string
    default = "10.0.21.0/24"
}

variable "sub_priv2" {
    type = string
    default = "10.0.22.0/24"
}

variable "sub_pub1" {
    type = string
    default = "10.0.11.0/24"
}

variable "sub_pub2" {
    type = string
    default = "10.0.12.0/24"
}