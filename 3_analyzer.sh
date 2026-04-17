#!/bin/bash

################################################################################
# Vulnerability Analyzer & Report Generator
# Analyzes scan results and generates actionable reports
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAN_RESULTS="${SCRIPT_DIR}/scan_results"
ANALYSIS_OUTPUT="${SCRIPT_DIR}/analysis_reports"

# Create analysis directory
mkdir -p "${ANALYSIS_OUTPUT}"

# Timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ANALYSIS_REPORT="${ANALYSIS_OUTPUT}/analysis_${TIMESTAMP}.txt"

# ============================================================================
# Utility Functions
# ============================================================================

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
    ║     VULNERABILITY ANALYZER & REPORT GENERATOR v1.0          ║
    ║   Professional Vulnerability Assessment Tool                ║
    ║     Developed By Elifaster InfoSec                          ║
    ╚══════════════════════════════════════════════════════════════╝
    
EOF
    echo -e "${NC}"
}

log_analysis() {
    echo -e "$1" | tee -a "${ANALYSIS_REPORT}"
}

print_header() {
    echo -e "\n${CYAN}════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}\n"
}

# ============================================================================
# Analysis Functions
# ============================================================================

analyze_ports() {
    local nmap_file="$1"
    
    print_header "PORT ANALYSIS"
    
    if [[ ! -f "$nmap_file" ]]; then
        log_analysis "${YELLOW}No Nmap results found${NC}"
        return
    fi
    
    log_analysis "${BLUE}=== Open Ports Summary ===${NC}"
    
    # Count open ports
    local open_count=$(grep "^[0-9].*/open" "$nmap_file" | wc -l)
    local closed_count=$(grep "^[0-9].*/closed" "$nmap_file" | wc -l)
    local filtered_count=$(grep "^[0-9].*/filtered" "$nmap_file" | wc -l)
    
    log_analysis "Total Open Ports: ${GREEN}$open_count${NC}"
    log_analysis "Total Closed Ports: $closed_count"
    log_analysis "Total Filtered Ports: ${YELLOW}$filtered_count${NC}\n"
    
    # Show risky services
    log_analysis "${BLUE}=== Potentially Risky Services ===${NC}"
    grep -E "open.*ftp|telnet|smtp|snmp|nfs|rsh|rlogin|bootpc" "$nmap_file" | while read line; do
        log_analysis "${RED}⚠ $line${NC}"
    done
    
    # Show verified services
    log_analysis "\n${BLUE}=== Verified Services ===${NC}"
    grep "^[0-9].*/open.*http" "$nmap_file" | head -n 5 | while read line; do
        log_analysis "${GREEN}✓ $line${NC}"
    done
}

analyze_directories() {
    local dir_file="$1"
    
    print_header "DIRECTORY ENUMERATION ANALYSIS"
    
    if [[ ! -f "$dir_file" ]]; then
        log_analysis "${YELLOW}No directory results found${NC}"
        return
    fi
    
    log_analysis "${BLUE}=== Directory Summary ===${NC}"
    
    # Count status codes
    local status_200=$(grep "\[200\]" "$dir_file" | wc -l)
    local status_301=$(grep "\[301\]" "$dir_file" | wc -l)
    local status_302=$(grep "\[302\]" "$dir_file" | wc -l)
    local status_403=$(grep "\[403\]" "$dir_file" | wc -l)
    
    log_analysis "Accessible Directories [200]: ${GREEN}$status_200${NC}"
    log_analysis "Redirects [301/302]: ${YELLOW}$((status_301 + status_302))${NC}"
    log_analysis "Forbidden [403]: ${RED}$status_403${NC}\n"
    
    # Show sensitive paths
    log_analysis "${BLUE}=== Potentially Sensitive Paths ===${NC}"
    grep -E "\[200\].*(admin|backup|config|database|private|secret|test|old)" "$dir_file" | while read line; do
        log_analysis "${RED}⚠️ $line${NC}"
    done
    
    # Show accessible directories
    log_analysis "\n${BLUE}=== Top Accessible Directories ===${NC}"
    grep "\[200\]" "$dir_file" | head -n 10 | while read line; do
        log_analysis "${GREEN}✓ $line${NC}"
    done
}

