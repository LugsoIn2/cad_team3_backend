
data "archive_file" "zipFile" {
  type        = "zip"
  output_path = "../out/cad_team3_backend.zip"
  source_dir = "../cad_team3_backend"

}

resource "aws_s3_bucket" "dist_bucket" {
  bucket = "cad-team3-bucket-elb-dist"
  acl    = "private"
}

resource "aws_s3_bucket_object" "dist_item" {
  key    = "dist-${uuid()}.zip"
  bucket = "${aws_s3_bucket.dist_bucket.id}"
  source = "../out/cad_team3_backend.zip"
}

resource "aws_elastic_beanstalk_application" "cad-team3-tf-backend" {
  name        = "tf-backend"
  description = "tf-backend-desc"
}

resource "aws_elastic_beanstalk_application_version" "cad-team3-tf-backend-version" {
  name        = "cad-team3-backend-env-${uuid()}"
  application = aws_elastic_beanstalk_application.cad-team3-tf-backend.name
  description = "application version created by terraform"
  bucket      = "${aws_s3_bucket.dist_bucket.id}"
  key         = "${aws_s3_bucket_object.dist_item.id}"
}

resource "aws_elastic_beanstalk_environment" "cad-team3-tf-backend-env" {
  name                = "cad-team3-tf-backend-env"
  application         = aws_elastic_beanstalk_application.cad-team3-tf-backend.name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.1 running Python 3.8"
  tier                = "WebServer"
  version_label       = aws_elastic_beanstalk_application_version.cad-team3-tf-backend-version.name

  setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "IamInstanceProfile"
      value = "aws-elasticbeanstalk-ec2-role"
  }
}