# 🛡️ SecKit - Security Toolkit
## Professional Security Assessment Suite

---

## 📦 What You Have

A **complete, production-ready cybersecurity toolkit** for professional reconnaissance and vulnerability assessment.

### Core Component

| Component | Purpose | Status |
|-----------|---------|--------|
| **seckit** | All-in-one: Setup, Scanning, Analysis | ✓ Ready |

**Total Code: Production-quality Bash with integrated functionality**

---

## 🚀 Quick Start (3 Steps)

### Step 1: Install Dependencies
```bash
./seckit start
```

### Step 2: Run Your First Scan
```bash
./seckit -t example.com
```

### Step 3: Analyze Results
```bash
./seckit analyse
```

---

## 📚 Documentation Map

### For Beginners
1. **Start here**: [GETTING-STARTED.md](GETTING-STARTED.md)
   - Complete setup instructions
   - Workflows and examples
   - Troubleshooting guide

2. **Quick commands**: [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
   - Common command patterns
   - Real-world scenarios
   - Automation examples

### For Advanced Users
3. **Full documentation**: [README.md](README.md)
   - Detailed feature explanations
   - OWASP Top 10 deep dive
   - Advanced usage patterns

4. **Configuration**: [config.template](config.template)
   - All configurable options
   - Performance tuning
   - Advanced settings

---

## 🎯 Features at a Glance

### 1️⃣ Port & Service Scanning
```bash
✓ Comprehensive port discovery (1-65535)
✓ Service version detection
✓ Operating system fingerprinting
✓ Custom port ranges
✓ Multi-threaded scanning
```

**Command:**
```bash
./recon-vuln-scanner.sh -t target.com -s ports -p 1-5000
```

### 2️⃣ Directory Enumeration
```bash
✓ Automatic protocol detection
✓ HTTP status code categorization
✓ Custom wordlist support
✓ Redirect tracking
✓ Path brute-forcing
```

**Command:**
```bash
./recon-vuln-scanner.sh -t target.com -s directories
```

### 3️⃣ Subdomain Discovery
```bash
✓ DNS resolution
✓ MX record analysis
✓ SPF record detection
✓ Reverse DNS lookup
✓ NS record enumeration
```

**Command:**
```bash
./recon-vuln-scanner.sh -t target.com -s subdomains
```

### 4️⃣ OWASP Top 10 Vulnerability Assessment

#### Included Tests:
1. **SQL Injection** - Detects database manipulation
2. **XSS** - Finds JavaScript injection points
3. **Authentication** - Analyzes login mechanisms
4. **Sensitive Data** - Checks security headers
5. **Access Control** - Tests authorization
6. **XXE** - Identifies XML injection
7. **Deserialization** - Finds unsafe object handling
8. **Weak Components** - Extracts versions
9. **Broken Authentication** - Tests credentials
10. **Insufficient Logging** - Finds exposed logs

**Command:**
```bash
./recon-vuln-scanner.sh -t target.com -s vuln -v
```

---

## 🔧 Tool Capabilities

### Scanner Modes

| Mode | Use Case | Speed | Depth |
|------|----------|-------|-------|
| `ports` | Network reconnaissance | Fast | Light |
| `directories` | Web app mapping | Medium | Medium |
| `subdomains` | Asset discovery | Fast | Light |
| `vuln` | Vulnerability assessment | Medium | Deep |
| `all` | Complete assessment | Slow | Deep |

### Performance Options

```bash
# Fast scan (10 threads, limited ports)
./recon-vuln-scanner.sh -t target.com -s ports -p 1000 -T 10

# Balanced scan (default)
./recon-vuln-scanner.sh -t target.com -s all

# Comprehensive scan (50 threads, all ports)
./recon-vuln-scanner.sh -t target.com -s all -T 50 -p 1-65535

# Passive scan (directories only)
./recon-vuln-scanner.sh -t target.com -s directories
```

---

## 📂 Output Files

All results are saved with timestamps:

```
scan_results/
├── scan_report_20240417_120530.txt              # Main report
├── scan_log_20240417_120530.log                 # Detailed log
├── nmap_target_com_20240417_120530.txt          # Port scan
├── directories_target_com_20240417_120530.txt   # Directory findings
├── subdomains_target_com_20240417_120530.txt    # Subdomain results
└── vulnerabilities_target_com_20240417_120530.txt # Vulnerability findings
```

### Analyzer Output

```
analysis_reports/
└── analysis_20240417_120530.txt                 # Comprehensive analysis
    ├── Risk score calculation
    ├── Severity assessment
    ├── Remediation recommendations
    └── Summary and next steps
```

---

## 🎓 Common Usage Patterns

### Pattern 1: Website Security Check
```bash
./recon-vuln-scanner.sh -t mywebsite.com -s all -v
./vulnerability-analyzer.sh -t mywebsite.com
```
**Time**: ~5-10 minutes | **Scope**: Full website assessment

### Pattern 2: Network Penetration Test
```bash
./recon-vuln-scanner.sh -t 192.168.1.100 -s ports -p 1-65535 -T 20
./recon-vuln-scanner.sh -t 192.168.1.100 -s directories
./recon-vuln-scanner.sh -t 192.168.1.100 -s vuln
```
**Time**: ~20-30 minutes | **Scope**: Deep infrastructure assessment

### Pattern 3: Quick Vulnerability Assessment
```bash
./recon-vuln-scanner.sh -t target.com -s vuln
```
**Time**: ~2-5 minutes | **Scope**: Vulnerability focused

### Pattern 4: Continuous Monitoring
```bash
#!/bin/bash
while true; do
    ./recon-vuln-scanner.sh -t target.com -s all
    ./vulnerability-analyzer.sh -t target.com
    sleep 86400  # Daily
done
```
**Time**: Automated | **Scope**: Ongoing security monitoring

---

## 🛡️ Security Considerations

### ⚠️ Legal Requirements
- **Authorization**: Always get written permission
- **Scope**: Clearly define testing boundaries
- **Laws**: Comply with local regulations
- **Responsibility**: Handle findings responsibly

### 🔐 Ethical Practices
✓ Only test authorized targets
✓ Document all activities
✓ Follow responsible disclosure
✓ Maintain confidentiality
✓ Test in controlled environments

---

## 📋 Requirements & Dependencies

### System Requirements
- **OS**: Linux (Ubuntu, Debian, CentOS, Fedora, Arch)
- **Bash**: Version 4.0+
- **Storage**: 500MB minimum
- **Network**: Internet access
- **Privileges**: Standard user (sudo for some features)

### Required Tools
```
✓ nmap              - Port scanning
✓ curl              - Web requests
✓ dig               - DNS queries
✓ python3           - Encoding/processing
```

### Installation
```bash
# All at once
bash setup-dependencies.sh

# Or individual tools:
sudo apt-get install nmap curl dnsutils python3  # Ubuntu/Debian
sudo yum install nmap curl bind-utils python3    # CentOS/RHEL
brew install nmap curl bind-tools python3        # macOS
```

---

## 🔍 Understanding Results

### Port Status Codes
| Status | Meaning | Risk |
|--------|---------|------|
| open | Listening service | ⚠️ Investigate |
| closed | No service | ✓ Safe |
| filtered | Blocked | ✓ Protected |

### HTTP Status Codes
| Code | Meaning | Action |
|------|---------|--------|
| 200 | Page accessible | Investigate |
| 301/302 | Redirects | Check target |
| 403 | Forbidden | Likely sensitive |
| 404 | Not found | Safe |

### Vulnerability Severity
| Level | Impact | Action |
|-------|--------|--------|
| 🔴 CRITICAL | Immediate risk | Fix immediately |
| 🟠 HIGH | Significant risk | Fix soon |
| 🟡 MEDIUM | Notable risk | Plan remediation |
| 🟢 LOW | Minor issue | Monitor |

---

## 🚨 Common Findings

### High-Risk Services
- FTP (unencrypted credentials)
- Telnet (unencrypted communication)
- SQL Server directly accessible
- SSH on non-standard ports

### Vulnerable Patterns
- Admin panels accessible
- Default credentials accepted
- SQL Injection possible
- XSS vulnerabilities present
- Missing security headers

---

## ⚙️ Advanced Configuration

### Performance Tuning
```bash
# For slow networks
./recon-vuln-scanner.sh -t target.com -T 5 -p 1-1000

# For fast networks
./recon-vuln-scanner.sh -t target.com -T 50 -p 1-65535

# Balanced (default)
./recon-vuln-scanner.sh -t target.com -T 10
```

### Custom Wordlists
```bash
# Create custom wordlist
echo -e "admin\napi\nconfig" > custom_dirs.txt

# Place in scan_results
cp custom_dirs.txt scan_results/directory_wordlist.txt

# Scanner will use it automatically
./recon-vuln-scanner.sh -t target.com -s directories
```

### Batch Processing
```bash
#!/bin/bash
for target in target1.com target2.com target3.com; do
    echo "Scanning $target..."
    ./recon-vuln-scanner.sh -t "$target" -s all
    sleep 300  # 5 minute delay
done
```

---

## 🐛 Troubleshooting

### Issue: Script won't run
```bash
chmod +x *.sh
```

### Issue: nmap not found
```bash
bash setup-dependencies.sh
# or
sudo apt-get install nmap
```

### Issue: Permission denied
```bash
sudo ./recon-vuln-scanner.sh -t target.com
```

### Issue: No results
```bash
# Verify connectivity
ping target.com

# Test specific port
nc -zv target.com 80

# Check logs
cat scan_results/scan_log_*.log
```

### Issue: Slow scanning
```bash
# Use limited port range
./recon-vuln-scanner.sh -t target.com -s ports -p 1-1000

# Reduce threads
./recon-vuln-scanner.sh -t target.com -T 5
```

---

## 📚 Learning Path

### Level 1: Getting Started (1-2 days)
1. Read GETTING-STARTED.md
2. Install dependencies
3. Run test scan
4. Understand output formats

### Level 2: Basic Usage (1 week)
1. Run all scan types
2. Try different options
3. Analyze results
4. Study OWASP Top 10

### Level 3: Advanced Usage (2-4 weeks)
1. Create custom wordlists
2. Automate scanning
3. Build detection logic
4. Integrate with tools

### Level 4: Expert (Ongoing)
1. Contribute improvements
2. Create specialized tools
3. Build automation
4. Master security assessment

---

## 📞 Support Resources

### Documentation
- [README.md](README.md) - Full documentation
- [GETTING-STARTED.md](GETTING-STARTED.md) - Setup guide
- [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Command cheat sheet

### External Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Nmap Guide](https://nmap.org/book/)
- [HackTricks](https://book.hacktricks.xyz/)
- [CyberDefenders](https://cyberdefenders.org/)

### Practice Targets
- [DVWA](http://dvwa.co.uk/) - Vulnerable web app
- [WebGoat](https://owasp.org/www-project-webgoat/)
- [HackTheBox](https://www.hackthebox.com/)
- [TryHackMe](https://tryhackme.com/)

---

## ✅ Setup Verification Checklist

Use this to verify your installation:

- [ ] All scripts are executable (`ls -l *.sh`)
- [ ] Dependencies installed (`nmap --version`)
- [ ] Help displays correctly (`./recon-vuln-scanner.sh -h`)
- [ ] Test scan runs successfully
- [ ] Results appear in `scan_results/`
- [ ] Analyzer works (`./vulnerability-analyzer.sh -h`)
- [ ] Documentation is readable (Open README.md)

---

## 🎯 Architecture

```
┌─────────────────────────────────────────────────┐
│     Reconnaissance & Vulnerability Scanner      │
├─────────────────────────────────────────────────┤
│                                                 │
│  1. Port Scanner ──┐                           │
│     (Nmap)        │                           │
│                   ├─→ scan_results/ ──→ Analysis
│  2. Directory     │                           │
│     Enumerator    │                           │
│                   │                           │
│  3. Subdomain     │                           │
│     Finder        │                           │
│                   │                           │
│  4. OWASP Tester ─┤                           │
│     (10 checks)   │                           │
│                   │                           │
└─────────────────────────────────────────────────┘
         ↓                                    ↓
    Raw Results                    Analyzed Reports
    ├─ nmap_*.txt                 ├─ risk_score
    ├─ directories_*.txt          ├─ vulnerabilities
    ├─ subdomains_*.txt           ├─ recommendations
    └─ vulns_*.txt                └─ action_items
```

---

## 🎓 Example: Complete Assessment

### Scenario: Assess a web application

```bash
# 1. Initial port scan (2 min)
./recon-vuln-scanner.sh -t myapp.com -s ports -p 1-5000

# 2. Check directories (5 min)
./recon-vuln-scanner.sh -t myapp.com -s directories

# 3. Find subdomains (2 min)
./recon-vuln-scanner.sh -t myapp.com -s subdomains

# 4. Test for vulnerabilities (5 min)
./recon-vuln-scanner.sh -t myapp.com -s vuln -v

# 5. Comprehensive analysis (1 min)
./vulnerability-analyzer.sh -t myapp.com

# 6. Review findings
cat scan_results/scan_report_*.txt
cat analysis_reports/analysis_*.txt

# 7. Take action based on findings
```

**Total Time**: ~15-20 minutes
**Deliverables**: Complete security assessment

---

## 🚀 Next Steps

1. **Install**: Run `bash setup-dependencies.sh`
2. **Learn**: Read `GETTING-STARTED.md`
3. **Practice**: Run test scan on authorized target
4. **Analyze**: Use `vulnerability-analyzer.sh`
5. **Improve**: Customize for your needs
6. **Automate**: Create scanning workflows
7. **Master**: Deep dive into OWASP Top 10

---

## 📝 File Manifest

```
~/Scripts/
├── recon-vuln-scanner.sh       → Main scanning tool (674 lines)
├── vulnerability-analyzer.sh   → Results analyzer (428 lines)
├── setup-dependencies.sh       → Dependency installer (169 lines)
├── README.md                   → Full documentation (374 lines)
├── GETTING-STARTED.md          → Setup guide (619 lines)
├── QUICK-REFERENCE.md          → Command sheet (310 lines)
├── config.template             → Configuration (182 lines)
├── INDEX.md                    → This file
└── scan_results/               → Output directory (auto-created)
    ├── scan_report_*.txt
    ├── scan_log_*.log
    ├── nmap_*.txt
    ├── directories_*.txt
    ├── subdomains_*.txt
    └── vulnerabilities_*.txt

analysis_reports/               → Analysis output (auto-created)
└── analysis_*.txt
```

---

## 🎯 Your Next Action

**Right now, do this:**

```bash
cd ~/Scripts
bash setup-dependencies.sh
./recon-vuln-scanner.sh -h
```

**Then read**: GETTING-STARTED.md

---

## ⚖️ Legal Notice

This toolkit is designed for professional security testing on **authorized systems only**.

- Unauthorized access to computer systems is illegal
- Always obtain written authorization
- Define clear scope
- Follow responsible disclosure
- Comply with applicable laws

---

**Created**: April 17, 2026
**Version**: 1.0
**Status**: Production Ready ✓

**Ready to secure your systems? Start here: [GETTING-STARTED.md](GETTING-STARTED.md)**