analyze_subdomains() {
    local subdomain_file="$1"
    
    print_header "SUBDOMAIN ANALYSIS"
    
    if [[ ! -f "$subdomain_file" ]]; then
        log_analysis "${YELLOW}No subdomain results found${NC}"
        return
    fi
    
    log_analysis "${BLUE}=== Subdomain Summary ===${NC}"
    
    local subdomain_count=$(wc -l < "$subdomain_file")
    log_analysis "Total Subdomains Found: ${GREEN}$subdomain_count${NC}\n"
    
    log_analysis "${BLUE}=== Discovered Subdomains ===${NC}"
    cat "$subdomain_file" | head -n 20 | while read line; do
        if [[ -n "$line" ]]; then
            log_analysis "${GREEN}✓ $line${NC}"
        fi
    done
    
    if [[ $subdomain_count -gt 20 ]]; then
        log_analysis "\n${YELLOW}... and $((subdomain_count - 20)) more subdomains${NC}"
    fi
}

analyze_vulnerabilities() {
    local vuln_file="$1"
    
    print_header "VULNERABILITY ASSESSMENT"
    
    if [[ ! -f "$vuln_file" ]]; then
        log_analysis "${YELLOW}No vulnerability results found${NC}"
        return
    fi
    
    # Count vulnerability types
    local sqli_issues=$(grep -c "SQL Injection\|Injection: SQL" "$vuln_file" || true)
    local xss_issues=$(grep -c "XSS\|script injection" "$vuln_file" || true)
    local auth_issues=$(grep -c "Authentication\|Weak Auth" "$vuln_file" || true)
    local exposure_issues=$(grep -c "Missing Headers\|Sensitive Data" "$vuln_file" || true)
    local access_issues=$(grep -c "Access\|unauthorized" "$vuln_file" || true)
    
    log_analysis "${BLUE}=== Vulnerability Summary ===${NC}\n"
    
    [[ $sqli_issues -gt 0 ]] && log_analysis "${RED}[CRITICAL] SQL Injection Issues: $sqli_issues${NC}"
    [[ $xss_issues -gt 0 ]] && log_analysis "${RED}[HIGH] XSS Issues: $xss_issues${NC}"
    [[ $auth_issues -gt 0 ]] && log_analysis "${YELLOW}[HIGH] Authentication Issues: $auth_issues${NC}"
    [[ $exposure_issues -gt 0 ]] && log_analysis "${YELLOW}[MEDIUM] Data Exposure Issues: $exposure_issues${NC}"
    [[ $access_issues -gt 0 ]] && log_analysis "${YELLOW}[MEDIUM] Access Control Issues: $access_issues${NC}"
    
    if [[ $sqli_issues -eq 0 ]] && [[ $xss_issues -eq 0 ]] && [[ $auth_issues -eq 0 ]]; then
        log_analysis "${GREEN}No critical vulnerabilities detected${NC}"
    fi
    
    log_analysis "\n${BLUE}=== Detailed Findings ===${NC}"
    cat "$vuln_file" | head -n 50
}

# ============================================================================
# Risk Assessment
# ============================================================================

calculate_risk_score() {
    local nmap_file="$1"
    local vuln_file="$2"
    
    local risk_score=20  # Base score
    
    # Add points for open ports
    if [[ -f "$nmap_file" ]]; then
        local open_ports=$(grep "^[0-9].*/open" "$nmap_file" | wc -l)
        risk_score=$((risk_score + (open_ports * 2)))
        
        # High-risk services
        if grep -q "^[0-9].*/open.*ftp" "$nmap_file"; then
            risk_score=$((risk_score + 20))
        fi
        if grep -q "^[0-9].*/open.*telnet" "$nmap_file"; then
            risk_score=$((risk_score + 25))
        fi
        if grep -q "^[0-9].*/open.*smtp" "$nmap_file"; then
            risk_score=$((risk_score + 10))
        fi
    fi
    
    # Add points for vulnerabilities
    if [[ -f "$vuln_file" ]]; then
        local crit_count=$(grep -c "CRITICAL\|SQL Injection" "$vuln_file" || true)
        local high_count=$(grep -c "HIGH\|XSS" "$vuln_file" || true)
        local med_count=$(grep -c "MEDIUM" "$vuln_file" || true)
        
        risk_score=$((risk_score + (crit_count * 30) + (high_count * 15) + (med_count * 5)))
    fi
    
    # Cap at 100
    if [[ $risk_score -gt 100 ]]; then
        risk_score=100
    fi
    
    echo $risk_score
}

