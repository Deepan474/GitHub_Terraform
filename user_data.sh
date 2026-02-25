#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1
        
yum update -y
yum install -y python3 git nginx
        
# Clone as ec2-user
sudo -u ec2-user git clone https://github.com/Deepan474/Python_Demo.git /home/ec2-user/Python_Demo
        
cd /home/ec2-user/Python_Demo
        
python3 -m venv venv
        
/home/ec2-user/Python_Demo/venv/bin/pip install --upgrade pip
/home/ec2-user/Python_Demo/venv/bin/pip install -r requirements.txt
/home/ec2-user/Python_Demo/venv/bin/pip install gunicorn
        
# Create a systemd service file for Gunicorn
cat <<SERVICE > /etc/systemd/system/gunicorn.service
[Unit]
Description=Gunicorn instance to serve Flask app
After=network.target  

[Service]
User=ec2-user 
WorkingDirectory=/home/ec2-user/Python_Demo
ExecStart=/home/ec2-user/Python_Demo/venv/bin/gunicorn -w 3 -b 0.0.0.0:5000 main:app
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

# Reload systemd to recognize the new service, enable it to start on boot, and start it immediately
systemctl daemon-reload
systemctl enable gunicorn
systemctl start gunicorn

# Configure Nginx as a reverse proxy
cat <<NGINX > /etc/nginx/conf.d/flask_app.conf
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr; 
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
NGINX

# Start Nginx
systemctl enable nginx
systemctl restart nginx