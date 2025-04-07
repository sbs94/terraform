# ALB 생성
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.public_sg.id]
  subnets           = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "my-alb"
  }
}

# ALB Target Group 생성
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "my-target-group"
  }
}

# ALB Listener 생성
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
    }
  }
}

# EC2 인스턴스를 ALB Target Group에 등록
resource "aws_lb_target_group_attachment" "my_attachment_server1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.public1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my_attachment_server2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.public2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my_attachment_server3" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.public3.id
  port             = 80
}

# -------------------------------------------------------------------------------------------------------------------
#[코드 설명]
#---
#1. ALB 생성 (aws_lb)
#- aws_lb 리소스를 사용하여 Application Load Balancer를 생성합니다.
#- internal = false로 외부 접근이 가능한 ALB로 설정합니다.
#- subnets는 ALB가 배포될 두 개의 퍼블릭 서브넷을 지정합니다.
#
#2. Target Group 생성 (aws_lb_target_group)
#- aws_lb_target_group 리소스를 사용하여 ALB의 Target Group을 설정합니다. 
#  ALB는 Target Group에 등록된 EC2 인스턴스로 트래픽을 분배합니다.
#- health_check 설정을 통해 EC2 인스턴스의 상태를 모니터링합니다.
#
#3. Listener 생성 (aws_lb_listener)
#- aws_lb_listener 리소스를 사용하여 ALB의 HTTP 리스너를 설정합니다.
#- default_action으로는 요청을 처리할 기본 동작을 설정합니다. (예: 고정된 응답을 반환하는 방식)
#
#4. Target Group Attachment
#- aws_lb_target_group_attachment 리소스를 사용하여 각 EC2 인스턴스를 ALB의 Target Group에 등록합니다.
#- 이 예시에서는 3개의 EC2 인스턴스를 ALB의 Target Group에 등록하고 있습니다.
