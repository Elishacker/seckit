#!/bin/bash

################################################################################
# Comprehensive Reconnaissance & Vulnerability Scanner
# Author: Security Expert
# Description: Powerful tool for gathering target information and vulnerability
#              scanning following OWASP Top 10 guidelines
################################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/scan_results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="${OUTPUT_DIR}/scan_report_${TIMESTAMP}.txt"
LOG_FILE="${OUTPUT_DIR}/scan_log_${TIMESTAMP}.log"

# Default values
TARGET=""
PORT_RANGE="1-65535"
SCAN_TYPE=""
VERBOSE=0
THREADS=10

# Create output directory
mkdir -p "${OUTPUT_DIR}"

################################################################################
# Utility Functions
################################################################################

# Logging function
log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

# Print banner
print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    
    ███████╗██╗     ██╗███████╗██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗ 
    ██╔════╝██║     ██║██╔════╝██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
    █████╗  ██║     ██║███████╗███████║███████║██║     █████╔╝ █████╗  ██████╔╝
    ██╔══╝  ██║     ██║╚════██║██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
    ███████╗███████╗██║███████║██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
    ╚══════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
    
    ╔══════════════════════════════════════════════════════════════╗
    ║     RECONNAISSANCE & VULNERABILITY SCANNER v1.0             ║
    ║   Professional Security Assessment Tool                     ║
    ║     Developed By Elifaster InfoSec                          ║
    ║                                                              ║
    ║  Gathering intelligence on: Open Ports, Services,           ║
    ║  Directories, Subdomains & OWASP Top 10 Vulnerabilities     ║
    ╚══════════════════════════════════════════════════════════════╝
    
EOF
    echo -e "${NC}"
}

# Error handler
error_exit() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    log "ERROR" "$1"
    exit 1
}

# Success message
success() {
    echo -e "${GREEN}[✓] $1${NC}"
    log "INFO" "$1"
}

# Info message
info() {
    echo -e "${BLUE}[*] $1${NC}"
    log "INFO" "$1"
}

# Warning message
warn() {
    echo -e "${YELLOW}[!] $1${NC}"
    log "WARN" "$1"
}

# Check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

