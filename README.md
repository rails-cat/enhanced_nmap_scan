# Network Vulnerability Assessment Script

This repository contains a Bash script that performs network scanning using `nmap` and integrates with the OpenAI GPT-4 API to assess potential vulnerabilities. The script identifies active hosts on a local network, performs detailed scans on each host to gather open ports, services, and OS details, then queries GPT-4 to analyze potential security risks.

## Features

- **Network Scanning**: Uses `nmap` to discover active hosts on the network and conduct in-depth scans of each.
- **Service and OS Detection**: Detects open ports, running services, and operating systems on each host.
- **GPT-4 Integration**: Queries GPT-4 to analyze scan results and provide insights on potential security risks.
- **Detailed Output**: Outputs both raw `nmap` scan results and GPT-4 analysis.

## Prerequisites

- **nmap**: Install `nmap` for network scanning.
```bash
sudo apt-get install nmap
```
- **jq**: Used for JSON handling.
```bash
sudo apt-get install jq
```
- **OpenAI API Key**: Obtain an API key from OpenAI and either pass it as a parameter or enter it when prompted.

## Usage
Run script
```bash
chmod +x network_vulnerability_assessment.sh
./network_vulnerability_assessment.sh YOUR_OPENAI_API_KEY
```
Review results:
- nmap_scan_results.txt: Contains raw nmap scan results for each host.
- gpt4_analysis.txt: Contains GPT-4’s analysis for each host, highlighting potential security risks.
- raw_gpt4.txt: Stores the raw GPT-4 responses, including prompts and full API responses.
