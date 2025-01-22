# Dockerfile for KPA project to be used in CI

# Start from kpa-marp-pandoc
FROM ghcr.io/mmul-it/kpa-marp-pandoc:v1.2.0

# Create workdir path
RUN mkdir /kpa
RUN mkdir /kpa/output
RUN mkdir /kpa/projects

# Copy local files into container
COPY kpa.sh /kpa/
COPY .ansible-lint .mdl* .yamllint /kpa/
COPY playbooks /kpa/playbooks
COPY projects/example /kpa/projects/example

# Add user and group for the kpa unprivileged user
RUN groupadd --gid 1000 kpa
RUN useradd --no-log-init -d /kpa --uid 1000 -g kpa kpa
RUN chown -R kpa: /kpa

# Set /kpa as workdir
WORKDIR /kpa

# Set user to  kpa
USER kpa

# Install KPA repository
RUN ansible-galaxy install \
      -r playbooks/roles/requirements.yml \
      --roles-path ./playbooks/roles

# Define CMD
ENTRYPOINT ["/kpa/kpa.sh"]
