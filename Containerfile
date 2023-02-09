# Containerfile for KPA project to be used in CI
FROM quay.io/ansible/ansible-core

WORKDIR /kpa

# Install yamllint
RUN pip3 install yamllint ansible-lint

# Install mdl (Mardownlinter)
RUN dnf -y module reset ruby
RUN dnf -y module enable ruby:2.7
RUN dnf -y install rubygems
RUN gem install mdl

# Install Marp
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash -
RUN dnf -y --enablerepo epel install chromium nodejs
RUN npm install -g @marp-team/marp-cli

# Install KPA repository (busting the cache)
ARG CACHEBUST=1
RUN git clone https://github.com/mmul-it/kpa .
RUN ansible-galaxy install \
      -r playbooks/roles/requirements.yml \
      --roles-path ./playbooks/roles