print_risk_assessment() {
    local score="$1"
    
    print_header "RISK ASSESSMENT"
    
    local color=""
    local level=""
    
    if [[ $score -le 25 ]]; then
        color="${GREEN}"
        level="LOW RISK"
    elif [[ $score -le 50 ]]; then
        color="${YELLOW}"
        level="MEDIUM RISK"
    elif [[ $score -le 75 ]]; then
        color="${YELLOW}"
        level="HIGH RISK"
    else
        color="${RED}"
        level="CRITICAL RISK"
    fi
    
    log_analysis "${color}Risk Score: ${score}/100 - ${level}${NC}\n"
    
    # Visual bar
    echo -n "Risk Level: "
    for ((i=0; i<score/10; i++)); do
        echo -n "█"
    done
    for ((i=score/10; i<10; i++)); do
        echo -n "░"
    done
    echo -e " ${color}${score}%${NC}\n" | tee -a "${ANALYSIS_REPORT}"
}

# ============================================================================
# Recommendations
# ============================================================================

generate_recommendations() {
    local nmap_file="$1"
    local vuln_file="$2"
    
    print_header "REMEDIATION RECOMMENDATIONS"
    
    log_analysis "${BLUE}=== Immediate Actions (Critical) ===${NC}\n"
    
    # Check for SQL injection
    if [[ -f "$vuln_file" ]] && grep -q "SQL Injection" "$vuln_file"; then
        log_analysis "${RED}1. SQL Injection Vulnerability Detected${NC}"
        log_analysis "   Action: Implement parameterized queries and input validation"
        log_analysis "   Priority: CRITICAL\n"
    fi
    
    # Check for XSS
    if [[ -f "$vuln_file" ]] && grep -q "XSS\|script" "$vuln_file"; then
        log_analysis "${RED}2. Cross-Site Scripting Vulnerability Detected${NC}"
        log_analysis "   Action: Implement output encoding and CSP headers"
        log_analysis "   Priority: CRITICAL\n"
    fi
    
    # Check for weak authentication
    if [[ -f "$vuln_file" ]] && grep -q "Weak Auth\|default" "$vuln_file"; then
        log_analysis "${YELLOW}3. Weak Authentication Detected${NC}"
        log_analysis "   Action: Enforce strong passwords and MFA"
        log_analysis "   Priority: HIGH\n"
    fi
    
    # Check for missing security headers
    if [[ -f "$vuln_file" ]] && grep -q "Missing Headers" "$vuln_file"; then
        log_analysis "${YELLOW}4. Missing Security Headers${NC}"
        log_analysis "   Action: Add HSTS, CSP, X-Frame-Options headers"
        log_analysis "   Priority: MEDIUM\n"
    fi
    
    # Check for unnecessary services
    if [[ -f "$nmap_file" ]] && grep -q "ftp.*open\|telnet.*open" "$nmap_file"; then
        log_analysis "${YELLOW}5. Insecure Legacy Services Running${NC}"
        log_analysis "   Action: Disable FTP/Telnet, use SFTP/SSH instead"
        log_analysis "   Priority: HIGH\n"
    fi
    
    log_analysis "${BLUE}=== Standard Security Practices ===${NC}\n"
    log_analysis "• Keep all software updated and patched"
    log_analysis "• Implement proper access controls"
    log_analysis "• Monitor logs for suspicious activity"
    log_analysis "• Conduct regular security assessments"
    log_analysis "• Implement Web Application Firewall (WAF)"
    log_analysis "• Use HTTPS/TLS for all communications"
    log_analysis "• Implement rate limiting and DDoS protection"
}

# ============================================================================
# Main Analysis Function
# ============================================================================

