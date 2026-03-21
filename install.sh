#!/bin/bash
# OCISpec Workflow Installer
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMAND_NAME="ocispec"

usage() {
    echo -e "${BLUE}OCISpec Workflow Installer${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -u, --user      Install to user-level (~/.codex/prompts/)"
    echo "  -p, --project   Install to project-level (./.codex/prompts/)"
    echo "  -t, --target    Install to custom target path"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --user"
    echo "  $0 --project"
    echo "  $0 --target /custom/path"
}

install_prompts() {
    local target_dir=$1
    local source_dir="$SCRIPT_DIR/prompts"

    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}Error: 'prompts' directory not found${NC}"
        return 1
    fi

    echo -e "${BLUE}Installing prompts${NC} -> $target_dir"
    mkdir -p "$target_dir"

    cp "$source_dir"/oci:*.md "$target_dir/"
    echo -e "${GREEN}  ✓ Installed prompts${NC}"
}

install_scripts() {
    local target_dir=$1
    local source_dir="$SCRIPT_DIR/scripts"
    local dest_dir="$target_dir/../skills/oci-openspec-csv/scripts"

    if [ ! -d "$source_dir" ]; then
        echo -e "${YELLOW}Warning: 'scripts' directory not found, skipping${NC}"
        return 0
    fi

    echo -e "${BLUE}Installing scripts${NC} -> $dest_dir"
    mkdir -p "$dest_dir"

    cp "$source_dir"/*.py "$dest_dir/"
    chmod +x "$dest_dir"/*.py
    echo -e "${GREEN}  ✓ Installed scripts${NC}"
}

TARGET_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--user)
            TARGET_PATH="$HOME/.codex/prompts"
            shift
            ;;
        -p|--project)
            TARGET_PATH="./.codex/prompts"
            shift
            ;;
        -t|--target)
            TARGET_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

if [ -z "$TARGET_PATH" ]; then
    echo -e "${RED}Error: Please specify installation target (-u, -p, or -t)${NC}"
    echo ""
    usage
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}OCISpec Workflow Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Target: ${GREEN}$TARGET_PATH${NC}"
echo ""

install_prompts "$TARGET_PATH"
install_scripts "$TARGET_PATH"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
