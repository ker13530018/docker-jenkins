FROM jenkins/jenkins:lts

RUN python --version && uname -a && pwd && echo $HOME

USER root

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl \
   && chmod +x ./kubectl \
   && mv ./kubectl /usr/local/bin/kubectl 

RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
   && unzip awscli-bundle.zip \ 
   && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

RUN aws configure set aws_access_key_id "" \
   && aws configure set aws_secret_access_key ""/YBQBATrYEG0 \
   && aws configure set region ap-southeast-1 \
   &&  aws configure set output json

RUN aws --region ap-southeast-1 eks update-kubeconfig  \
   --name edoc-playground-1

RUN kubectl get nodes

RUN apt-get update -qq \
   && apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

RUN apt-get update  -qq \
   && apt-get install docker-ce=17.12.1~ce-0~debian -y

RUN curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

RUN chmod +x /usr/local/bin/docker-compose

RUN usermod -aG docker jenkins
