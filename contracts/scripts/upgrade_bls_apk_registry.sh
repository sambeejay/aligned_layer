#!/bin/bash

# cd to the directory of this script so that this can be run from anywhere
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"

cd ../

# Save the output to a variable to later extract the address of the new deployed contract
forge_output=$(forge script script/upgrade/BLSApkRegistryUpgrader.s.sol \
    $EXISTING_DEPLOYMENT_INFO_PATH \
    $OUTPUT_PATH \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --sig "run(string memory eigenLayerDeploymentFilePath, string memory alignedLayerDeploymentFilePath, )")

echo "$forge_output"

# Extract the alignedLayerServiceManagerImplementation value from the output
new_bls_apk_registry_implementation=$(echo "$forge_output" | awk '/1: address/ {print $3}')

# Use the extracted value to replace the alignedLayerServiceManagerImplementation value in alignedlayer_deployment_output.json and save it to a temporary file
jq --arg new_bls_apk_registry_implementation "$new_bls_apk_registry_implementation" '.addresses.blsApkRegistryImplementation = $new_bls_apk_registry_implementation' "script/output/holesky/alignedlayer_deployment_output.json" > "script/output/holesky/alignedlayer_deployment_output.temp.json"

# Replace the original file with the temporary file
mv "script/output/holesky/alignedlayer_deployment_output.temp.json" "script/output/holesky/alignedlayer_deployment_output.json"

# Delete the temporary file
rm -f "script/output/holesky/alignedlayer_deployment_output.temp.json"
