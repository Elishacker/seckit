# Reconnaissance & Vulnerability Scanner

A powerful and comprehensive Bash-based security reconnaissance and vulnerability scanning tool designed for professional penetration testers and security experts.

## Features

### 🔍 **1. Port & Service Scanning**
- Comprehensive port discovery using Nmap
- Service identification and version detection
- Customizable port ranges
- Support for TCP/UDP scans
- Service script detection

### 📂 **2. Directory Enumeration**
- Automatic web service detection (HTTP/HTTPS)
- Directory brute-forcing with wordlist
- HTTP status code identification
- Both common and custom wordlist support
- Redirect tracking

### 🌐 **3. Subdomain Analysis**
- DNS subdomain enumeration
- MX record analysis
- SPF record detection
- NS record enumeration
- DNS TXT record analysis
- Reverse DNS lookups for IP targets

### 🛡️ **4. OWASP Top 10 Vulnerability Scanning**

1. **SQL Injection Detection** - Tests for SQL injection vectors
2. **Cross-Site Scripting (XSS)** - Detects reflected and DOM-based XSS
3. **Authentication & Session Management** - Analyzes session headers and mechanisms
4. **Sensitive Data Exposure** - Checks for missing security headers (HSTS, CSP, X-Frame-Options)
5. **Broken Access Control** - Tests for unauthorized access to admin panels
6. **XML External Entity (XXE)** - Identifies XXE injection points
7. **Insecure Deserialization** - Detects serialization vulnerabilities
8. **Broken Authentication** - Tests default credentials
9. **Components with Known Vulnerabilities** - Extracts server and framework versions
10. **Insufficient Logging & Monitoring** - Identifies exposed logging endpoints

## Prerequisites

### Required Tools
```bash
# Core utilities (usually pre-installed)
- bash (4.0+)
- curl
- dig
- python3

# Security tools (may need installation)
- nmap
```

### Installation of Dependencies

**On Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y nmap curl dnsutils python3
```

**On CentOS/RHEL:**
```bash
sudo yum install -y nmap curl bind-utils python3
```

**On macOS:**
```bash
brew install nmap curl bind-tools python3
```

## Installation

1. **Clone the repository:**
```bash
git clone git@github.com:Elishacker/3lishack3r.git ~/3lishack3r
cd ~/3lishack3r
chmod +x seckit 3_analyzer.sh
```

2. **Run setup to install dependencies:**
```bash
./seckit start
```

3. **Optional: Add to PATH**
```bash
sudo cp seckit /usr/local/bin/seckit
sudo chown root:root /usr/local/bin/seckit
```

## Usage

### Initialization
```bash
./seckit start
```
This installs all required dependencies (nmap, curl, dnsutils, python3).

### Basic Syntax
```bash
./seckit [OPTIONS]
```

### Options
```
-t, --target <target>      Target IP address or domain (REQUIRED)
-s, --scan <type>          Scan type: all, ports, directories, subdomains, vuln
                           (Default: all)
-p, --ports <range>        Port range (Default: 1-65535)
                           Example: 1-1000, 22,80,443,3306
-T, --threads <num>        Number of threads for parallel scanning (Default: 10)
-v, --verbose              Enable verbose output
-h, --help                 Display help message
```

### Examples

**1. Full Reconnaissance Scan (All Modules)**
```bash
./seckit -t example.com
```

**2. Port Scan Only (Limited Range)**
```bash
./seckit -t 192.168.1.100 -s ports -p 1-5000
```

**3. Specific Ports**
```bash
./seckit -t example.com -s ports -p 22,80,443,8080,8443
```

**4. Directory Enumeration**
```bash
./seckit -t example.com -s directories
```

**5. Subdomain Discovery**
```bash
./seckit -t example.com -s subdomains
```

**6. OWASP Vulnerability Scan**
```bash
./seckit -t example.com -s vuln
```

**7. Full Scan with Verbose Output**
```bash
./seckit -t 192.168.1.100 -s all -v
```

**8. Scan with Multiple Threads**
```bash
./seckit -t example.com -s all -T 20
```

## Output and Reporting

All scan results are automatically saved to the `scan_results/` directory with timestamps:

```
scan_results/
├── scan_report_20240417_120530.txt          # Main report
├── scan_log_20240417_120530.log             # Detailed log
├── nmap_example_com_20240417_120530.txt     # Port scan results
├── directories_example_com_20240417_120530.txt    # Directory findings
├── subdomains_example_com_20240417_120530.txt     # Subdomain results
└── vulnerabilities_example_com_20240417_120530.txt # Vulnerability findings
```

### Reading Results
```bash
# View main report
cat scan_results/scan_report_*.txt

# View detailed log
cat scan_results/scan_log_*.txt

