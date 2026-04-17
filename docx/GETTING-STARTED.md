# Getting Started Guide - Reconnaissance & Vulnerability Scanner

A complete guide to setting up and using the professional reconnaissance and vulnerability scanning toolkit.

## 📋 Quick Start (5 Minutes)

### Step 1: Install Dependencies
```bash
cd ~/Scripts
bash setup-dependencies.sh
```

### Step 2: Run Your First Scan
```bash
./recon-vuln-scanner.sh -t example.com
```

### Step 3: View Results
```bash
cat scan_results/scan_report_*.txt | less
```

## 🔧 Complete Setup

### System Requirements
- **OS**: Linux (Ubuntu, Debian, CentOS, Fedora, Arch)
- **Shell**: Bash 4.0+
- **Storage**: 500MB minimum for tool installation
- **Network**: Internet connection for external target scanning
- **Privileges**: Root/sudo for some advanced features

### Installation Steps

#### 1. Verify Files
```bash
ls -la ~/Scripts/
# Should show:
# - recon-vuln-scanner.sh
# - setup-dependencies.sh
# - vulnerability-analyzer.sh
# - README.md
# - QUICK-REFERENCE.md
# - config.template
# - GETTING-STARTED.md (this file)
```

#### 2. Make Scripts Executable
```bash
chmod +x ~/Scripts/*.sh
```

#### 3. Install Required Tools
```bash
# Option A: Automatic installation
cd ~/Scripts
bash setup-dependencies.sh

# Option B: Manual installation for Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y nmap curl dnsutils python3

# Option C: Manual installation for CentOS/RHEL
sudo yum install -y nmap curl bind-utils python3

# Option D: Manual installation for macOS
brew install nmap curl bind-tools python3
```

#### 4. Verify Installation
```bash
./recon-vuln-scanner.sh -h
```

## 📚 Understanding the Tools

### Main Scanner: `recon-vuln-scanner.sh`
The primary reconnaissance and vulnerability assessment tool.

#### Capabilities:
1. **Port & Service Scanning** - Uses Nmap for comprehensive port discovery
2. **Directory Enumeration** - Brute-forces directories on web services
3. **Subdomain Discovery** - Enumerates DNS subdomains
4. **OWASP Top 10 Assessment** - Tests for common web vulnerabilities

#### Key Features:
- Automatic protocol detection (HTTP/HTTPS)
- Multi-threaded scanning
- Comprehensive logging
- Timestamped results
- Color-coded output

### Vulnerability Analyzer: `vulnerability-analyzer.sh`
Processes and analyzes scan results to provide actionable insights.

#### Features:
- Risk score calculation
- Vulnerability categorization
- Remediation recommendations
- Threat assessment
- Summary reports

### Support Files:
- **README.md** - Full documentation
- **QUICK-REFERENCE.md** - Command cheat sheet
- **config.template** - Configuration options
- **setup-dependencies.sh** - Dependency installer

## 🎯 Common Workflows

### Workflow 1: Initial Target Assessment

Perfect for first-time reconnaissance on a new target.

```bash
#!/bin/bash
TARGET="example.com"

# Step 1: Scan for open ports and services
echo "Scanning ports..."
./recon-vuln-scanner.sh -t "$TARGET" -s ports -p 1-5000

# Wait for user review
echo "Review port scan results? (press enter)"
read

# Step 2: Enumerate directories
echo "Enumerating directories..."
./recon-vuln-scanner.sh -t "$TARGET" -s directories

# Step 3: Find subdomains
echo "Discovering subdomains..."
./recon-vuln-scanner.sh -t "$TARGET" -s subdomains

# Step 4: Check for vulnerabilities
echo "Scanning for vulnerabilities..."
./recon-vuln-scanner.sh -t "$TARGET" -s vuln

# Step 5: Analyze results
echo "Analyzing results..."
./vulnerability-analyzer.sh -t "$TARGET"

echo "Complete! Check scan_results/ for all findings"
```

### Workflow 2: Rapid Web App Assessment

Quick assessment of a web application.

