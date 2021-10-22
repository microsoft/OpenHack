# Build application
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
WORKDIR /src
ADD ./scripts/tools/Deploy/src/Deploy/ /src/
RUN dotnet publish -c Release -r linux-musl-x64 --self-contained true --output /out

# Build deployment environment
FROM mcr.microsoft.com/azure-cli AS deploy-env

# Install Bicep
RUN az bicep Install

# Install Git CLI
RUN apk add git

# Copy deploy script from build-env
COPY --from=build-env /out /deploy
RUN chmod +x /deploy/Deploy

# Copy source files
ADD ./scripts/source/ /source/repos/
ADD ./scripts/tools/AzDevOps/ /source/azdo/
ADD ./scripts/tools/Deploy/deploy.sh /deploy/
RUN chmod +x /deploy/deploy.sh

# Set the entrypoint
ENTRYPOINT ["/deploy/deploy.sh"]