# View port scan results
cat scan_results/nmap_*.txt
```

## Understanding Results

### Port Scan Results
- Format: `PORT/STATE SERVICE [VERSION]`
- Common ports: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3306 (MySQL), 5432 (PostgreSQL)

### Directory Results
- `[200]` - File/Directory accessible
- `[301/302]` - Redirect found
- `[403]` - Forbidden (exists but access denied)
- `[404]` - Not found (doesn't exist)

### Vulnerability Results
- 🔴 **CRITICAL** - Immediate remediation required
- 🟠 **HIGH** - Significant security risk
- 🟡 **MEDIUM** - Should be addressed
- 🟢 **LOW** - Minor issues

## Security Considerations

⚠️ **LEGAL DISCLAIMER**

This tool is intended for authorized security testing only. Unauthorized access to computer systems is illegal. Always:

1. **Obtain written authorization** before testing any target
2. **Define scope clearly** - know what systems you're authorized to test
3. **Document everything** - keep detailed logs of all activities
4. **Follow local laws** - ensure compliance with applicable regulations
5. **Maintain confidentiality** - handle findings responsibly
6. **Use in isolated environments** first when possible
7. **Test with client approval** - never surprise with production scans

### Responsible Disclosure
- Report findings through proper channels
- Give vendors reasonable time to fix (typically 90 days)
- Don't publicly disclose until patched
- Work with security teams professionally

## Advanced Usage

### Custom Wordlists
Place custom wordlists in the `scan_results/` directory and reference them:
```bash
cp my_wordlist.txt scan_results/directory_wordlist.txt
./seckit -t target.com -s directories
```

### Combining Scans
```bash
# Scan web services first, then directories
./seckit -t example.com -s ports
./seckit -t example.com -s directories
```

### Generate Analysis Report
```bash
# After scanning, analyze results with the analyzer script
./3_analyzer.sh
```

### Scheduling Regular Scans
```bash
# Add to crontab for daily scans
0 2 * * * /home/user/3lishack3r/seckit -t example.com >> /var/log/seckit-scan.log 2>&1
```

## Troubleshooting

### "nmap not found" Error
```bash
# Run the setup command to install dependencies
./seckit start
```

### "Permission denied" Error
```bash
# Make seckit executable
chmod +x seckit
```

### No results or "Connection timeout"
- Verify target is reachable: `ping example.com`
- Check firewall rules
- Verify you have network connectivity
- Try specific port: `nc -zv example.com 80`

### Insufficient privileges for some scans
- Some features require root/sudo
- Run with: `sudo ./seckit -t target.com`
- For full privilege access: `sudo ./seckit start` then `sudo ./seckit -t target.com`

### Slow scans
- Reduce port range with `-p` option
- Decrease threads with `-T` option
- Run specific scan types instead of `all`

## Performance Tips

1. **Limit port range** for faster scans:
   ```bash
   ./seckit -t target.com -s ports -p 1-1000
   ```

2. **Use specific scan types** instead of full scans when possible

3. **Adjust thread count** based on system resources

4. **Run during off-peak hours** to minimize network impact

5. **Use timeout options** to skip unresponsive hosts

## OWASP Top 10 Deep Dive

### 1. SQL Injection
The tool tests common SQL injection payloads against parameters and checks for error-based SQL responses.

### 2. XSS (Cross-Site Scripting)
Tests reflected XSS by injecting JavaScript payloads and checking if they're reflected in responses.

### 3. Authentication & Session Management
Analyzes session cookies, authentication headers, and session timeout mechanisms.

### 4. Sensitive Data Exposure
Verifies presence of critical security headers:
- HSTS (HTTP Strict Transport Security)
- CSP (Content Security Policy)
- X-Frame-Options

### 5. Broken Access Control
Tests known admin paths and sensitive URLs for unauthorized access.

### 6. XXE (XML External Entity)
Identifies endpoints accepting XML/SOAP input for potential XXE attacks.

### 7. Insecure Deserialization
Detects serialization function usage that could lead to code execution.

### 8. Broken Authentication
Tests default credentials against login endpoints.

### 9. Components with Known Vulnerabilities
Extracts server software and version information for vulnerability lookup.

### 10. Insufficient Logging
Identifies exposed logging endpoints that could leak sensitive information.

## File Structure

```
3lishack3r/
├── seckit                       # Combined setup & scanner (all-in-one)
├── 3_analyzer.sh                # Vulnerability analyzer & report generator
├── README.md                    # This file
├── LICENSE                      # License file
├── scan_results/                # Scanner output directory (auto-created)
│   ├── scan_report_*.txt
│   ├── scan_log_*.txt
│   ├── nmap_*.txt
│   ├── directories_*.txt
│   ├── subdomains_*.txt
│   └── vulnerabilities_*.txt
├── analysis_reports/            # Analyzer output directory (auto-created)
│   └── analysis_*.txt
└── docx/                        # Documentation files
    ├── GETTING-STARTED.md
    ├── QUICK-REFERENCE.md
    ├── QUICKSTART
    └── TOOLKIT-SUMMARY.md
```

## Contributing

To improve this tool:
1. Test against various target types
2. Report issues and feature requests
3. Suggest additional checks or methods
4. Share wordlists and payloads (responsibly)

## Workflow

1. **Setup** - Run `./seckit start` to install all dependencies
2. **Scan** - Run `./seckit -t <target>` to perform reconnaissance and vulnerability scanning
3. **Analyze** - Run `./3_analyzer.sh` to generate comprehensive reports from scan results

## Version History

- **v1.0** - Initial release
  - Port scanning with Nmap
  - Directory enumeration
  - Subdomain discovery
  - OWASP Top 10 vulnerability assessment
  - Vulnerability analysis and report generation

## License

This tool is provided for authorized security testing only. Users are responsible for compliance with all applicable laws and regulations.

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Nmap Documentation](https://nmap.org/book/)
- [Port Numbers](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers)
- [DNS Enumeration](https://book.hacktricks.xyz/enumeration/dns-enumeration)
- [Web Application Security](https://owasp.org/www-community/)

## Support

For issues, questions, or suggestions:
1. Check the Troubleshooting section
2. Review the script output and logs
3. Verify prerequisites are installed
4. Test with authorized targets

---

**⚡ Happy Hunting!** 

Remember: Great responsibilities come with great power. Use this tool ethically and legally.
