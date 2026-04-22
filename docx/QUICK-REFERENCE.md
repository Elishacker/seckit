# SecKit - Quick Reference

## One-Liner Commands

### Setup & Initialization

```bash
# Install dependencies (run once)
./seckit start
```

### Basic Scans

```bash
# Full reconnaissance on domain
./seckit -t example.com

# Full reconnaissance on IP
./seckit -t 192.168.1.100

# Full scan with verbose output
./seckit -t target.com -v
```

### Port Scanning

```bash
# Scan top 1000 ports
./seckit -t target.com -s ports -p 1-1000

# Scan specific ports
./seckit -t target.com -s ports -p 22,80,443,3306,5432

# Full port range scan
./seckit -t target.com -s ports -p 1-65535
```

### Directory Enumeration

```bash
# Standard directory brute force
./seckit -t example.com -s dir

# With verbose output
./seckit -t example.com -s dir -v
```

### Subdomain Discovery

```bash
# Enumerate subdomains
./seckit -t example.com -s dom

# For IP addresses (reverse DNS)
./seckit -t 192.168.1.100 -s dom
```

### Vulnerability Scanning

```bash
# OWASP Top 10 scan
./seckit -t example.com -s vuln

# With verbose output
./seckit -t example.com -s vuln -v
```

### Multiple Scans

```bash
# Combine ports and directories
./seckit -t example.com -s ports,dir

# Combine ports, directories, and vulnerabilities
./seckit -t example.com -s ports,dir,vuln

# Combine all subdomains and vulnerabilities
./seckit -t example.com -s dom,vuln
```

### Analysis & Reporting

```bash
# Analyze latest scan results
./seckit analyse

# Generate professional report
./seckit analyse
```

## Advanced Usage

### Multi-Threading

```bash
# Faster scans with 20 threads
./seckit -t example.com -T 20

# Conservative 5 threads
./seckit -t example.com -T 5
```

### Sequential Scanning

```bash
# Run scans one by one
./seckit -t example.com -s ports
./seckit -t example.com -s dir

# Or run multiple scans together
./seckit -t example.com -s ports,dir
```

### Full Investigation

```bash
# Run all scans in one command
./seckit -t target.com -s all -v

# Or run specific combination of scans
./seckit -t target.com -s ports,dir,dom,vuln

# Quick focus on web and vulnerabilities
./seckit -t target.com -s dir,vuln -v
```

## Output Files

```
scan_results/
├── scan_report_YYYYMMDD_HHMMSS.txt              # Main findings report
├── scan_log_YYYYMMDD_HHMMSS.log                 # Detailed activities
├── nmap_target_YYYYMMDD_HHMMSS.txt              # Nmap output
├── directories_target_YYYYMMDD_HHMMSS.txt       # Directory findings
├── subdomains_target_YYYYMMDD_HHMMSS.txt        # Subdomain results
└── vulnerabilities_target_YYYYMMDD_HHMMSS.txt   # Vulnerability findings

analysis_reports/
└── analysis_YYYYMMDD_HHMMSS.txt                 # Professional analysis report
```

### View Results

```bash
# Read main report
cat scan_results/scan_report_*.txt

# Read scan log
tail -100 scan_results/scan_log_*.log

# See all results
ls -lh scan_results/
```

## Common Findings Interpretation

### Port Status Codes

| Status | Meaning |
|--------|---------|
| open | Port is listening |
| closed | Port is closed |
| filtered | Firewall blocked |
| open\|filtered | Uncertain status |
| unfiltered | Port exists but not probed |

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Page exists |
| 301/302 | Redirect found |
| 403 | Forbidden - Access denied |
| 404 | Not found |
| 500 | Server error |

### Vulnerability Severity

| Level | Color | Action |
|-------|-------|--------|
| CRITICAL | 🔴 Red | Fix immediately |
| HIGH | 🟠 Orange | Fix soon |
| MEDIUM | 🟡 Yellow | Plan remediation |
| LOW | 🟢 Green | Document & monitor |

## Real-World Scenarios

### Scenario 1: Quick Security Check