# Validate target
validate_target() {
    if [[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ||
       [[ "$1" =~ ^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
        return 0
    fi
    return 1
}

# Display usage
show_usage() {
    cat << EOF
${CYAN}Usage: $0 [OPTIONS]${NC}

${YELLOW}Options:${NC}
    -t, --target <target>      Target IP address or domain (REQUIRED)
    -s, --scan <type>          Scan type: all, ports, directories, subdomains, vuln
                               (Default: all)
    -p, --ports <range>        Port range (Default: 1-65535)
                               Example: 1-1000, 22,80,443,3306
    -T, --threads <num>        Number of threads for parallel scanning (Default: 10)
    -v, --verbose              Enable verbose output
    -h, --help                 Display this help message

${YELLOW}Examples:${NC}
    $0 -t 192.168.1.100
    $0 -t example.com -s ports -p 1-1000
    $0 -t 10.0.0.5 -s all -T 20 -v

${YELLOW}Scan Types:${NC}
    all            - Run all scans (ports, directories, subdomains, vulnerabilities)
    ports          - Port and service scanning
    directories    - Directory enumeration and listing
    subdomains     - Subdomain discovery
    vuln           - OWASP Top 10 vulnerability scanning

${NC}
EOF
}

################################################################################
# Port and Service Scanning
################################################################################

scan_ports() {
    local target="$1"
    local port_range="$2"
    
    echo -e "\n${PURPLE}╔════ PORT & SERVICE SCANNING ════╗${NC}"
    info "Initiating port scan on $target (Range: $port_range)"
    
    local nmap_output="${OUTPUT_DIR}/nmap_${target//./_}_${TIMESTAMP}.txt"
    
    if ! check_command "nmap"; then
        warn "nmap not found. Attempting to install..."
        sudo apt-get update && sudo apt-get install -y nmap 2>/dev/null || error_exit "Please install nmap"
    fi
    
    # Run Nmap scan
    info "Running Nmap scan with service detection..."
    nmap -sV -sC -p "${port_range}" -oN "${nmap_output}" "$target" 2>/dev/null || {
        warn "Nmap scan encountered issues, attempting basic scan..."
        nmap -p "${port_range}" -oN "${nmap_output}" "$target" 2>/dev/null || error_exit "Nmap scan failed"
    }
    
    # Extract and display results
    echo -e "\n${CYAN}=== OPEN PORTS AND SERVICES ===${NC}"
    cat "${nmap_output}" | grep -E "^[0-9]+/" | tee -a "${REPORT_FILE}"
    
    # Extract service information
    echo -e "\n${CYAN}=== SERVICE DETAILS ===${NC}"
    grep -E "Service|Product|Version" "${nmap_output}" | tee -a "${REPORT_FILE}" || true
    
    success "Port scan completed. Results saved to $nmap_output"
    
    # Return open ports for further analysis
    echo "${nmap_output}"
}

################################################################################
# Directory Enumeration
################################################################################

scan_directories() {
    local target="$1"
    
    echo -e "\n${PURPLE}╔════ DIRECTORY ENUMERATION ════╗${NC}"
    info "Starting directory brute-forcing on $target"
    
    # Determine if target is IP or domain
    local protocol="http"
    local port="80"
    
    # Check if HTTPS is available
    if timeout 5 bash -c "echo > /dev/tcp/${target}/443" 2>/dev/null; then
        protocol="https"
        port="443"
        info "HTTPS detected on port 443"
    fi
    
    # Check HTTP
    if ! timeout 5 bash -c "echo > /dev/tcp/${target}/80" 2>/dev/null; then
        if ! timeout 5 bash -c "echo > /dev/tcp/${target}/443" 2>/dev/null; then
            warn "No web service detected on standard ports (80, 443)"
            return
        fi
    fi
    
    local dir_output="${OUTPUT_DIR}/directories_${target//./_}_${TIMESTAMP}.txt"
    
    # Common directory wordlist
    local wordlist="/usr/share/wordlists/dirb/common.txt"
    if [[ ! -f "$wordlist" ]]; then
        info "Creating basic directory wordlist..."
        wordlist="${OUTPUT_DIR}/directory_wordlist.txt"
        cat > "$wordlist" << 'WORDLIST'
admin
api
assets
backup
blog
config
css
database
downloads
files
images
includes
index.php
index.html
js
login
members
old
pages
panel
pictures
public
scripts
secure
server-status
shop
src
static
style
uploads
user
users
var
videos
web
wp-admin
wp-content
wp-includes
WORDLIST
    fi
    
    info "Using wordlist: $wordlist"
    
    # Directory scanning using curl with wordlist
    echo -e "\n${CYAN}=== DIRECTORY BRUTE FORCE RESULTS ===${NC}"
    {
        while IFS= read -r dir; do
            if [[ -z "$dir" ]] || [[ "$dir" =~ ^# ]]; then
                continue
            fi
            
            local url="${protocol}://${target}/${dir}"
            local response=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "$url" 2>/dev/null || echo "000")
            
            if [[ "$response" != "000" ]] && [[ "$response" != "404" ]]; then
                local status_color="${GREEN}"
                [[ "$response" == "403" ]] && status_color="${YELLOW}"
                
                echo -e "${status_color}[${response}]${NC} $url"
                echo "[${response}] $url" >> "${dir_output}"
            fi
        done < "$wordlist"
    } | tee -a "${REPORT_FILE}"
    
    success "Directory enumeration completed. Results saved to $dir_output"
}

################################################################################
# Subdomain Enumeration
################################################################################

scan_subdomains() {
    local target="$1"
    
    echo -e "\n${PURPLE}╔════ SUBDOMAIN ENUMERATION ════╗${NC}"
    info "Starting subdomain discovery for $target"
    
    # Extract domain from target
    local domain="$target"
    if [[ "$domain" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        info "Target is IP address. Attempting reverse DNS lookup..."
        domain=$(dig +short -x "$target" 2>/dev/null | sed 's/\.$//' || echo "$target")
    fi
    
    local subdomain_output="${OUTPUT_DIR}/subdomains_${target//./_}_${TIMESTAMP}.txt"
    
    # Method 1: Using curl + DNS
    echo -e "\n${CYAN}=== METHOD 1: DNS ENUMERATION ===${NC}"
    info "Performing DNS enumeration..."
    
    local common_subdomains=(
        "www" "mail" "ftp" "localhost" "webmail" "smtp" "pop" "ns1" "ns2" "ns3"
        "webdisk" "test" "vpn" "api" "blog" "admin" "dev" "staging" "backup"
        "cdn" "dns" "mysql" "postgresql" "database" "db" "cloud" "ssh" "ftp2"
        "server" "store" "shop" "ssl" "secure" "secure2" "app" "apps" "cpanel"
        "whm" "autodiscover" "docs" "wiki" "git" "github" "gitlab" "jenkins"
        "monitoring" "status" "download" "downloads" "support" "help"
    )
    
    {
        for subdomain in "${common_subdomains[@]}"; do
            local full_domain="${subdomain}.${domain}"
            local ip=$(dig +short "$full_domain" 2>/dev/null | grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" | head -1)
            
            if [[ -n "$ip" ]]; then
                echo -e "${GREEN}[+]${NC} $full_domain -> $ip"
                echo "$full_domain -> $ip" >> "${subdomain_output}"
            fi
        done
    } | tee -a "${REPORT_FILE}"
    
    # Method 2: Using DNS TXT records
    echo -e "\n${CYAN}=== METHOD 2: SPF/MX RECORDS ===${NC}"
    info "Extracting SPF, MX, and other DNS records..."
    {
        echo -e "${CYAN}MX Records:${NC}"
        dig +short MX "$domain" 2>/dev/null | head -n 10 || echo "No MX records found"
        
        echo -e "\n${CYAN}SPF Records:${NC}"
        dig +short TXT "$domain" 2>/dev/null | grep "v=spf1" || echo "No SPF record found"
        
        echo -e "\n${CYAN}NS Records:${NC}"
        dig +short NS "$domain" 2>/dev/null | head -n 5 || echo "No NS records found"
    } | tee -a "${REPORT_FILE}"
    
    success "Subdomain enumeration completed. Results saved to $subdomain_output"
}

################################################################################
# OWASP Top 10 Vulnerability Scanning
################################################################################

scan_owasp_vulnerabilities() {
    local target="$1"
    
    echo -e "\n${PURPLE}╔════ OWASP TOP 10 VULNERABILITY SCAN ════╗${NC}"
    info "Starting OWASP Top 10 vulnerability assessment"
    
    # Determine protocol
    local protocol="http"
    local port="80"
    
    if timeout 5 bash -c "echo > /dev/tcp/${target}/443" 2>/dev/null; then
        protocol="https"
        port="443"
    fi
    
    if ! timeout 5 bash -c "echo > /dev/tcp/${target}/${port}" 2>/dev/null; then
        warn "No web service accessible on $target"
        return
    fi
    
    local base_url="${protocol}://${target}"
    local vuln_output="${OUTPUT_DIR}/vulnerabilities_${target//./_}_${TIMESTAMP}.txt"
    
    # 1. SQL Injection Detection
    echo -e "\n${CYAN}=== 1. SQL INJECTION DETECTION ===${NC}"
    info "Testing for SQL injection vulnerabilities..."
    {
        local sql_payloads=("' OR '1'='1" "admin' --" "1' UNION SELECT NULL --" "' OR 1=1 --")
        local found_sqli=0
        
        for payload in "${sql_payloads[@]}"; do
            local encoded_payload=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$payload'))" 2>/dev/null || echo "$payload")
            local response=$(curl -s -m 5 "${base_url}/?id=${encoded_payload}" 2>/dev/null || echo "")
            
            if echo "$response" | grep -iqE "sql|mysql|syntax|error|warning|database"; then
                echo -e "${RED}[!] Potential SQL Injection found!${NC}"
                echo "Payload: $payload" >> "${vuln_output}"
                found_sqli=1
            fi
        done
        
        if [[ $found_sqli -eq 0 ]]; then
            echo -e "${GREEN}[-] No obvious SQL injection detected${NC}"
        fi
    }
    
    # 2. Cross-Site Scripting (XSS) Detection
    echo -e "\n${CYAN}=== 2. CROSS-SITE SCRIPTING (XSS) DETECTION ===${NC}"
    info "Testing for XSS vulnerabilities..."
    {
        local xss_payload="<script>alert('XSS')</script>"
        local encoded_xss=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$xss_payload'))" 2>/dev/null || echo "$xss_payload")
        local response=$(curl -s -m 5 "${base_url}/?search=${encoded_xss}" 2>/dev/null || echo "")
        
        if echo "$response" | grep -q "<script>alert('XSS')</script>"; then
            echo -e "${RED}[!] Reflected XSS vulnerability found!${NC}"
            echo "Reflected XSS: $xss_payload" >> "${vuln_output}"
        else
            echo -e "${GREEN}[-] No reflected XSS detected in basic test${NC}"
        fi
    }
    
    # 3. Authentication & Session Management
    echo -e "\n${CYAN}=== 3. AUTHENTICATION & SESSION MANAGEMENT ===${NC}"
    info "Checking authentication mechanisms..."
    {
        local response=$(curl -s -i -m 5 "$base_url" 2>/dev/null | head -20)
        
        if echo "$response" | grep -iq "set-cookie"; then
            echo -e "${YELLOW}[*] Cookies detected${NC}"
            echo "$response" | grep -i "set-cookie" | head -n 3
        fi
        
        if echo "$response" | grep -iq "WWW-Authenticate"; then
            echo -e "${YELLOW}[*] Basic Authentication required${NC}"
        fi
        
        if ! echo "$response" | grep -iq "x-frame-options"; then
            echo -e "${YELLOW}[!] X-Frame-Options header missing (Clickjacking risk)${NC}"
            echo "Clickjacking: X-Frame-Options header missing" >> "${vuln_output}"
        fi
    }
    
    # 4. Sensitive Data Exposure
    echo -e "\n${CYAN}=== 4. SENSITIVE DATA EXPOSURE ===${NC}"
    info "Checking security headers..."
    {
        local response=$(curl -s -i -m 5 "$base_url" 2>/dev/null)
        local missing_headers=()
        
        if ! echo "$response" | grep -iq "strict-transport-security"; then
            missing_headers+=("HSTS")
        fi
        if ! echo "$response" | grep -iq "content-security-policy"; then
            missing_headers+=("CSP")
        fi
        if ! echo "$response" | grep -iq "x-content-type-options"; then
            missing_headers+=("X-Content-Type-Options")
        fi
        
        if [[ ${#missing_headers[@]} -gt 0 ]]; then
            echo -e "${RED}[!] Missing security headers: ${missing_headers[*]}${NC}"
            echo "Missing Headers: ${missing_headers[*]}" >> "${vuln_output}"
        else
            echo -e "${GREEN}[-] Basic security headers present${NC}"
        fi
    }
    
    # 5. Broken Access Control
    echo -e "\n${CYAN}=== 5. BROKEN ACCESS CONTROL ===${NC}"
    info "Testing for access control bypass..."
    {
        local admin_paths=("/admin" "/administrator" "/wp-admin" "/control" "/dashboard")
        local found_issues=0
        
        for path in "${admin_paths[@]}"; do
            local response=$(curl -s -m 5 -o /dev/null -w "%{http_code}" "${base_url}${path}" 2>/dev/null)
            
            if [[ "$response" == "200" ]]; then
                echo -e "${RED}[!] Admin path accessible: ${path}${NC}"
                echo "Broken AC: $path accessible" >> "${vuln_output}"
                found_issues=1
            fi
        done
        
        if [[ $found_issues -eq 0 ]]; then
            echo -e "${GREEN}[-] Common admin paths properly restricted${NC}"
        fi
    }
    
    # 6. XML External Entity (XXE)
    echo -e "\n${CYAN}=== 6. XMLL EXTERNAL ENTITY (XXE) INJECTION ===${NC}"
    info "Testing for XXE vulnerabilities..."
    {
        echo -e "${YELLOW}[*] XXE testing available on XML/SOAP endpoints${NC}"
        echo "[NOTE] Manual XXE testing required for specific endpoints" >> "${vuln_output}"
    }
    
    # 7. Insecure Deserialization
    echo -e "\n${CYAN}=== 7. INSECURE DESERIALIZATION ===${NC}"
    info "Checking for serialization indicators..."
    {
        local response=$(curl -s -m 5 "$base_url" 2>/dev/null)
        
        if echo "$response" | grep -qE "serialized|unserialize|pickle|marshal"; then
            echo -e "${YELLOW}[!] Potential serialization function detected${NC}"
            echo "Insecure Deserialization: Serialization methods detected" >> "${vuln_output}"
        else
            echo -e "${GREEN}[-] No obvious serialization issues${NC}"
        fi
    }
    
    # 8. Broken Authentication
    echo -e "\n${CYAN}=== 8. BROKEN AUTHENTICATION ===${NC}"
    info "Testing for weak authentication..."
    {
        # Check for default credentials
        local creds=("admin:admin" "admin:password" "admin:123456" "root:root")
        
        for cred in "${creds[@]}"; do
            local username="${cred%:*}"
            local password="${cred#*:}"
            local auth=$(echo -n "$cred" | base64)
            
            local response=$(curl -s -m 5 -H "Authorization: Basic $auth" "$base_url" -o /dev/null -w "%{http_code}" 2>/dev/null)
            
            if [[ "$response" == "200" ]] || [[ "$response" == "301" ]] || [[ "$response" == "302" ]]; then
                echo -e "${RED}[!] Default credentials may work: $username:$password${NC}"
                echo "Weak Auth: $cred might work" >> "${vuln_output}"
            fi
        done
    }
    
    # 9. Using Components with Known Vulnerabilities
    echo -e "\n${CYAN}=== 9. COMPONENTS WITH KNOWN VULNERABILITIES ===${NC}"
    info "Detecting server and framework versions..."
    {
        local response=$(curl -s -i -m 5 "$base_url" 2>/dev/null | head -20)
        
        echo "$response" | grep -iE "Server:|X-Powered-By:" | while read -r line; do
            echo -e "${YELLOW}[*] $line${NC}"
            echo "$line" >> "${vuln_output}"
        done
    }
    
    # 10. Insufficient Logging & Monitoring
    echo -e "\n${CYAN}=== 10. INSUFFICIENT LOGGING & MONITORING ===${NC}"
    info "Checking for logging endpoints..."
    {
        local logging_paths=("/logs" "/access.log" "/error.log" "/var/log")
        
        for path in "${logging_paths[@]}"; do
            local response=$(curl -s -m 5 -o /dev/null -w "%{http_code}" "${base_url}${path}" 2>/dev/null)
            
            if [[ "$response" == "200" ]]; then
                echo -e "${YELLOW}[!] Logging endpoint exposed: ${path}${NC}"
                echo "Log Exposure: $path accessible" >> "${vuln_output}"
            fi
        done
    }
    
    success "OWASP Top 10 vulnerability scan completed. Results saved to $vuln_output"
}

################################################################################
# Main Execution
################################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--target)
                TARGET="$2"
                shift 2
                ;;
            -s|--scan)
                SCAN_TYPE="$2"
                shift 2
                ;;
            -p|--ports)
                PORT_RANGE="$2"
                shift 2
                ;;
            -T|--threads)
                THREADS="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Print banner
    print_banner
    
    # Validate target
    if [[ -z "$TARGET" ]]; then
        error_exit "Target is required. Use -t or --target option"
    fi
    
    if ! validate_target "$TARGET"; then
        error_exit "Invalid target format. Please provide a valid IP or domain"
    fi
    
    # Initialize report
    {
        echo "═══════════════════════════════════════════════════════════════════"
        echo "RECONNAISSANCE & VULNERABILITY SCAN REPORT"
        echo "═══════════════════════════════════════════════════════════════════"
        echo "Target: $TARGET"
        echo "Scan Date: $(date)"
        echo "Scan Type: ${SCAN_TYPE:-all}"
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
    } | tee "${REPORT_FILE}"
    
    info "Starting reconnaissance and vulnerability scan on $TARGET"
    log "INFO" "Scan initiated for target: $TARGET"
    
    # Set default scan type
    SCAN_TYPE="${SCAN_TYPE:-all}"
    
    # Execute scans based on type
    case $SCAN_TYPE in
        all)
            scan_ports "$TARGET" "$PORT_RANGE"
            scan_directories "$TARGET"
            scan_subdomains "$TARGET"
            scan_owasp_vulnerabilities "$TARGET"
            ;;
        ports)
            scan_ports "$TARGET" "$PORT_RANGE"
            ;;
        directories)
            scan_directories "$TARGET"
            ;;
        subdomains)
            scan_subdomains "$TARGET"
            ;;
        vuln)
            scan_owasp_vulnerabilities "$TARGET"
            ;;
        *)
            error_exit "Unknown scan type: $SCAN_TYPE"
            ;;
    esac
    
    # Final summary
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Scan Complete!${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    success "Report saved to: $REPORT_FILE"
    success "Detailed log saved to: $LOG_FILE"
    info "Results directory: $OUTPUT_DIR"
    
    # Display summary
    echo -e "\n${YELLOW}Summary:${NC}"
    echo "  - Target: $TARGET"
    echo "  - Scans performed: $SCAN_TYPE"
    echo "  - Output files generated:"
    ls -lh "${OUTPUT_DIR}" | grep "${TIMESTAMP}" | awk '{print "    * " $NF}'
    
    echo -e "\n${YELLOW}Next Steps:${NC}"
    echo "  1. Review the full report: cat $REPORT_FILE"
    echo "  2. Check individual scan results in: $OUTPUT_DIR"
    echo "  3. Investigate high-severity findings"
    echo "  4. Prioritize remediation efforts"
    
    echo -e "\n${BLUE}Remember: Always obtain proper authorization before scanning!${NC}\n"
}

# Run main function
main "$@"
