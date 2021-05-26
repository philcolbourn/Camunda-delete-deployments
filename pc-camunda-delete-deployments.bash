#!/bin/bash

# apt-cyg -u install jq

declare TENANTS="$1"

declare     URL="http://localhost:8080/engine-rest"
declare    JSON="qDeployments.json"
declare     IDs="qDeploymentIds.txt"
declare  RESULT="qResult.json"

printJsonFile(){ local HEAD="$1"; local FILE="$2"; printf "\n%s:\n" "$HEAD"; cat $FILE | json_pp; }
printFile()    { local HEAD="$1"; local FILE="$2"; printf "\n%s:\n" "$HEAD"; cat $FILE;           }

# get deployments, process or decision definitions for tenants
getProcessDefinitions() { curl "$URL/process-definition?tenantIdIn=$TENANTS";  }
getDecisionDefinitions(){ curl "$URL/decision-definition?tenantIdIn=$TENANTS"; }
getDeployment()         { curl "$URL/deployment?tenantIdIn=$TENANTS";          }

# get IDs from JSON assuming [{'id':'someId','deploymentId':'someDeploymentId',...},...]
getIds()          { jq -r '.[]."id"';           }
getDeploymentIds(){ jq -r '.[]."deploymentId"'; }

deleteProcessDefinition(){ local ID="$1"; curl --request DELETE "$URL/process-definition/${ID}?cascade=true&skipCustomListeners=true&skipIoMappings=true"; }
deleteDeployment()       { local ID="$1"; curl --request DELETE "$URL/deployment/$ID"; }


getProcessDefinitions >$JSON; printJsonFile "Process definitions"    $JSON
cat $JSON | getIds    >$IDs;  printFile     "Process definition IDs" $IDs

# FIXME: does it return json?
while read ID; do deleteProcessDefinition "$ID"; done <$IDs

# delete deployments - will fail for deployments with process instances
getDeployment      >$JSON; printJsonFile "Deployment"     $JSON
cat $JSON | getIds >$IDs;  printFile     "Deployment IDs" $IDs

while read ID; do deleteDeployment "$ID"; done <$IDs

exit 0
# should not need this now

# get decision definitions for tenants
getDecisionDefinitions >$JSON; printJsonFile "Decision definitions"    $JSON
cat $JSON | getIds     >$IDs;  printFile     "Decision definition IDs" $IDs

# delete deployment - fails if process instances exist
#while read ID; do deleteDeployment "$ID"; done <$IDs
