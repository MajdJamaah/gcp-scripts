We need to automate the process of adding custom metrics and alerts.
So that I prepared a script to handle the process.

Detect changes for:
- GCE: 
Beta.compute.instances.insert, and v1.compute.instances.delete
- IAM:
SetIamPolicy
- Firewall:
v1.compute.firewalls.patch, v1.compute.firewalls.insert, and v1.compute.firewalls.delete
- KMS:
CreateCryptoKey, UpdateCryptoKey, and DestroyCryptoKeyVersion



Note that we need to specify person based alerts to detect that what policy triggered and by whom.


How to use (alerting-gcp.sh)

Needed Params(in Order):

PolicyName-[byWhom] ProjectName ChannelID PrincipalEmail ServiceName[firewall,iam,gce,kms]

PolicyName → specified by you and better to mention the name for a person with it.
ProjectName → the project need to apply for.
ChannelID → the email channel ID you want to receive alerts on.
PrincipalEmail → email of the person.
ServiceName → what we need to get alerts for [firewall, iam, gce, kms].

Example: 

./alerts firewall-changes-majd my-project xxxxxx majd.jamaah@xxx.com firewall
