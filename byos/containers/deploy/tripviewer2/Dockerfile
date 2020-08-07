# 
# builder - first stage to build the application
# 
FROM mcr.microsoft.com/dotnet/core/sdk:2.1 AS build-env
WORKDIR /src

COPY . .
RUN dotnet publish "web/TripViewer.csproj" -c Release -o /publish

# ------------------------------------------------

# 
# runtime - build final runtime image
# 
FROM mcr.microsoft.com/dotnet/core/aspnet:2.1-alpine

ARG IMAGE_CREATE_DATE
ARG IMAGE_VERSION
ARG IMAGE_SOURCE_REVISION


ENV TRIPS_API_ENDPOINT="http://endpoint" \
    USERPROFILE_API_ENDPOINT="http://endpoint" \
    WCF_ENDPOINT="changeme"

# Metadata as defined in OCI image spec annotations - https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="TripInsights - TripViewer Site" \
      org.opencontainers.image.description="The TripViewer website is a user portal for the TripInsights application." \
      org.opencontainers.image.created=$IMAGE_CREATE_DATE \
      org.opencontainers.image.version=$IMAGE_VERSION \
      org.opencontainers.image.authors="Microsoft" \
      org.opencontainers.image.url="https://github.com/Azure-Samples/openhack-containers/blob/master/dockerfiles/Dockerfile_1" \
      org.opencontainers.image.documentation="https://github.com/Azure-Samples/openhack-containers/blob/master/src/tripviewer/README.md" \
      org.opencontainers.image.vendor="Microsoft" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/Azure-Samples/openhack-containers.git" \
      org.opencontainers.image.revision=$IMAGE_SOURCE_REVISION 

# add debugging utilities
RUN apk --no-cache add \
  curl \
  ca-certificates \
  jq \
  less \
  vim

# add the application to the container
WORKDIR /app
COPY --from=build-env /publish .

ENTRYPOINT ["dotnet", "TripViewer.dll"]