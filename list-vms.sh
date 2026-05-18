(
echo -e "TYPE\tNAME\tRESOURCE_GROUP\tLOCATION\tPRIVATE_IP"

# Normal VMs
az vm list -d --query \
'[].{type:`VM`,name:name,rg:resourceGroup,loc:location,ip:privateIps}' \
-o tsv | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5}'

# VMSS instances
for vmss in $(az vmss list --query '[].id' -o tsv); do

    rg=$(echo "$vmss" | cut -d/ -f5)
    vmss_name=$(echo "$vmss" | cut -d/ -f9)

    az vmss nic list \
        --resource-group "$rg" \
        --vmss-name "$vmss_name" \
        --query '[].{vmid:virtualMachine.id,loc:location,ip:ipConfigurations[0].privateIPAddress}' \
        -o json | jq -r --arg rg "$rg" '
            .[] |
            (.vmid | split("/")) as $p |
            [
              "VMSS_INSTANCE",
              ($p[-3] + "_" + $p[-1]),
              $rg,
              (.loc // "N/A"),
              (.ip // "NO_IP")
            ] | @tsv
        '
done
) | column -t -s $'\t'