analyze_scan_results() {
    local target_pattern="$1"
    
    print_header "STARTING VULNERABILITY ANALYSIS"
    
    {
        echo "═══════════════════════════════════════════════════════════════════"
        echo "VULNERABILITY ANALYSIS REPORT"
        echo "═══════════════════════════════════════════════════════════════════"
        echo "Generated: $(date)"
        echo "Target Pattern: $target_pattern"
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
    } > "${ANALYSIS_REPORT}"
    
    # Find relevant files
    local nmap_file=$(ls "${SCAN_RESULTS}"/nmap_*"${target_pattern}"*.txt 2>/dev/null | head -n 1)
    local dir_file=$(ls "${SCAN_RESULTS}"/directories_*"${target_pattern}"*.txt 2>/dev/null | head -n 1)
    local subdomain_file=$(ls "${SCAN_RESULTS}"/subdomains_*"${target_pattern}"*.txt 2>/dev/null | head -n 1)
    local vuln_file=$(ls "${SCAN_RESULTS}"/vulnerabilities_*"${target_pattern}"*.txt 2>/dev/null | head -n 1)
    
    # Run analyses
    analyze_ports "${nmap_file}"
    analyze_directories "${dir_file}"
    analyze_subdomains "${subdomain_file}"
    analyze_vulnerabilities "${vuln_file}"
    
    # Calculate and display risk score
    local risk_score=$(calculate_risk_score "${nmap_file}" "${vuln_file}")
    print_risk_assessment "$risk_score"
    
    # Generate recommendations
    generate_recommendations "${nmap_file}" "${vuln_file}"
    
    # Final summary
    print_header "ANALYSIS SUMMARY"
    
    log_analysis "${GREEN}Analysis Complete!${NC}"
    log_analysis "\nReport saved to: ${ANALYSIS_REPORT}"
    log_analysis "\n${BLUE}Next Steps:${NC}"
    log_analysis "1. Review all findings in detail"
    log_analysis "2. Prioritize vulnerabilities by severity"
    log_analysis "3. Create remediation tickets"
    log_analysis "4. Implement fixes systematically"
    log_analysis "5. Re-test after remediation"
}

# ============================================================================
# Main Execution
# ============================================================================

show_usage() {
    cat << EOF
${CYAN}Usage: $0 [OPTIONS]${NC}

${YELLOW}Options:${NC}
    -t, --target <pattern>     Target pattern to analyze (required)
    -a, --all                  Analyze all available scans
    -l, --list                 List available scan results
    -h, --help                 Display this help message

${YELLOW}Examples:${NC}
    $0 -t example.com
    $0 -t 192.168.1.100
    $0 -a
    $0 -l

${NC}
EOF
}

# Parse arguments
print_banner

if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

# Display banner unless just showing help or listing
if [[ "$1" != "-h" ]] && [[ "$1" != "--help" ]] && [[ "$1" != "-l" ]] && [[ "$1" != "--list" ]]; then
    echo ""  # Add spacing after banner
fi

case "${1:-}" in
    -t|--target)
        if [[ $# -lt 2 ]]; then
            echo -e "${RED}Error: Target pattern required${NC}"
            show_usage
            exit 1
        fi
        analyze_scan_results "$2"
        ;;
    -a|--all)
        # Find all scan results and analyze
        for scan in "${SCAN_RESULTS}"/scan_report_*.txt; do
            if [[ -f "$scan" ]]; then
                target=$(grep "Target:" "$scan" | head -n 1 | awk '{print $NF}')
                [[ -n "$target" ]] && analyze_scan_results "${target//./_}"
            fi
        done
        ;;
    -l|--list)
        echo -e "${CYAN}Available Scan Results:${NC}\n"
        find "${SCAN_RESULTS}" -type f -name "*.txt" -o -name "*.log" 2>/dev/null | sort -r | head -n 20
        echo -e "\n${BLUE}Scan Results Location:${NC} ${SCAN_RESULTS}"
        ;;
    -h|--help)
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        show_usage
        exit 1
        ;;
esac

echo -e "\n${BLUE}Analysis reports saved to: ${ANALYSIS_OUTPUT}${NC}"
