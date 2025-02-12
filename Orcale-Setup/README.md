# 🖥️ Virtual Machine Setup Guide

This guide provides instructions for setting up an Ubuntu virtual machine using either Oracle VM VirtualBox or Microsoft Hyper-V with the specified requirements.

## 📋 System Requirements

- 🐧 Ubuntu 20.04 LTS or later (Server Or Desktop)
- 🔄 4 vCPUs
- 💾 4 GB RAM
- 💽 100 GB disk space
- 🔑 SSH access enabled

# 🔵 Option 1: Oracle VM VirtualBox Setup

## 🚀 Setup Instructions

### 1. Download Oracle VM VirtualBox

1. 🌐 Visit the [Oracle VM VirtualBox download page](https://www.virtualbox.org/wiki/Downloads)
2. ⬇️ Download and install VirtualBox for your host operating system

### 2. Download Ubuntu ISO

1. 🌐 Visit the [Ubuntu downloads page](https://ubuntu.com/download/desktop)
2. ⬇️ Download Ubuntu 20.04 LTS or later

### 3. Create Virtual Machine

1. 📱 Open Oracle VM VirtualBox
2. ➕ Click "New" to create a new virtual machine
3. ⚙️ Configure the VM with these settings:
   - Name: Ubuntu-VM
   - Type: Linux
   - Version: Ubuntu (64-bit)
   - Memory: 4096 MB (4 GB)
   - CPU: 4 vCPUs
   - Create a virtual hard disk:
     - VDI (VirtualBox Disk Image)
     - Dynamically allocated
     - Size: 100 GB

### 4. Configure VM Settings

1. ⚙️ Select the new VM and click "Settings"
2. 💻 Under "System":
   - Processor tab: Set 4 CPUs
   - Enable PAE/NX
3. 🌐 Under "Network":
   - Adapter 1: NAT
   - Advanced: Enable Port Forwarding for SSH

### 5. Install Ubuntu

1. ▶️ Start the VM
2. 💿 Select the downloaded Ubuntu ISO as the boot medium
3. 📝 Follow the Ubuntu installation wizard
4. ✅ Choose "Install Ubuntu"
5. 🔧 Select your preferences for:
   - Language
   - Keyboard layout
   - Installation type (Use entire disk)
   - Time zone
   - User account details

### 6. Enable SSH Access

After installation, run these commands in the Ubuntu terminal:

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl status ssh
sudo ufw allow ssh
```

### 7. Configure Port Forwarding

1. In VirtualBox Manager:
   - Select your VM
   - Go to Settings > Network
   - Adapter 1 > Advanced > Port Forwarding
   - Add new rule:
     - Name: SSH
     - Protocol: TCP
     - Host Port: 2222
     - Guest Port: 22

### 8. Connect via SSH

From your host machine, you can now connect using:

```bash
ssh username@localhost -p 2222
```

Replace 'username' with your Ubuntu user account name.

## 🔍 Verification

To verify the system specifications after setup:

```bash
# Check CPU
lscpu | grep "CPU(s):"

# Check RAM
free -h

# Check Disk Space
df -h

# Check Ubuntu Version
lsb_release -a
```

## ❗ Troubleshooting

If you encounter any issues:
1. 🔧 Ensure virtualization is enabled in your BIOS
2. ✅ Verify that your host system meets the minimum requirements
3. 📝 Check VirtualBox error logs for specific issues
4. 🌐 Ensure network settings are properly configured

For additional support, consult the [VirtualBox Documentation](https://www.virtualbox.org/wiki/Documentation) or [Ubuntu Documentation](https://help.ubuntu.com/).

# 🔷 Option 2: Microsoft Hyper-V Setup

## 📋 Prerequisites

1. 💻 Windows 10/11 Pro, Enterprise, or Education edition
2. 🔧 Hardware requirements:
   - 64-bit processor with Second Level Address Translation (SLAT)
   - CPU support for VM Monitor Mode Extension (VT-x on Intel)
   - Minimum 4 GB memory

## 🔌 Enable Hyper-V

1. 🖥️ Open PowerShell as Administrator and run:
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```
2. 🔄 Restart your computer when prompted

Alternatively, enable through Windows Features:
1. ⚙️ Open Control Panel
2. 📱 Go to Programs > Turn Windows features on or off
3. ✅ Select Hyper-V and click OK
4. 🔄 Restart your computer

## 🚀 Setup Instructions

### 1. Download Ubuntu ISO

1. 🌐 Visit the [Ubuntu downloads page](https://ubuntu.com/download/desktop)
2. ⬇️ Download Ubuntu 20.04 LTS or later

### 2. Create Virtual Machine

1. 📱 Open Hyper-V Manager
2. ➕ Click "Quick Create" or "New" > "Virtual Machine"
3. ⚙️ If using New Virtual Machine wizard:
   - Specify Name and Location
   - Choose "Generation 2"
   - Assign memory: 4096 MB (4 GB)
   - Configure networking: "Default Switch"
   - Create virtual hard disk: 100 GB
   - Choose "Install an operating system from a bootable image file"
   - Select your Ubuntu ISO file

### 3. Configure VM Settings

1. ⚙️ Before starting the VM, configure additional settings:
   - Right-click the VM and select "Settings"
   - Under Processor, set "Number of virtual processors" to 4
   - Under Security, disable Secure Boot
   - Under Integration Services, ensure all services are enabled

### 4. Install Ubuntu

1. ▶️ Start the VM
2. 📝 Follow the Ubuntu installation wizard
3. 🔧 Complete the installation with your preferences for:
   - Language
   - Keyboard layout
   - Installation type (Use entire disk)
   - Time zone
   - User account details

### 5. Enable SSH Access

After installation, run these commands in the Ubuntu terminal:

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl status ssh
sudo ufw allow ssh
```

### 6. Network Configuration

1. In Hyper-V Manager:
   - 🔧 Open VM settings
   - 🌐 Under "Network Adapter", ensure it's connected to "Default Switch"
   - 📝 Note the VM's IP address using this command inside Ubuntu:
     ```bash
     ip addr show
     ```

### 7. Connect via SSH

From your Windows host, connect using:

```bash
ssh username@vm_ip_address
```

Replace 'username' with your Ubuntu user account name and 'vm_ip_address' with the IP address noted earlier.

## 🔍 Hyper-V Specific Verification

To verify the system specifications in Hyper-V:

```powershell
# Get VM information (run in PowerShell as admin)
Get-VM -Name "YourVMName" | Select-Object *
```

Inside the Ubuntu VM, use the same verification commands as mentioned in the Oracle VM section:

```bash
# Check CPU
lscpu | grep "CPU(s):"

# Check RAM
free -h

# Check Disk Space
df -h

# Check Ubuntu Version
lsb_release -a
```

## ❗ Hyper-V Troubleshooting

1. 🚫 If VM creation fails:
   - Ensure Hyper-V is properly installed
   - Verify virtualization is enabled in BIOS/UEFI
   - Check Windows Event Viewer for specific errors

2. 🌐 If networking issues occur:
   - Ensure Default Switch is properly created
   - Try recreating the virtual switch
   - Check Windows Firewall settings

3. ⚡ If performance is poor:
   - Verify no other hypervisors are running
   - Check host system's resource usage
   - Ensure dynamic memory is properly configured

For additional support, consult the [Microsoft Hyper-V Documentation](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/) or [Ubuntu Documentation](https://help.ubuntu.com/).