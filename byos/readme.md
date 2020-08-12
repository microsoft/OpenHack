![Microsoft OpenHack](images/OpenHack.png "Microsoft Open Hack")


# Microsoft OpenHack Bring your Own Subscription (BYOS)

Bring your own subscription (BYOS) enables you to participate in a Microsoft OpenHack using your own Azure subscriptions. The documentation in this repository provides guidance on how to setup each OpenHack in your subscription as well as an overview of some of the differences you will see when interacting with the coach and attendee portals of OpenHack when using your own subscription.


**Contents**

<!-- TOC -->

- [Microsoft OpenHack Bring your Own Subscription BYOS](#microsoft-openhack-bring-your-own-subscription-byos)
    - [Timing Alert](#timing-alert)
    - [OpenHack Specific Deployment Guidance](#openhack-specific-deployment-guidance)
    - [OpenHack Portal Differences](#openhack-portal-differences)
        - [Cloud Sandbox Coach Portal](#cloud-sandbox-coach-portal)
        - [Attendee Portal](#attendee-portal)

<!-- /TOC -->


## Timing Alert
Setup of environment may take extensive time depending on the OpenHack topic you are running. For safe measure, please start running the OpenHack on your Azure subscription(s) at least 48 hours before the kickoff of the event. 


## OpenHack Specific Deployment Guidance

The following documents outline the permissions needed for each OpenHack, the most common resources that are created, as well deployment script documentation if the OpenHack has resources that should be created prior to the start. 

- [AI-Powered Knowledge Mining](knowledge-mining/deployment.md)
- [App Modernization with NoSQL](app-modernization-no-sql/deployment.md)
- [Containers](containers/deployment.md)
- [DevOps 2.0](devops-2.0/deployment.md)
- [Modern Data Warehousing](modern-data-warehousing/deployment.md)
- [Power Platform](power-platform/deployment.md)
- [Serverless](serverless/deployment.md)

## OpenHack Portal Differences

In a BYOS OpenHack, the Azure subscriptions are managed completely out of the Opsgility environment. The following outlines the differences you will experience in the Cloud Sandbox/Coach Portal and the attendee portal in a BYOS OpenHack environment.

### Cloud Sandbox (Coach Portal)

The differences you will encounter on the Cloud Sandbox is as a Tech Lead or a Lead PM/Coach:

- You will no longer have the ability to start or end the lab environment. This is because the Azure subscriptions in a BYOS scenario are not controlled by the Cloud Sandbox. 
- You will not have the ability to view view the Azure credentials for the environments. Access to the Azure subscriptions must be managed in the Azure AD tenant you will use for the BYOS environment. 

### Attendee Portal

The difference you will encounter on the Attendee portal is you will not see the **View Lab Environment** tab with your Azure user credentials. Access to the Azure subscription in managed on the Azure AD tenant you will use for the BYOS environent.



## Questions?

- OpenHack program: <a href="mailto:askopenhack@microsoft.com">Contact us askopenhack@microsoft.com</a>
- Opsgility Portals <a href="mailto:openhacks@opsgility.com">Contact us at openhacks@opsgility.com</a>