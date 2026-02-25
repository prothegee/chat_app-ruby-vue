sudo docker run -d \
    --name chat_app-ruby-vue-backend \
    -e RAILS_ENV=production \
    -e SECRET_KEY_BASE=a805b73f34efb8b5eb75986543e710f67d3b43b62e403bf43fbe07c127c5d59bcad9cfd5f953724770130b6d93d79845bd8950a18fd005b7f35619f497fabf1b \
    -p 10000:10000 \
    chat_app-ruby-vue-backend:latest;