```bash
TARGET="webapp.example.com"

# Fast vulnerability scan
./recon-vuln-scanner.sh -t "$TARGET" -s vuln -v

# Directory enumeration with common paths
./recon-vuln-scanner.sh -t "$TARGET" -s directories

# Analyze findings
./vulnerability-analyzer.sh -t "$TARGET"
```

### Workflow 3: Network Reconnaissance

Deep network analysis for infrastructure assessment.

```bash
NETWORK="192.168.1.0/24"

for IP in 192.168.1.{1..254}; do
    # Quick ping to see if alive
    if ping -c 1 -W 1 "$IP" &>/dev/null; then
        echo "Scanning $IP..."
        ./recon-vuln-scanner.sh -t "$IP" -s ports -p 1-1000
    fi
done
```

### Workflow 4: Continuous Security Monitoring

Regular security scans on production systems.

```bash
# Create monitoring script
cat > monitor.sh << 'EOF'
#!/bin/bash
TARGET="$1"
SCAN_DIR="scans/$(date +%Y%m%d)"
mkdir -p "$SCAN_DIR"

cd "$SCAN_DIR"
../../recon-vuln-scanner.sh -t "$TARGET" -s all
../../vulnerability-analyzer.sh -t "$TARGET"
EOF

chmod +x monitor.sh

# Run weekly
(crontab -l 2>/dev/null; echo "0 2 * * 0 cd ~/Scripts && bash monitor.sh example.com") | crontab -
```

## 📊 Understanding Results

### Result Files

All results are stored in `scan_results/` directory:

```
scan_results/
├── scan_report_20240417_120530.txt          # Main findings
├── scan_log_20240417_120530.log             # Detailed log
├── nmap_example_com_20240417_120530.txt     # Port scan
├── directories_example_com_20240417_120530.txt
├── subdomains_example_com_20240417_120530.txt
└── vulnerabilities_example_com_20240417_120530.txt
```

### Port Scan Results

```
22/tcp    open     ssh       OpenSSH 7.4
80/tcp    open     http      Apache httpd 2.4.6
443/tcp   open     https     Apache httpd 2.4.6
3306/tcp  open     mysql     MySQL 5.7.31
```

**What it means:**
- `22/tcp open ssh` - SSH service accessible (use port 22)
- `80/tcp open http` - Web server on port 80
- `3306/tcp open mysql` - MySQL database accessible ⚠️

### Directory Results

```
[200] http://example.com/admin        ← Accessible
[200] http://example.com/backup       ← Contains data
[301] http://example.com/old          ← Redirects
[403] http://example.com/private      ← Forbidden
```

**Severity mapping:**
- 200 = Accessible (investigate)
- 301/302 = Redirects (check destination)
- 403 = Forbidden (likely sensitive)
- 404 = Not found (safe)

### Subdomain Results

```
www.example.com -> 203.0.113.50
mail.example.com -> 203.0.113.51
ftp.example.com -> 203.0.113.50
api.example.com -> 203.0.113.52
admin.example.com -> 203.0.113.50
```

### Vulnerability Results

```
[CRITICAL] Potential SQL Injection found
[HIGH] Reflected XSS vulnerability found  
[MEDIUM] Missing security headers (CSP, HSTS)
[MEDIUM] Default credentials might work
[LOW] Admin path accessible: /admin
```

## 🛡️ OWASP Top 10 Explained

### 1. SQL Injection
**What**: Database queries can be manipulated
**Risk**: Data theft, modification, deletion
**Example**: Entering `' OR '1'='1` in a login field
**Fix**: Use parameterized queries

### 2. Cross-Site Scripting (XSS)
**What**: Malicious JavaScript injected into web pages
**Risk**: Session theft, malware distribution
**Example**: `<script>alert('hacked')</script>` in search box
**Fix**: Encode output, implement CSP

### 3. Authentication & Session Management
**What**: Weak password policies or session handling
**Risk**: Account takeover
**Example**: Default credentials (admin/admin)
**Fix**: Enforce strong passwords, implement MFA

### 4. Sensitive Data Exposure
**What**: Missing security headers and unencrypted data
**Risk**: Data interception
**Example**: Missing HSTS header
**Fix**: Use HTTPS, add security headers

