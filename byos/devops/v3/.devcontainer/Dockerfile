FROM ubuntu:focal

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV ACCEPT_EULA=Y
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Configure apt, install base packages, SDKs & tools
RUN apt-get update \
    && apt-get install -y git less procps lsb-release curl wget ca-certificates apt-transport-https gnupg software-properties-common \
    && curl -sL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list -o /etc/apt/sources.list.d/microsoft-prod.list \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list > /dev/null \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y mssql-tools unixodbc-dev azure-cli maven dotnet-sdk-3.1 snapd nodejs build-essential docker-ce docker-ce-cli containerd.io terraform python3 python3-pip powershell jq unzip zip gh \
    && az bicep install \
    && az extension add --name azure-devops
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/bash.bashrc
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /etc/bash.bashrc

# Golang
WORKDIR /tmp
RUN curl -fsS https://dl.google.com/go/go1.16.8.linux-amd64.tar.gz -o golang.tar.gz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf golang.tar.gz
ENV GO111MODULE=on
ENV CGO_ENABLED=0
RUN echo 'export PATH="$PATH:/usr/local/go/bin"' >> /etc/bash.bashrc

# Create the user - https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && groupadd docker || true \
    && usermod -aG docker $USERNAME

# Cleanup apt
RUN apt-get autoremove -y \
    && apt-get clean -y 

# Paths and user set up
WORKDIR /home/$USERNAME
USER $USERNAME
RUN az bicep install \
    && az extension add --name azure-devops
