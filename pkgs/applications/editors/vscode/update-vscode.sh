#! /usr/bin/env nix-shell
#! nix-shell update-shell.nix -i bash

# Update script for the vscode versions and hashes.
# Usually doesn't need to be called by hand,
# but is called by a bot: https://github.com/samuela/nixpkgs-upkeep/actions
# Call it by hand if the bot fails to automatically update the versions.

set -eou pipefail

ROOT="$(dirname "$(readlink -f "$0")")"
if [ ! -f "$ROOT/vscode.nix" ]; then
  echo "ERROR: cannot find vscode.nix in $ROOT"
  exit 1
fi

# VSCode

VSCODE_VER=$(curl --fail --silent https://api.github.com/repos/Microsoft/vscode/releases/latest | jq --raw-output .tag_name)
sed -i "s/version = \".*\"/version = \"${VSCODE_VER}\"/" "$ROOT/vscode.nix"

TEMP_FOLDER=$(mktemp -d)

VSCODE_X64_LINUX_URL="https://update.code.visualstudio.com/${VSCODE_VER}/linux-x64/stable"

# Split output by newlines into Bash array
readarray -t VSCODE_X64_LINUX <<< $(nix-prefetch-url --print-path ${VSCODE_X64_LINUX_URL})

sed -i "s/x86_64-linux = \".\{52\}\"/x86_64-linux = \"${VSCODE_X64_LINUX[0]}\"/" "$ROOT/vscode.nix"

tar xf ${VSCODE_X64_LINUX[1]} -C $TEMP_FOLDER
VSCODE_COMMIT=$(jq --raw-output .commit $TEMP_FOLDER/VSCode-linux-x64/resources/app/product.json)
sed -i "s/rev = \".\{40\}\"/rev = \"${VSCODE_COMMIT}\"/" "$ROOT/vscode.nix"

SERVER_X64_LINUX_URL="https://update.code.visualstudio.com/commit:${VSCODE_COMMIT}/server-linux-x64/stable"
SERVER_X64_LINUX_SHA256=$(nix-prefetch-url ${SERVER_X64_LINUX_URL})
sed -i "s/sha256 = \".\{51,52\}\"/sha256 = \"${SERVER_X64_LINUX_SHA256}\"/" "$ROOT/vscode.nix"
