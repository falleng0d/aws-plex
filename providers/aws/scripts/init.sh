#!/bin/bash
# see https://github.com/nginx-proxy/nginx-proxy
silent() {
	sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -o Dpkg::Use-Pty=0 "$@" < /dev/null;
}

silent update
echo [$(date -u +"%Y/%m/%d %H:%M:%S")] silent updated
silent upgrade
echo [$(date -u +"%Y/%m/%d %H:%M:%S")] silent upgraded

wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
echo [$(date -u +"%Y/%m/%d %H:%M:%S")] installed amazon-cloudwatch-agent.deb

sudo cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<- EOM
{
  "agent": {
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "${GROUP}",
            "log_stream_name": "cloud-init-output"
          },
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "${GROUP}",
            "log_stream_name": "user-data"
          }
        ]
      }
    }
  }
}
EOM

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
	-a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
echo [$(date -u +"%Y/%m/%d %H:%M:%S")] tried to initialize cloudwatch

echo [$(date -u +"%Y/%m/%d %H:%M:%S")] Initialized Instance
