# Creación de la VPC
resource "aws_vpc" "vpc_cloud_romo" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags={
        Name = "Cloud_romo_vpc"
    }
}

# Creación de la subred pública 1
resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.vpc_cloud_romo.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "Public1"
    }
}

# Creación de la subred pública 2
resource "aws_subnet" "public_2" {
    vpc_id     = aws_vpc.vpc_cloud_romo.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
        Name = "Public2"
    }
}

# Creación de la subred privada 1
resource "aws_subnet" "private_1" {
    vpc_id     = aws_vpc.vpc_cloud_romo.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = true
    
    tags = {
        Name = "Private1"
    }
}

# Creación de la subred privada 2
resource "aws_subnet" "private_2" {
    vpc_id     = aws_vpc.vpc_cloud_romo.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1d"
    map_public_ip_on_launch = true
    
    tags = {
        Name = "Private2"
    }
}

# Creación de Internet Gateway
resource "aws_internet_gateway" "igw_romo_cloud" {
    vpc_id = aws_vpc.vpc_cloud_romo.id
    
    tags = {
        Name = "Internet_GateWay"
    }
}

# Creación de la tabla de enrutamiento pública
resource "aws_route_table" "route_table_romo_public" {
    vpc_id = aws_vpc.vpc_cloud_romo.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_romo_cloud.id
    }
    
    tags = {
        Name = "Tabla_enrutamiento_romo_Public"
    }
}

# Creación de la tabla de enrutamiento privada
resource "aws_route_table" "route_table_romo_private" {
    vpc_id = aws_vpc.vpc_cloud_romo.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_romo_cloud.id
    }
    
    tags = {
        Name = "Tabla_enrutamiento_romo_Private"
    }
}

# Asociaciones de tablas de enrutamiento
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

# Creación del Security Group para RDS con acceso público
resource "aws_security_group" "rds_sg" {
    vpc_id = aws_vpc.vpc_cloud_romo.id
    name        = "allow_rds_public_access"
    description = "Permitir acceso publico a la base de datos RDS"
    
    ingress {
        from_port   = 3306        # Puerto MySQL
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Permitir desde cualquier IP
        }
        
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]  # Permitir cualquier tráfico de salida
        }

    tags = {
        Name = "rds_sg"
        }
}

# Creación de la instancia de RDS MySQL
resource "aws_db_instance" "mysql_romo" {
    allocated_storage    = 20                       # Tamaño en GB
    engine               = "mysql"                  # Motor MySQL
    engine_version       = "8.0"                    # Versión del motor
    instance_class       = "db.t3.micro"            # Clase de instancia
    db_name              = "mysql_romo"             # Nombre de la base de datos
    username             = "admin"                  # Usuario administrador
    password             = "Danielromo2307"         # Contraseña (asegúrate de usar variables seguras)
    publicly_accessible  = true                     # Hacer que la DB sea accesible públicamente
    skip_final_snapshot  = true                     # Evitar snapshot final al eliminar la DB
    vpc_security_group_ids = [aws_security_group.rds_sg.id]
    db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
    identifier           = "my-mysql-db-instance"

    tags = {
    Name = "MySQL_RDS_DB_ROMO"
    }
}

# Creación del grupo de subredes para RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
    name       = "rds_subnet_group"
    subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]

    tags = {
    Name = "rds_subnet_group"
    }
}

# Output para mostrar el endpoint de la base de datos
#output "rds_endpoint" {
#    value = aws_db_instance.my_mysql_db.endpoint
#}
