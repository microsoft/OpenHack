# See here for image contents: https://github.com/microsoft/vscode-dev-containers/blob/v0.200.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use hirsuite or bionic on local arm64/Apple Silicon): hirsute, focal, bionic
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ARG USERNAME=vscode
ARG USER_HOME=/home/$USERNAME

# Setup toolset
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends azure-cli gh

# Setup bicep & ado extension for root
RUN az bicep install \
    && az extension add --name azure-devops
RUN chsh -s /bin/bash

# Cleanup apt
RUN apt-get autoremove -y \
    && apt-get clean -y 

# Paths and user set up
WORKDIR $USER_HOME
USER $USERNAME

# Setup bicep & ado extension for user
RUN az bicep install \
    && az extension add --name azure-devops