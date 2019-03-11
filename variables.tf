variable "region" {
  default = "eu-west-3"
}

variable "amis" {
  description = "Which AMI to spawn based on region."

  default = {
    eu-west-3 = "ami-0dd7e7ed60da8fb83"
  }
}

variable "private_key_file" {
  description = "Which Private Secret Key to use for acceesing infrastructure based on region (without .pem extension)"
  default = {
    eu-west-3 = ".secrets/paris-secret"
  }
}

variable "jenkins_master_instance_type" {
  description = "Jenkins Master Instance Type"
  default     = "t2.micro"
}

variable "jenkins_plugins" {
  description = "Jenkins Plugins that will be installed automatically when the jenkins master will be provisioned."
  default = ["aws-credentials", "git", "jira", "cloudbees-folder", "timestamper", "pipeline-stage-view", "workflow-step-api", "workflow-aggregator", "mailer", "blueocean", "ssh-slaves", "credentials-binding", ""]
}
