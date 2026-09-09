variable "public_subnet" {
    type = list(string)
}

variable "private_subnet" {
    type = list(string)
}

variable "cidr_block"{
    type = string
}

variable "AZ" {
    type = list(string)
}