```bash
# Initial assessment of known web app
./seckit -t myapp.example.com -s all -v

# Check results
cat scan_results/scan_report_*.txt | less
```

### Scenario 2: Deep Network Reconnaissance

```bash
# Comprehensive internal network scan
./seckit -t 192.168.1.100 -s all -T 20 -p 1-5000

# Review everything
for file in scan_results/*; do echo "=== $file ==="; head -20 "$file"; done
```

### Scenario 3: Targeted Web Application Assessment

```bash
# Web app focused scan
./seckit -t webapp.target.com -s dir
./seckit -t webapp.target.com -s vuln -v

# Investigate findings
cat scan_results/vulnerabilities_*.txt
```

### Scenario 4: Subdomain Mapping

```bash
# Find all subdomains and check services
./seckit -t target.com -s dom
./seckit -t target.com -s ports -p 1-1000
```

## Automation Examples

### Run Daily Scan

```bash
#!/bin/bash
TARGET="example.com"
TIMESTAMP=$(date +"%Y%m%d")
RESULTS="/var/log/security-scans/${TIMESTAMP}_${TARGET}.txt"

mkdir -p /var/log/security-scans/
/home/user/Scripts/seckit -t "$TARGET" > "$RESULTS" 2>&1

echo "Scan complete: $RESULTS" | mail -s "Daily Scan: $TARGET" admin@example.com
```

### Compare Scans Over Time

```bash
# Store baseline
./seckit -t target.com -s all 2>&1 | tee baseline_$(date +%Y%m%d).txt

# Future comparison
./seckit -t target.com -s all 2>&1 | tee current_$(date +%Y%m%d).txt

# Diff the findings
diff baseline_*.txt current_*.txt
```

### Batch Scanning Multiple Targets

```bash
#!/bin/bash
TARGETS=("target1.com" "target2.com" "target3.com")

for target in "${TARGETS[@]}"; do
    echo "Scanning $target..."
    ./seckit -t "$target" -s all
    sleep 300  # Wait 5 minutes between scans
done
```

## Troubleshooting Quick Fixes

### Script Won't Run

```bash
# Make it executable
chmod +x seckit

# Or run with bash explicitly
bash seckit -t target.com
```

### Missing Nmap

```bash
# Ubuntu/Debian
sudo apt-get install nmap

# Or use setup script
bash setup-dependencies.sh
```

### Connection Timeouts

```bash
# Verify target reachability
ping target.com

# Check if web service is running
curl -v http://target.com

# Check specific port
nc -zv target.com 80
```

### Permission Denied Errors

```bash
# Some scans need sudo
sudo ./seckit -t target.com

# Or install with sudo access configured
sudo ./setup-dependencies.sh
```

## Important Options Reference

| Option | Description |
|--------|-------------|
| TARGET | Required - Must be valid IP or domain |
| -s/--scan | all\|ports\|dir\|dom\|vuln |
| -p/--ports | Port range, e.g., 1-1000 or 22,80,443 |
| -T/--threads | Number of parallel threads (default 10) |
| -v/--verbose | Enable verbose output |
| -h/--help | Show full help menu |

## Security Best Practices

### ✅ DO:
- Get written authorization first
- Document scope with client
- Run during agreed times
- Keep detailed logs
- Report findings responsibly
- Test in controlled environments first

### ❌ DON'T:
- Scan without permission
- Cross outside defined scope
- Run on production without approval
- Publicly disclose vulnerabilities
- Use malicious payloads
- Ignore legal requirements

## Output File Locations

All results are saved in: `~/Scripts/scan_results/`

Access them quickly:

```bash
cd ~/Scripts/scan_results
ls -lt              # View latest files
cat *.txt           # View all reports
tail -f scan_log_*  # Watch live log
```

## Legal Reminder

⚠️ **AUTHORIZATION REQUIRED**

This tool should only be used on systems you own or have explicit written permission to test. Unauthorized access to computer systems is illegal in most jurisdictions.

Always:
- Obtain proper authorization
- Define testing scope
- Follow responsible disclosure
- Comply with local laws

For full documentation, see: [README.md](README.md)
