#!/bin/bash


cmd=$1
name=$2

if [[ $cmd = "start" ]]; then
    # provision the dev environment
    uv run main.py create "$name"

    # get the pod name
    claim_name=$(cat $name.claim.txt)
    sandbox_id=$(cat $name.id.txt)

    bridge_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

    echo "Configuring..."

    # configure sandbox

    echo "Connect via HTTP at the following"
    echo "http://$bridge_ip:30111/devb/default/$sandbox_id/8888/"

    # start an ssh connection
    kubectl exec -it "$sandbox_id" -- /bin/bash

    exit 0
fi

# get the pod name
claim_name=$(cat $name.claim.txt 2> /dev/null)
sandbox_id=$(cat $name.id.txt 2> /dev/null)

# clean up
if [[ $cmd = "stop" ]]; then
    uv run main.py delete "$claim_name"

    rm $name.claim.txt 2> /dev/null
    rm $name.id.txt 2> /dev/null

    exit 0
fi

echo ""
echo "commands are: start, stop"
echo ""
echo "for example:"
echo "./dev-box.sh start <name>"
echo "or,"
echo "./dev-box.sh stop <name>"
echo ""