### 5. Broken Access Control
**What**: Users can access unauthorized resources
**Risk**: Privilege escalation
**Example**: `/admin` accessible to non-admins
**Fix**: Implement proper authorization checks

### 6. XML External Entity (XXE)
**What**: XML parsers process external entities
**Risk**: Data disclosure, DoS
**Example**: XML files with external entity references
**Fix**: Disable external entity processing

### 7. Insecure Deserialization
**What**: Untrusted data causing code execution
**Risk**: Remote code execution
**Example**: Deserializing user-provided objects
**Fix**: Validate and sign serialized data

### 8. Broken Authentication
**What**: Authentication mechanisms are weak
**Risk**: Unauthorized access
**Example**: Plaintext passwords, no rate limiting
**Fix**: Strong auth, rate limiting, MFA

### 9. Components with Known Vulnerabilities
**What**: Using outdated software with known CVEs
**Risk**: Exploitation of known flaws
**Example**: Apache 2.2 with CVE-2024-XXXX
**Fix**: Keep all software updated

### 10. Insufficient Logging & Monitoring
**What**: Lack of security event logging
**Risk**: Breaches going undetected
**Example**: No monitoring of failed login attempts
**Fix**: Implement comprehensive logging

## 🚀 Advanced Usage

### Custom Wordlist for Directories

```bash
# Create custom wordlist
cat > custom_wordlist.txt << 'EOF'
custom-admin
internal-api
private-backup
test-config
staging-portal
EOF

# Use it in scanning
cp custom_wordlist.txt scan_results/directory_wordlist.txt
./recon-vuln-scanner.sh -t example.com -s directories
```

### Scanning Multiple Targets

```bash
#!/bin/bash
TARGETS=(
    "target1.com"
    "target2.com"
    "target3.com"
)

for target in "${TARGETS[@]}"; do
    echo "Scanning $target..."
    ./recon-vuln-scanner.sh -t "$target" -s all
    sleep 300  # Wait 5 minutes between scans
done
```

### Filtering Results

```bash
# Find all SQL injection vulnerabilities
grep -r "SQL Injection" scan_results/

# Find all open admin panels
grep "\[200\].*admin" scan_results/directories_*.txt

# Find risky services
grep -E "ftp|telnet|smtp|snmp" scan_results/nmap_*.txt
```

### Combining Tools

```bash
# Detailed port analysis
nmap -sV -sC -p- example.com -oN detailed_nmap.txt

# Web service detection + directory scan
./recon-vuln-scanner.sh -t example.com -s directories

# Analyze everything
./vulnerability-analyzer.sh -t example.com
```

## ⚙️ Configuration

### Using config.template

```bash
# Create custom config
cp config.template my_config.conf

# Edit settings
vim my_config.conf

# Source in your scripts
source my_config.conf
./recon-vuln-scanner.sh -t "$TARGET" -s all
```

### Configuration Examples

```bash
# Conservative scanning (low network impact)
THREADS=5
PORT_RANGE="1-1000"
AGGRESSIVE_VULN_TEST="no"

# Aggressive scanning (deep assessment)
THREADS=50
PORT_RANGE="1-65535"
AGGRESSIVE_VULN_TEST="yes"

# Balanced approach (default)
THREADS=10
PORT_RANGE="1-65535"
AGGRESSIVE_VULN_TEST="no"
```

## 🔍 Troubleshooting

### Common Issues

#### Issue: "command not found: nmap"
```bash
# Solution
sudo apt-get install nmap
# or
bash setup-dependencies.sh
```

#### Issue: Permission denied
```bash
# Solution
chmod +x *.sh
# or run with sudo
sudo ./recon-vuln-scanner.sh -t target.com
```

#### Issue: No response from target
```bash
# Verify connectivity
ping target.com

# Check specific port
nc -zv target.com 80

# Try with verbose mode
./recon-vuln-scanner.sh -t target.com -s ports -v
```

#### Issue: Timeout errors
```bash
# Use specific ports instead of full range
./recon-vuln-scanner.sh -t target.com -s ports -p 1-1000

# Reduce threads
./recon-vuln-scanner.sh -t target.com -T 5
```

