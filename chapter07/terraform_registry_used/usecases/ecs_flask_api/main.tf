# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = "${var.stage}-flask-api-tf"

  fargate_capacity_providers = {
    FARGATE = {}
  }
}

module "ecs_task_definition" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  family                   = "${var.stage}-flask-api-tf"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  skip_destroy             = true

  container_definitions = {
    flask_api = {
      name      = "flask-api"
      essential = true
      image     = "${data.aws_ecr_repository.flask_api.repository_url}:latest"
      port_mappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.flask_api.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "flask-api"
        }
      }
      secrets = [
        {
          name      = "CORRECT_ANSWER"
          valueFrom = data.aws_ssm_parameter.flask_api_correct_answer.arn
        },
      ]
    }
  }
}

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name        = "flask-api-tf"
  cluster_arn = module.ecs_cluster.arn

  desired_count                     = 0
  enable_execute_command            = true
  health_check_grace_period_seconds = 60
  launch_type                       = "FARGATE"

  deployment_circuit_breaker = {
    enable   = true
    rollback = false
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["flask_api_tf"].arn
      container_name   = "flask-api" # local.container_definitions.flask_api.name
      container_port   = 5000
    }
  }

  subnet_ids = data.aws_subnets.public.ids

  security_group_rules = {
    alb_ingress = {
      type                     = "ingress"
      from_port                = 5000
      to_port                  = 5000
      protocol                 = "tcp"
      source_security_group_id = module.alb.security_group_id
    }
    egress = {
      type      = "egress"
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
      cidr_ipv4 = "0.0.0.0/0"
    }
  }
}

# すでに作成した SSM パラメータストアについてのデータソース
data "aws_ssm_parameter" "flask_api_correct_answer" {
  name = "/flask-api-tf/${var.stage}/correct_answer"
}

# リージョンの問い合わせ
data "aws_region" "current" {}

# ECR リポジトリの問い合わせ
data "aws_ecr_repository" "flask_api" {
  name = "${var.stage}-flask-api-tf"
}

# ECS タスクのロググループ
resource "aws_cloudwatch_log_group" "flask_api" {
  name              = "/ecs/${var.stage}-flask-api-tf"
  retention_in_days = 7
}

locals {
  vpc_name = "${var.stage}-vpc-tf"
}

# データソースによる VPC の情報の照会
# Name というタグの値で指定
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

# データソースによるサブネットの情報の照会
# Name というタグの値で指定
data "aws_subnets" "public" {
  filter {
    name = "tag:Name"
    values = [
      "${local.vpc_name}-public-ap-northeast-1a",
      "${local.vpc_name}-public-ap-northeast-1c",
      "${local.vpc_name}-public-ap-northeast-1d",
    ]
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.11.2" # NOTE: terraform.tf の記載バージョン >=5.72.1 で使用できる最新のバージョン

  name               = "${var.stage}-flask-api-alb-tf"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.public.ids

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    ecs_fargate = {
      from_port   = 5000
      to_port     = 5000
      ip_protocol = "tcp"
      # ECS Fargate インスタンス用のセキュリティグループがアタッチされた ENI への通信を許可
      referenced_security_group_id = module.ecs_service.security_group_id
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "flask_api_tf"
      }
    }
  }

  target_groups = {
    flask_api_tf = {
      backend_protocol = "HTTP"
      backend_port     = 5000
      target_type      = "ip"
      vpc_id           = data.aws_vpc.this.id

      health_check = {
        enabled  = true
        path     = "/health"
        protocol = "HTTP"
        matcher  = "200"
        interval = 10
      }
    }
  }
}
