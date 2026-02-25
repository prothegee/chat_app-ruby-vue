aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 058040409591.dkr.ecr.ap-southeast-1.amazonaws.com;

podman build -t chat-app-ruby-vue/frontend .;

podman tag chat-app-ruby-vue/frontend:latest 058040409591.dkr.ecr.ap-southeast-1.amazonaws.com/chat-app-ruby-vue/frontend:latest;

podman push 058040409591.dkr.ecr.ap-southeast-1.amazonaws.com/chat-app-ruby-vue/frontend:latest;
