resource "aws_default_vpc" "default_vpc" {}

data "aws_subnet_ids" "default_subnet_ids" {
  vpc_id = aws_default_vpc.default_vpc.id
}

data "aws_availability_zones" "region_availability_zones" {

}
