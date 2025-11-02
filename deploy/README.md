# Build & run docker
sudo docker build -t flight-delay-api .
sudo docker run -d --name flight-api -p 8000:8000 flight-delay-api

# Check container & logs
sudo docker ps
sudo docker logs -f flight-api

# Nginx check & restart
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager

# Stop / start service
sudo docker stop flight-api
sudo systemctl stop nginx

# Resume
sudo systemctl start nginx
sudo docker start flight-api

# SSH (on laptop)
ssh -i "flight-api-key.pem" ec2-user@<PUBLIC_IP>

# Copy frontend to nginx directory
sudo cp fe/index.html /usr/share/nginx/html/index.html
sudo chown root:root /usr/share/nginx/html/index.html
sudo chmod 644 /usr/share/nginx/html/index.html
sudo nginx -t && sudo systemctl restart nginx
