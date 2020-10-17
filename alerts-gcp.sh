#! /bin/bash
NAME=$1
PROJECT=$2
Channel_ID=$3
by_whome=$4
what=$5
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters!"
    echo "Needed Params(in Order): PolicyName-[byWhom] ProjectName ChannelID PrincipalEmail ServiceName[firewall,iam,gce,kms]"
    echo "Example: ./alerts firewall-changes-majd my-project xxxxxxxx majd.jamaah@gmail.com firewall"
    exit 0
fi


if [[ $what == "firewall" ]]; then
cat > config_$1.json <<EOF
{
  "name": $NAME,
  "description": $NAME,
  "filter": 'resource.type="gce_firewall_rule" logName="projects/$PROJECT/logs/cloudaudit.googleapis.com%2Factivity" protoPayload.methodName="v1.compute.firewalls.patch" OR protoPayload.methodName="v1.compute.firewalls.insert" OR protoPayload.methodName="v1.compute.firewalls.delete" protoPayload.authenticationInfo.principalEmail=$by_whome'
}
EOF
elif [[ $what == "kms" ]]; then
cat > config_$1.json <<EOF
{
  "name": $NAME,
  "description": $NAME,
  "filter": 'protoPayload.serviceName="cloudkms.googleapis.com" logName="projects/$PROJECT/logs/cloudaudit.googleapis.com%2Factivity" protoPayload.methodName="CreateCryptoKey" OR protoPayload.methodName="UpdateCryptoKey" OR protoPayload.methodName="DestroyCryptoKeyVersion" protoPayload.authenticationInfo.principalEmail=$by_whome'
}
EOF
elif [[ $what == "iam" ]]; then
cat > config_$1.json <<EOF
{
  "name": $NAME,
  "description": $NAME,
  "filter": 'protoPayload.serviceName="cloudresourcemanager.googleapis.com" logName="projects/$PROJECT/logs/cloudaudit.googleapis.com%2Factivity" protoPayload.methodName="SetIamPolicy" protoPayload.authenticationInfo.principalEmail=$by_whome'
}
EOF
elif [[ $what == "gce" ]]; then
cat > config_$1.json <<EOF
{
  "name": $NAME,
  "description": $NAME,
  "filter": 'resource.type="gce_instance" logName="projects/$PROJECT/logs/cloudaudit.googleapis.com%2Factivity" protoPayload.methodName="beta.compute.instances.insert" OR "v1.compute.instances.delete" protoPayload.authenticationInfo.principalEmail=$by_whome'
}
EOF
fi

sleep 10

gcloud beta logging metrics create $NAME --config-from-file=config_$NAME.json
cat > config_$1.yml <<EOF
combiner: OR
conditions:
- conditionThreshold:
    aggregations:
    - alignmentPeriod: 60s
      perSeriesAligner: ALIGN_RATE
    comparison: COMPARISON_GT
    duration: 0s
    filter: metric.type="logging.googleapis.com/user/$NAME" resource.type="global"
    trigger:
      count: 1
  displayName: logging/user/$NAME
displayName: $NAME
enabled: true
notificationChannels:
- projects/$PROJECT/notificationChannels/$Channel_ID
EOF
gcloud alpha monitoring policies create --policy-from-file=config_$NAME.yml

