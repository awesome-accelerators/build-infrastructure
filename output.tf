output "jenkins_public_dns" {
  value = "[ http://${aws_instance.jenkins_master.public_dns}:8080]"
}