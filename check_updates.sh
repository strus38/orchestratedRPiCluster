#!/bin/bash
for p in $(kubectl get deployments -o jsonpath='{range .items[*]}{range .spec.template.spec.containers[*]}{.image}{"\n"}{end}'| grep -v  "latest\|stable"); do 
    IFS=:
    read -r -a array <<< "$p"
    latest=$(curl -s https://hub.docker.com/v2/repositories/"${array[0]}"/tags/ | jq -r '[.results[]|select(.name | test("^v?\\d+\\.\\d+\\.\\d(-\\d+)?$"))][0].name')
    if [[ "${array[1]}" != "$latest" ]]; then
        echo "${array[0]}" Current: "${array[1]}" Latest: "$latest"
    fi
done
