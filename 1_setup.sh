#!/bin/bash

################################################################################
# Reconnaissance Scanner - Dependency Setup Script
# This script installs all required dependencies
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Cannot detect OS${NC}"
    exit 1
fi

echo -e "${BLUE}"
cat << "EOF"
    
    ███████╗██╗     ██╗███████╗██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗ 
    ██╔════╝██║     ██║██╔════╝██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
    █████╗  ██║     ██║███████╗███████║███████║██║     █████╔╝ █████╗  ██████╔╝
    ██╔══╝  ██║     ██║╚════██║██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
    ███████╗███████╗██║███████║██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
    ╚══════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
    
    ╔══════════════════════════════════════════════════════════════╗
    ║     RECON SCANNER - DEPENDENCY SETUP                        ║
    ║   Professional Vulnerability Assessment Tool                ║
    ║     Developed By Elifaster InfoSec                          ║
    ║                                                              ║
    ║  This script will install all required dependencies for     ║
    ║  the Reconnaissance & Vulnerability Scanner                 ║
    ╚══════════════════════════════════════════════════════════════╝
    
EOF
echo -e "${NC}"

echo -e "${YELLOW}Detected OS: $OS${NC}\n"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}This script may require sudo for package installation.${NC}"
    echo -e "${YELLOW}Please enter your password when prompted.${NC}\n"
    SUDO="sudo"
else
    SUDO=""
fi

# Function to install packages
install_packages() {
    local packages=("$@")
    
    case $OS in
        ubuntu|debian)
            echo -e "${BLUE}[*] Updating package list...${NC}"
            $SUDO apt-get update -qq
            
            for pkg in "${packages[@]}"; do
                echo -e "${BLUE}[*] Installing $pkg...${NC}"
                $SUDO apt-get install -y "$pkg" 2>&1 | grep -v "^Get:" || true
                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}✓ $pkg installed${NC}"
                else
                    echo -e "${YELLOW}! $pkg may already be installed${NC}"
                fi
            done
            ;;
            
        fedora|rhel|centos)
            for pkg in "${packages[@]}"; do
                echo -e "${BLUE}[*] Installing $pkg...${NC}"
                $SUDO dnf install -y "$pkg" 2>&1 | tail -5 || true
                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}✓ $pkg installed${NC}"
                else
                    echo -e "${YELLOW}! $pkg may already be installed${NC}"
                fi
            done
            ;;
            
        arch)
            for pkg in "${packages[@]}"; do
                echo -e "${BLUE}[*] Installing $pkg...${NC}"
                $SUDO pacman -S --noconfirm "$pkg" 2>&1 | tail -5 || true
                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}✓ $pkg installed${NC}"
                else
                    echo -e "${YELLOW}! $pkg may already be installed${NC}"
                fi
            done
            ;;
    esac
}

# Define required packages
REQUIRED_PACKAGES=("nmap" "curl" "bind-utils" "python3")

# Linux-specific adjustments
if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
    REQUIRED_PACKAGES=("nmap" "curl" "dnsutils" "python3")
fi

echo -e "${YELLOW}Required packages:${NC}"
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    echo "  - $pkg"
done
echo ""

# Check for already installed packages
echo -e "${BLUE}Checking for installed packages...${NC}"
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if command -v "$pkg" &> /dev/null || $SUDO dpkg -l | grep -q "$pkg" 2>/dev/null || $SUDO rpm -q "$pkg" &> /dev/null 2>&1; then
        echo -e "${GREEN}✓ $pkg is already installed${NC}"
    else
        echo -e "${YELLOW}! $pkg needs to be installed${NC}"
    fi
done
echo ""

# Offer installation
read -p "Do you want to install missing dependencies? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_packages "${REQUIRED_PACKAGES[@]}"
else
    echo -e "${YELLOW}Skipping package installation.${NC}"
fi

# Verify installations
echo -e "\n${BLUE}Verifying installations...${NC}"
MISSING=0

for cmd in nmap curl dig python3; do
    if command -v "$cmd" &> /dev/null; then
        VERSION=$("$cmd" --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓ $cmd${NC} - $VERSION"
    else
        echo -e "${RED}✗ $cmd${NC} - NOT FOUND"
        MISSING=$((MISSING + 1))
    fi
done

if [[ $MISSING -eq 0 ]]; then
    echo -e "\n${GREEN}═════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ All dependencies are installed and ready!${NC}"
    echo -e "${GREEN}═════════════════════════════════════════════════════════${NC}"
    
    echo -e "\n${BLUE}Quick Start:${NC}"
    echo "  1. Make sure recon-vuln-scanner.sh is executable:"
    echo "     chmod +x /home/r3dh4t/Scripts/recon-vuln-scanner.sh"
    echo ""
    echo "  2. Run a basic scan:"
    echo "     ./recon-vuln-scanner.sh -t example.com"
    echo ""
    echo "  3. For help, run:"
    echo "     ./recon-vuln-scanner.sh -h"
    echo ""
else
    echo -e "\n${RED}═════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}✗ Some dependencies are still missing!${NC}"
    echo -e "${RED}═════════════════════════════════════════════════════════${NC}"
    echo -e "\n${YELLOW}Missing $MISSING dependencies. Please install them manually.${NC}"
    exit 1
fi

echo -e "\n${BLUE}For detailed information, see:${NC}"
echo "  - README.md"
echo "  - ./recon-vuln-scanner.sh -h"
