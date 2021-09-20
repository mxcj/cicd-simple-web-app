aws_region = "us-west-2"
vpc_name = "vpc_simple_web"
vpc_cidr = "10.0.0.0/16"
vpc_az = ["us-west-2a", "us-west-2b", "us-west-2c"]
vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
vpc_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
cluser_name = "cluster-simple-server"
tags = {
        terraform = "true"
    }
td_name = "simple-server"
container_name = "simple-server"
container_image = "224234462137.dkr.ecr.us-west-2.amazonaws.com/simple-web-app:latest"
container_memory = 2048
container_memory_reservation = 2048
container_cpu = 1024
port_mappings = [{
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
    }]
log_configuration = {
        logDriver = "awslogs"
        options   = {
                awslogs-group = "/ecs/simple-server"
                awslogs-region = "us-west-2"
                awslogs-stream-prefix = "ecs"
            }
    }
desired_count = 1
enable_ecs_managed_tags = true
platform_version = "LATEST"

service_name = "service-simple-server-service"
assign_public_ip = true
enable_autoscaling = true
lb_internal = false
#ecs_service_security_groups = null
lb_enable_deletion_protection = true
lb_enable_http2 = false
lb_ip_address_type = "ipv4"
lb_http_ports = {
  default_http = {
    listener_port = 3000
    target_group_port = 3000
    type = "forward"
  }
}
lb_http_ingress_cidr_blocks = ["0.0.0.0/0"]

lb_https_ports = {}
lb_https_ingress_cidr_blocks = []
lb_target_group_health_check_enabled = true
lb_target_group_health_check_interval = 30
lb_target_group_health_check_path = "/services/status"
lb_target_group_health_check_timeout = 5
lb_target_group_health_check_healthy_threshold = 3
lb_target_group_health_check_unhealthy_threshold = 3
lb_target_group_health_check_matcher = 200

artifacts_bucket_name = "cicd-simple-web-artifacts"
nodejs_project_repository_name = "mxcj/cicd-simple-web-app"
codestar_connector_credentials = "arn:aws:codestar-connections:us-west-2:224234462137:connection/f1bac62a-c5b5-4bff-91fb-47c95f2a54a3"
