FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build

WORKDIR /apps

COPY svcbusclient /apps/svcbusclient
COPY ContainersSimulator/ContainersSimulator /apps/ContainersSimulator
RUN dotnet add svcbusclient/svcbusclient.csproj package Microsoft.Azure.ServiceBus --version 3.1.0 
RUN dotnet build svcbusclient/svcbusclient.csproj 
RUN dotnet publish -c release -o /apps/svcbusclient/release  -r linux-musl-x64 svcbusclient/svcbusclient.csproj
RUN dotnet build ContainersSimulator/ContainersSimulator.csproj 
RUN dotnet publish -c release -o /apps/ContainersSimulator/output ContainersSimulator/ContainersSimulator.csproj 


FROM mcr.microsoft.com/azure-cli:2.0.67

ENV home /home/azureuser
RUN mkdir -p /home/azureuser
WORKDIR /home/azureuser

RUN apk update && \
  apk add jq zip

#####Dotnet Runtime Deps######
RUN apk add --no-cache \
        ca-certificates \
        \
        # .NET Core dependencies
        krb5-libs \
        libgcc \
        libintl \
        libssl1.0 \
        libstdc++ \
        lttng-ust \
        tzdata \
        userspace-rcu \
        zlib

# Configure web servers to bind to port 80 when present
ENV ASPNETCORE_URLS=http://+:80 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Set the invariant mode since icu_libs isn't included (see https://github.com/dotnet/announcements/issues/20)
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

#######

COPY --from=build apps/svcbusclient/release ./svcbusclient/release
COPY insuranceapp-monitoring ./insuranceapp-monitoring
COPY WinLegacyApp ./WinLegacyApp
COPY --from=build apps/ContainersSimulator/output ./ContainersSimulator/output
COPY tripviewer2 ./tripviewer2
COPY ContainersSimulatorV2 ./ContainersSimulatorV2
COPY send_msg.sh .
COPY deploy.sh .

RUN ["chmod", "+x", "send_msg.sh"]
RUN ["chmod", "+x", "deploy.sh"]

ENTRYPOINT [ "/bin/bash","-c", "./deploy.sh -u $AZUREUSER -p $AZUREPASS -s $SUBID -g `[ -z \"${RESOURCEGROUPNAME}\" ] && echo teamResources || echo $RESOURCEGROUPNAME` -l $LOCATION -i $SIMULATORLOCATION -r $RECIPIENTEMAIL -c $CHATCONNECTIONSTRING -q $CHATMSGQUEUE -o `[ -z \"${PROCTORRESOURCEGROUP}\" ] && echo ProctorVMRG || echo $PROCTORRESOURCEGROUP` -t $TENANTID"]
