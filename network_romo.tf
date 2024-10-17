#Creacion de la VPC
resource "aws_vpc" "vpc_cloud_romo" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags={
        Name = "Cloud_romo_vpc"
    }
    
}

#Creacion de la subred publica 1
resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.vpc_cloud_romo.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "Public1"
    }
}


#Creacion de la subred publica 2
resource "aws_subnet" "public_2" {
    vpc_id     = aws_vpc.vpc_cloud_romo.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    
    tags = {
        Name = "Public2"
    }
}
#Creacion de la subred privada 1
resource "aws_subnet" "private_1" {
    vpc_id     = aws_vpc.vpc_cloud_romo.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = true
    
    tags = {
        Name = "Private1"
        }
}
#Creacion de la subred privada 2
resource "aws_subnet" "private_2" {
    vpc_id     = aws_vpc.vpc_cloud_romo.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1d"
    map_public_ip_on_launch = true
    
    tags = {
        Name = "Private2"
        }
}

#Creacion de Internet Gateway
resource "aws_internet_gateway" "igw_romo_cloud" {
    vpc_id = aws_vpc.vpc_cloud_romo.id
    
    tags = {
        Name = "Internet_GateWay"
        }
}

#Creacion de la tabla de enrrutamiento
resource "aws_route_table" "route_table_romo_public" {
    vpc_id = aws_vpc.vpc_cloud_romo.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_romo_cloud.id
        
        }
        
        tags = {
            Name = "Tabla_enrrutmiento_romo"
            }
}
#Creacion de la tabla de enrrutamiento
resource "aws_route_table" "route_table_romo_private" {
    vpc_id = aws_vpc.vpc_cloud_romo.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_romo_cloud.id
        
        }
        
        tags = {
            Name = "Tabla_enrrutmiento_romo"
            }
}

#Asociasion de la tabla de enrrutamiento con las subredes
resource "aws_route_table_association" "asociacion_publica1" {
    subnet_id = aws_subnet.public_1.id
    route_table_id = aws_route_table.route_table_romo_public.id
}

resource "aws_route_table_association" "asociacion_publica2" {
    subnet_id = aws_subnet.public_2.id
    route_table_id = aws_route_table.route_table_romo_public.id  
}

resource "aws_route_table_association" "asociacion_privada1" {
    subnet_id = aws_subnet.private_1.id
    route_table_id = aws_route_table.route_table_romo_private.id  
}

resource "aws_route_table_association" "asociacion_privada2" {
    subnet_id = aws_subnet.private_2.id
    route_table_id = aws_route_table.route_table_romo_private.id  
}