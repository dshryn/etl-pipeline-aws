set -e

sudo systemctl start docker

# (re)build if dockerfile present
cd ~
if [ -f Dockerfile ]; then
  sudo docker build -t flight-delay-api . || true
fi

# remove old container
if sudo docker ps -a --format '{{.Names}}' | grep -q '^flight-api$'; then
  sudo docker rm -f flight-api || true
fi

# run container
sudo docker run -d --name flight-api -p 8000:8000 flight-delay-api

# restart nginx
sudo nginx -t && sudo systemctl restart nginx

# show status
sudo docker ps --filter name=flight-api --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
sudo systemctl status nginx --no-pager | sed -n '1,8p'
sudo docker logs --tail 50 flight-api || true
echo "DONE"