#### Issue: "Operation not permitted"
```bash
# Some scans require elevated privileges
sudo ./recon-vuln-scanner.sh -t target.com

# Or configure sudo access
sudo visudo  # Add necessary commands
```

## 📋 Important Notes

### Legal & Ethical Considerations

⚠️ **AUTHORIZATION REQUIRED**

1. **Always get written permission** before scanning
2. **Define the scope** of testing
3. **Respect system integrity** during testing
4. **Handle findings responsibly**
5. **Follow disclosure policies**
6. **Comply with local laws**

### Performance Optimization

- **Reduce port range** for faster scans
- **Limit threads** to avoid network saturation
- **Use specific scan types** instead of "all"
- **Schedule scans** during off-peak hours
- **Test incrementally** to verify targets

### Data Management

```bash
# Backup results
tar -czf scan_results_backup.tar.gz scan_results/

# Archive old results
find scan_results -mtime +30 -exec gzip {} \;

# Clean up
rm -rf scan_results/scan_log_*.log
```

## 📚 Learning Resources

### External Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Nmap Documentation](https://nmap.org/book/)
- [A2 Security](https://cheatsheetseries.owasp.org/)
- [HackTricks](https://book.hacktricks.xyz/)

### Practice Targets
- [DVWA](http://dvwa.co.uk/) - Deliberately Vulnerable Web App
- [WebGoat](https://owasp.org/www-project-webgoat/) - Learning platform
- [HackTheBox](https://www.hackthebox.com/) - CTF challenges
- [TryHackMe](https://tryhackme.com/) - Interactive labs

### Skill Development
1. Learn Linux basics
2. Understand networking fundamentals
3. Study web application security
4. Practice with vulnerable apps
5. Keep up with security news

## ✅ Verification Checklist

Use this checklist to verify your setup:

- [ ] All scripts are executable (`chmod +x`)
- [ ] Dependencies installed (`nmap`, `curl`, `dig`, `python3`)
- [ ] Can run help: `./recon-vuln-scanner.sh -h`
- [ ] Can run analyzer: `./vulnerability-analyzer.sh -h`
- [ ] Output directory created: `scan_results/`
- [ ] Read permissions on all files
- [ ] Test scan runs without errors
- [ ] Results visible in `scan_results/`

## 🎓 Example Session

Here's a complete example of a scanning session:

```bash
# 1. Navigate to scripts directory
cd ~/Scripts

# 2. Run initial scan
./recon-vuln-scanner.sh -t testsite.com -s ports -p 1-5000
# ✓ Results saved

# 3. Scan directories
./recon-vuln-scanner.sh -t testsite.com -s directories
# ✓ Found 23 accessible directories

# 4. Check vulnerabilities
./recon-vuln-scanner.sh -t testsite.com -s vuln -v
# ✓ Found 5 potential vulnerabilities

# 5. Analyze results
./vulnerability-analyzer.sh -t testsite.com
# ✓ Generated analysis report with risk score

# 6. Review findings
cat scan_results/analysis_*.txt | less

# 7. Document findings
cp scan_results/* ~/findings/testsite_$(date +%Y%m%d)/
```

## 📞 Support

### Getting Help

1. **Check README.md** - Comprehensive documentation
2. **Review QUICK-REFERENCE.md** - Command examples
3. **Verify setup** - Run diagnostic scan
4. **Check logs** - Review `scan_results/scan_log_*.log`

### Running Diagnostics

```bash
# Test connectivity
ping example.com

# Test DNS
dig example.com

# Test web service
curl -v http://example.com

# Test Nmap
nmap -p 80 example.com

# Run test scan with verbose
./recon-vuln-scanner.sh -t example.com -s ports -p 80,443 -v
```

## 🎯 Next Steps

1. **Complete the setup**: Follow Steps 1-4 above
2. **Run test scan**: Target a system you own
3. **Review results**: Understand the output formats
4. **Analyze report**: Use the analyzer tool
5. **Practice**: Run multiple scans on different targets
6. **Learn**: Study OWASP Top 10 in depth
7. **Automate**: Create scanning workflows
8. **Contribute**: Improve the tools

---

**Happy Scanning!** 🚀

Remember to always act ethically and legally. Great power requires great responsibility.

For full documentation, see [README.md](README.md)
