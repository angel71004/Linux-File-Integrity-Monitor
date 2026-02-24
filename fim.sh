#!/bin/bash

# =====================================================
# Linux File Integrity Monitoring System (FIM v3)
# Author: Angel A
# Description:
# Detects content, permission, and ownership changes
# =====================================================

# -------- Colors --------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

BASELINE_FILE="baseline.db"
REPORT_DIR="reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$REPORT_DIR/report_$TIMESTAMP.txt"

mkdir -p "$REPORT_DIR"

# -------- Target Monitoring Paths --------
MONITOR_PATHS=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/ssh/sshd_config"
    "/etc/sudoers"
)

# =====================================================
# Initialize Baseline
# =====================================================
initialize_baseline() {

    echo -e "${BLUE}[*] Initializing baseline...${RESET}"
    > "$BASELINE_FILE"

    for path in "${MONITOR_PATHS[@]}"; do

        if [ -f "$path" ]; then

            hash=$(sha256sum "$path" | awk '{print $1}')
            perm=$(stat -c "%a" "$path")
            owner=$(stat -c "%U" "$path")
            group=$(stat -c "%G" "$path")

            echo "$hash|$perm|$owner|$group|$path" >> "$BASELINE_FILE"

        fi
    done

    echo -e "${GREEN}[+] Baseline created successfully.${RESET}"
}

# =====================================================
# Check Integrity
# =====================================================
check_integrity() {

    if [ ! -f "$BASELINE_FILE" ]; then
        echo -e "${RED}[!] Baseline not found. Initialize first.${RESET}"
        exit 1
    fi

    echo -e "${BLUE}[*] Checking file integrity...${RESET}"
    echo "Integrity Check - $(date)" >> "$REPORT_FILE"

    modified=0
    unchanged=0
    missing=0

    # Declare associative arrays
    declare -A baseline_hashes
    declare -A baseline_perms
    declare -A baseline_owners
    declare -A baseline_groups

    # Load baseline
    while IFS="|" read -r hash perm owner group file; do
        baseline_hashes["$file"]="$hash"
        baseline_perms["$file"]="$perm"
        baseline_owners["$file"]="$owner"
        baseline_groups["$file"]="$group"
    done < "$BASELINE_FILE"

    # Check each file
    for file in "${!baseline_hashes[@]}"; do

        if [ -f "$file" ]; then

            current_hash=$(sha256sum "$file" | awk '{print $1}')
            current_perm=$(stat -c "%a" "$file")
            current_owner=$(stat -c "%U" "$file")
            current_group=$(stat -c "%G" "$file")

            alert_flag=0

            # Content Check
            if [ "${baseline_hashes[$file]}" != "$current_hash" ]; then
                echo -e "${RED}[ALERT] Content Modified: $file${RESET}"
                echo "[ALERT] Content Modified: $file" >> "$REPORT_FILE"
                ((modified++))
                alert_flag=1
            fi

            # Permission Check
            if [ "${baseline_perms[$file]}" != "$current_perm" ]; then
                echo -e "${YELLOW}[ALERT] Permission Changed: $file${RESET}"
                echo "[ALERT] Permission Changed: $file" >> "$REPORT_FILE"
                alert_flag=1
            fi

            # Ownership Check
            if [ "${baseline_owners[$file]}" != "$current_owner" ] || \
               [ "${baseline_groups[$file]}" != "$current_group" ]; then
                echo -e "${YELLOW}[ALERT] Ownership Changed: $file${RESET}"
                echo "[ALERT] Ownership Changed: $file" >> "$REPORT_FILE"
                alert_flag=1
            fi

            if [ $alert_flag -eq 0 ]; then
                ((unchanged++))
            fi

        else
            echo -e "${YELLOW}[WARNING] Missing File: $file${RESET}"
            echo "[WARNING] Missing File: $file" >> "$REPORT_FILE"
            ((missing++))
        fi

    done

    echo ""
    echo -e "${BLUE}========== Summary ==========${RESET}"
    echo -e "${GREEN}Unchanged Files: $unchanged${RESET}"
    echo -e "${RED}Modified Files: $modified${RESET}"
    echo -e "${YELLOW}Missing Files: $missing${RESET}"
    echo -e "${BLUE}=============================${RESET}"

    echo "Summary: Unchanged=$unchanged Modified=$modified Missing=$missing" >> "$REPORT_FILE"
}

# =====================================================
# AUTO MODE (For Cron)
# =====================================================
if [ "$1" == "--auto" ]; then
    check_integrity
    exit 0
fi

# =====================================================
# MENU
# =====================================================
clear
echo -e "${BLUE}"
echo "========================================="
echo "     Linux File Integrity Monitor"
echo "========================================="
echo -e "${RESET}"

echo "1) Initialize Baseline"
echo "2) Check Integrity"
echo "3) Exit"
echo ""

read -p "Select option: " choice

case $choice in
    1) initialize_baseline ;;
    2) check_integrity ;;
    3) exit 0 ;;
    *) echo -e "${RED}Invalid option.${RESET}" ;;
esac
