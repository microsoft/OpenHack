FROM jenkins/jenkins:2.229

ARG JENKINS_USERNAME=demouser
ARG JENKINS_PASSWORD=demo@pass123

ENV JENKINS_USERNAME $JENKINS_USERNAME
ENV JENKINS_PASSWORD $JENKINS_PASSWORD
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

RUN echo "Starting installation of Jenkins Plugins" \
    && /usr/local/bin/install-plugins.sh \
                              "git" \
                              "azure-commons" \
                              "azure-acs" \
                              "azure-app-service" \
                              "azure-cli" \
    && echo "Done"

COPY ./default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
