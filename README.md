# README for `jointodomain.sh`

## Overview

The `jointodomain.sh` script is designed to seamlessly join a Linux machine to a Windows Active Directory (AD) domain. It is compatible with Ubuntu, CentOS, and RedHat distributions and is intended for use by domain administrators. The script handles the installation of required packages, configuration of services, and joining the machine to the specified domain.

## Prerequisites

- **Operating Systems Supported:**
  - Ubuntu
  - CentOS
  - RedHat
  - (Future support for openSUSE-Leap is planned)

- **User Requirements:**
  - You must have domain admin credentials to join the domain.

## Instructions

1. **Run the Script:**
   - Use the following command to run the script:
     ```bash
     sudo bash jointodomain.sh
     ```
   - Follow the on-screen prompts, especially when entering the domain admin account.

2. **Log Files:**
   - All logs are captured in `join2domainLOG.txt` for debugging and auditing purposes.

## Script Workflow

1. **Log Initialization:**
   - The script starts by redirecting all output to `join2domainLOG.txt`.

2. **System Information:**
   - The script identifies the distribution type (`Ubuntu`, `CentOS`, `RedHat`) and adapts its behavior accordingly.

3. **Repository Update:**
   - For Ubuntu: `apt-get update`
   - For CentOS/RedHat: `yum makecache`

4. **Package Installation:**
   - Installs the necessary packages (`realmd`, `sssd`, `adcli`, etc.) depending on the distribution.

5. **Domain Discovery:**
   - The script checks if the specified domain is discoverable.

6. **Domain Join Status:**
   - Checks if the machine is already joined to the domain. If it is, the script exits. If not, it proceeds to join the domain.

7. **Joining the Domain:**
   - Prompts for the domain admin credentials and attempts to join the machine to the domain.

8. **Service Configuration:**
   - Configures and enables `SSSD` service to manage domain authentication.
   - Updates `/etc/sssd/sssd.conf` to adjust configurations.

## Error Handling

- The script includes error handling for package installation, repository updates, and domain joining. If any step fails, the script logs the error and exits gracefully, providing relevant details in the log file.

## Improvements/Updates

- The script is designed to be generic and will be updated to support more distributions in the future.
- Future enhancements might include support for openSUSE-Leap and additional error handling features.

## Known Issues

- The script currently supports only `Ubuntu`, `CentOS`, and `RedHat`. Other distributions may not work correctly.
- Ensure the machine has network connectivity to the AD domain before running the script.

## Support

For issues or questions, please refer to the log file `join2domainLOG.txt` for troubleshooting or contact your system administrator.
