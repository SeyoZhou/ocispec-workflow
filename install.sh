#!/bin/bash
# OCISpec Workflow Installer
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE_DIR="$SCRIPT_DIR/skills"
DEFAULT_CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

SKILL_DIRS=("oci:init" "oci:research" "oci:plan" "oci:openspec_to_csv" "oci:csv_execute" "oci:workflow")
SHARED_DIR="_shared"

MODE=""
CUSTOM_TARGET=""

usage() {
    echo -e "${BLUE}OCISpec Workflow Installer${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -u, --user      Install skills to \$CODEX_HOME/skills/"
    echo "  -p, --project   Install skills to ./.codex/skills/"
    echo "  -t, --target    Install to a custom directory (CODEX_HOME root or skills dir)"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Installs:"
    for s in "${SKILL_DIRS[@]}"; do
        echo "  /$(echo "$s" | tr ':' ':')"
    done
    echo ""
    echo "Examples:"
    echo "  $0 --user"
    echo "  $0 --project"
    echo "  $0 --target ~/.codex"
}

require_source_dir() {
    local dir=$1
    local label=$2
    if [ ! -d "$dir" ]; then
        echo -e "${RED}Error: ${label} directory not found: $dir${NC}"
        exit 1
    fi
}

install_skills() {
    local target_skills_dir=$1

    for skill in "${SKILL_DIRS[@]}"; do
        local src="$SKILLS_SOURCE_DIR/$skill"
        local dst="$target_skills_dir/$skill"
        require_source_dir "$src" "$skill"
        echo -e "  ${BLUE}Installing${NC} $skill"
        rm -rf "$dst"
        mkdir -p "$dst"
        COPYFILE_DISABLE=1 cp -R "$src"/. "$dst/"
    done

    # Install shared scripts into each skill that references them
    local shared_src="$SKILLS_SOURCE_DIR/$SHARED_DIR"
    if [ -d "$shared_src" ]; then
        for skill in "${SKILL_DIRS[@]}"; do
            local dst="$target_skills_dir/$skill/_shared"
            rm -rf "$dst"
            mkdir -p "$dst"
            COPYFILE_DISABLE=1 cp -R "$shared_src"/. "$dst/"
        done
        # Make scripts executable
        find "$target_skills_dir" -path '*/_shared/scripts/*.py' -exec chmod +x {} \;
    fi

    echo -e "${GREEN}  Done${NC}"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--user)
            MODE="user"
            shift
            ;;
        -p|--project)
            MODE="project"
            shift
            ;;
        -t|--target)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: --target requires a path${NC}"
                exit 1
            fi
            MODE="target"
            CUSTOM_TARGET="$2"
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

if [ -z "$MODE" ]; then
    echo -e "${RED}Error: Please specify installation target (-u, -p, or -t)${NC}"
    echo ""
    usage
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}OCISpec Workflow Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

case "$MODE" in
    user)
        TARGET_DIR="$DEFAULT_CODEX_HOME/skills"
        echo -e "Target: ${GREEN}$TARGET_DIR${NC}"
        echo ""
        install_skills "$TARGET_DIR"
        ;;
    project)
        TARGET_DIR="$SCRIPT_DIR/.codex/skills"
        echo -e "Target: ${GREEN}$TARGET_DIR${NC}"
        echo ""
        install_skills "$TARGET_DIR"
        ;;
    target)
        TARGET_PATH="${CUSTOM_TARGET/#\~/$HOME}"
        BASENAME="$(basename "$TARGET_PATH")"
        if [ "$BASENAME" = "skills" ]; then
            TARGET_DIR="$TARGET_PATH"
        else
            TARGET_DIR="$TARGET_PATH/skills"
        fi
        echo -e "Target: ${GREEN}$TARGET_DIR${NC}"
        echo ""
        install_skills "$TARGET_DIR"
        ;;
esac

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Restart Codex to reload skills.${NC}"
echo ""
echo -e "Usage:"
echo -e "  ${GREEN}/oci:init${NC}                              Initialize project"
echo -e "  ${GREEN}/oci:research${NC} \"requirement\"             Research requirement"
echo -e "  ${GREEN}/oci:plan${NC} openspec/proposal.md           Freeze plan"
echo -e "  ${GREEN}/oci:openspec_to_csv${NC} openspec/proposal.md  Generate CSV"
echo -e "  ${GREEN}/oci:csv_execute${NC} issues/<snapshot>.csv   Execute from CSV"
echo -e "  ${GREEN}/oci:workflow${NC}                            Show full flow"
