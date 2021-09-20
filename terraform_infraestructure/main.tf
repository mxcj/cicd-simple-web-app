#Terraform provider requirements
terraform {
  required_version = "~> 1.0.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"  
    }
  }
  backend "s3" {
        bucket = "ci-cd-pipeline-terraform"
        encrypt = true
        key = "terraform.tfstate"
        region = "us-west-2"
    }
}
#Provider configurations
provider "aws" {
    region = var.aws_region
}

#------------------------------------------------------------------------------
# EC2 VPC
#------------------------------------------------------------------------------

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_az
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    terraform = "true"
    environment = "dev"
  }
}

#------------------------------------------------------------------------------
# ECS Cluster
#------------------------------------------------------------------------------
module "ecs-cluster" {
  source  = "cn-terraform/ecs-cluster/aws"
  version = "1.0.7"
  # source  = "../terraform-aws-ecs-cluster"

  name = var.cluser_name
  tags = var.tags
}

#------------------------------------------------------------------------------
# ECS Task Definition
#------------------------------------------------------------------------------
module "td" {
  source  = "cn-terraform/ecs-fargate-task-definition/aws"
  version = "1.0.23"
  # source  = "../terraform-aws-ecs-fargate-task-definition"

  name_prefix                  = var.td_name
  container_name               = var.container_name
  container_image              = var.container_image
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  container_definition         = var.container_definition
  port_mappings                = var.port_mappings
  healthcheck                  = var.healthcheck
  container_cpu                = var.container_cpu
  essential                    = var.essential
  entrypoint                   = var.entrypoint
  command                      = var.command
  working_directory            = var.working_directory
  environment                  = var.environment
  extra_hosts                  = var.extra_hosts
  map_environment              = var.map_environment
  environment_files            = var.environment_files
  secrets                      = var.secrets
  readonly_root_filesystem     = var.readonly_root_filesystem
  linux_parameters             = var.linux_parameters
  log_configuration            = var.log_configuration
  firelens_configuration       = var.firelens_configuration
  mount_points                 = var.mount_points
  dns_servers                  = var.dns_servers
  dns_search_domains           = var.dns_search_domains
  ulimits                      = var.ulimits
  repository_credentials       = var.repository_credentials
  volumes_from                 = var.volumes_from
  links                        = var.links
  user                         = var.user
  container_depends_on         = var.container_depends_on
  docker_labels                = var.docker_labels
  start_timeout                = var.start_timeout
  stop_timeout                 = var.stop_timeout
  privileged                   = var.privileged
  system_controls              = var.system_controls
  hostname                     = var.ecs_hostname
  disable_networking           = var.disable_networking
  interactive                  = var.interactive
  pseudo_terminal              = var.pseudo_terminal
  docker_security_options      = var.docker_security_options

  permissions_boundary                    = var.permissions_boundary
  placement_constraints                   = var.placement_constraints_task_definition
  proxy_configuration                     = var.proxy_configuration
  ecs_task_execution_role_custom_policies = var.ecs_task_execution_role_custom_policies
  volumes                                 = var.volumes

  tags = var.tags
}

# #------------------------------------------------------------------------------
# # ECS Service
# #------------------------------------------------------------------------------
 module "ecs-fargate-service" {
  source  = "cn-terraform/ecs-fargate-service/aws"
  version = "2.0.15"
  # source  = "../terraform-aws-ecs-fargate-service"

  name_prefix = var.service_name
  vpc_id      = module.vpc.vpc_id

  ecs_cluster_arn                    = module.ecs-cluster.aws_ecs_cluster_cluster_arn
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  ordered_placement_strategy         = var.ordered_placement_strategy
  placement_constraints              = var.ecs_service_placement_constraints
  platform_version                   = var.platform_version
  propagate_tags                     = var.propagate_tags
  service_registries                 = var.service_registries
  task_definition_arn                = module.td.aws_ecs_task_definition_td_arn

  # Network configuration block
  public_subnets   = module.vpc.public_subnets
  private_subnets  = module.vpc.private_subnets
  security_groups  = var.ecs_service_security_groups
  assign_public_ip = var.assign_public_ip

  # ECS Service Load Balancer block
  container_name = var.container_name

  # ECS Autoscaling
  enable_autoscaling = var.enable_autoscaling
  ecs_cluster_name   = module.ecs-cluster.aws_ecs_cluster_cluster_name

  # Application Load Balancer
  lb_internal                         = var.lb_internal
  lb_security_groups                  = var.lb_security_groups
  lb_drop_invalid_header_fields       = var.lb_drop_invalid_header_fields
  lb_idle_timeout                     = var.lb_idle_timeout
  lb_enable_deletion_protection       = var.lb_enable_deletion_protection
  lb_enable_cross_zone_load_balancing = var.lb_enable_cross_zone_load_balancing
  lb_enable_http2                     = var.lb_enable_http2
  lb_ip_address_type                  = var.lb_ip_address_type

  # Access Control to Application Load Balancer
  lb_http_ports                    = var.lb_http_ports
  lb_http_ingress_cidr_blocks      = var.lb_http_ingress_cidr_blocks
  lb_http_ingress_prefix_list_ids  = var.lb_http_ingress_prefix_list_ids
  lb_https_ports                   = var.lb_https_ports
  lb_https_ingress_cidr_blocks     = var.lb_https_ingress_cidr_blocks
  lb_https_ingress_prefix_list_ids = var.lb_https_ingress_prefix_list_ids

  # Target Groups
  lb_deregistration_delay                          = var.lb_deregistration_delay
  lb_slow_start                                    = var.lb_slow_start
  lb_load_balancing_algorithm_type                 = var.lb_load_balancing_algorithm_type
  lb_stickiness                                    = var.lb_stickiness
  lb_target_group_health_check_enabled             = var.lb_target_group_health_check_enabled
  lb_target_group_health_check_interval            = var.lb_target_group_health_check_interval
  lb_target_group_health_check_path                = var.lb_target_group_health_check_path
  lb_target_group_health_check_timeout             = var.lb_target_group_health_check_timeout
  lb_target_group_health_check_healthy_threshold   = var.lb_target_group_health_check_healthy_threshold
  lb_target_group_health_check_unhealthy_threshold = var.lb_target_group_health_check_unhealthy_threshold
  lb_target_group_health_check_matcher             = var.lb_target_group_health_check_matcher

  # Certificates
  default_certificate_arn                         = var.default_certificate_arn
  ssl_policy                                      = var.ssl_policy
  additional_certificates_arn_for_https_listeners = var.additional_certificates_arn_for_https_listeners

  # Optional tags
  tags = var.tags
 }
