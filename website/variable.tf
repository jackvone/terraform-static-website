variable "domain" {
  description = "Domain name for the website (e.g., example.com). If not using real DNS, use a placeholder like 'mygame.local'."
  type        = string
  default     = "myquote.local"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
