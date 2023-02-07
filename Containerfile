# Containerfile for KPA project to be used in CI
FROM quay.io/ansible/ansible-core

WORKDIR /kpa

# YAMLLINT
RUN pip3 install yamllint ansible-lint

# KPA
RUN git clone https://github.com/mmul-it/kpa .
RUN ansible-galaxy install \
      -r playbooks/roles/requirements.yml \
      --roles-path ./playbooks/roles

# Marp
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash -
RUN dnf -y --enablerepo epel install chromium nodejs
RUN npm install -g @marp-team/marp-cli
