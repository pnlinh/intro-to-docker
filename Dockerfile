FROM ubuntu:14.04
MAINTAINER Education Team at Docker <education@docker.com>

ENV VERSION 0.0.1

RUN apt-get update
RUN apt-get install -y curl wget git ruby ruby-dev libxml2-dev libxslt-dev build-essential
RUN git clone https://github.com/puppetlabs/showoff.git
RUN cd showoff && gem build showoff.gemspec && gem install --no-rdoc --no-ri ./showoff-*.gem

RUN mkdir -p /slides

ADD . /slides
WORKDIR /slides

CMD [ "showoff", "serve" ]
