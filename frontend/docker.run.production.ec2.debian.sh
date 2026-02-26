sudo docker run -d \
    --name chat_app-ruby-vue-frontend \
    --restart always \
    -p 10001:10001 \
    chat_app-ruby-vue-frontend:latest;
