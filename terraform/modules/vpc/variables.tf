variable "cidr_block" {
  type = string
}

variable "public_subnet" {
  type = list(string)
}

variable "private_subnet" {
  type = list(string)
}

variable "az" {
  type = list(string)
}

variable "az_number" {
  type = number
}
