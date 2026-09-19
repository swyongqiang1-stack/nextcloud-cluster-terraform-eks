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


variable "cluster_name" {
  type = string
}


variable "region"{
    type = string
}

variable "nextcloud_namespace"{
    type = string
}

variable "kube_system_namespace"{
    type = string
}


variable "external_secrets_namespace"{
    type = string
}


variable "domain_name" {
    type = string
}