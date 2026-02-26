# ec2 deployment instead

## backend
cd backend;
sh ./init.sh;
sh ./docker.build.production.ec2.debian.sh;
sudo docker stop chat_app-ruby-vue-backend;
sudo docker rm chat_app-ruby-vue-backend;
sh ./docker.run.production.ec2.debian.sh;

## frontend
cd ../frontend;
sh ./docker.build.production.ec2.debian.sh;
sudo docker stop chat_app-ruby-vue-frontend;
sudo docker rm chat_app-ruby-vue-frontend;
sh ./docker.run.production.ec2.debian.sh;

## server: etc
cd ../etc;
sudo cp ./nginx/conf.d/chatapp.conf /etc/nginx/conf.d;
sudo nginx -t;
sudo systemctl restart nginx;
