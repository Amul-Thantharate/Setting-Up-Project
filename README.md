# WordPress Automation Setup Guide 🚀

This guide will help you set up an automated WordPress deployment system on AWS.

## Table of Contents 📑
1. [Install Terraform](#install-terraform)
2. [Launch EC2 Instance](#step-1-launch-an-ec2-instance)
3. [Install Required Packages](#step-2-install-required-packages)
4. [Set Up Virtual Hosts](#step-3-set-up-virtual-hosts-on-apache)
5. [Install WordPress](#step-4-install-and-set-up-wordpress)
6. [Automate WordPress Setup](#step-5-automate-wordpress-setup-for-second-domain)
7. [Create Web Interface](#step-6-create-web-page-to-trigger-automation)
8. [Configure DNS](#step-7-update-dns-or-hosts-file)
9. [Test Installation](#step-8-access-wordpress)

## 📝 Project Description

🚀 **Comprehensive WordPress Automation Toolkit for AWS**

Simplify your WordPress deployment on AWS with this comprehensive, user-friendly guide. Whether you're a developer, system administrator, or tech enthusiast, this toolkit provides step-by-step instructions for setting up a robust WordPress environment.

### 🌟 Key Features

- 🔵 **Terraform Support**
  - Detailed setup guide for Terraform
  - Comprehensive configuration instructions
  - Optimized for AWS

- 🔷 **WordPress Automation**
  - Seamless setup process for WordPress
  - Precise configuration guidelines
  - Support for multiple domains

### 🛠️ System Requirements

- 🐧 Ubuntu 22.04 LTS or later (Server)
- 🔄 4 vCPUs
- 💾 4 GB RAM
- 💽 100 GB disk space
- 🔑 SSH access enabled

### 🎯 Use Cases

- 💻 Software Development
- 🔬 Testing and Staging Environments
- 📚 Learning and Educational Purposes
- 🌐 Remote Server Deployment

### 🤝 Compatibility

- ✅ AWS
- ✅ Terraform
- ✅ WordPress

### 🚀 Quick Start

1. Choose your preferred AWS region
2. Follow the detailed step-by-step guide
3. Configure your WordPress environment
4. Start developing, testing, or learning!

### 🛡️ Best Practices

- 🔧 Detailed troubleshooting sections
- 📋 Verification steps for system configuration
- 🌐 Network configuration guidelines
- 🔒 SSH access setup instructions

### 🤔 Why This Guide?

Setting up a WordPress environment on AWS can be complex and time-consuming. This guide eliminates the guesswork, providing:
- 📘 Clear, emoji-enhanced documentation
- 🔍 Platform-specific instructions
- 💡 Best practices and troubleshooting tips
- 🚀 Rapid, reproducible environment deployment

### 🌈 Contributions Welcome!

- 🍴 Fork the repository
- 📝 Improve documentation
- 🐛 Report issues
- 🔧 Submit pull requests

### 📜 License

[MIT License](LICENSE)

### 🔗 Additional Resources

- [AWS Official Documentation](https://docs.aws.amazon.com/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [WordPress Official Documentation](https://wordpress.org/support/)

**Happy WordPress Automation Setup! 🎉**

## Install Terraform

### Linux Installation
```bash
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update and install Terraform
sudo apt-get update
sudo apt-get install terraform
```

### macOS Installation
```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Windows Installation
```powershell
# Using Chocolatey
choco install terraform

# Or download installer from:
# https://www.terraform.io/downloads.html
```

### Verify Installation
```bash
terraform version
```

## Step 1: Launch an EC2 Instance

### AWS Console Setup
1. Go to AWS Console → EC2 Dashboard
2. Click `Launch Instance`

### Instance Configuration
- **AMI**: Ubuntu 22.04 LTS
- **Type**: t2.micro (Free Tier eligible)

### Security Group Settings
Configure the following inbound rules:
```
HTTP  (Port 80)  → 0.0.0.0/0
HTTPS (Port 443) → 0.0.0.0/0
SSH   (Port 22)  → Your IP
```

### Launch & Connect
1. Select/create key pair
2. Launch instance
3. Connect via SSH:
```bash
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

## Step 2: Install Required Packages

### Update System and Install Packages
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql python3 nodejs unzip curl
```

### Enable Apache Server
```bash
sudo systemctl enable apache2
sudo systemctl start apache2
```

## Step 3: Set Up Virtual Hosts on Apache

### Create Website Directories
```bash
sudo mkdir -p /var/www/local.example.com/public_html
sudo mkdir -p /var/www/local.test.com/public_html # Optional because local.test.com will create when you access it http://ip_address/index.html
```

### Set Directory Permissions
```bash
sudo chown -R $USER:$USER /var/www/
sudo chmod -R 755 /var/www/
```

### Configure Virtual Hosts

Create configuration for example.com:
```apache
<VirtualHost *:80>
    ServerAdmin webmaster@local.example.com
    ServerName local.example.com
    DocumentRoot /var/www/local.example.com/public_html

    <Directory /var/www/local.example.com/public_html>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Create configuration for test.com (Optional):
```apache
<VirtualHost *:80>
    ServerAdmin webmaster@local.test.com
    ServerName local.test.com
    DocumentRoot /var/www/local.test.com/public_html

    <Directory /var/www/local.test.com/public_html>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

### Enable Virtual Hosts
```bash
sudo a2ensite local.example.com.conf
sudo a2ensite local.test.com.conf # Optional
sudo systemctl restart apache2
```

## Step 4: Install and Set Up WordPress

### Download and Extract WordPress
```bash
cd /var/www/local.example.com/public_html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz
```

### Configure Database
Access MySQL:
```bash
sudo mysql -u root -p
```

Create database and user:
```sql
CREATE DATABASE wordpress_db;
CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'root@root12';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Configure WordPress
```bash
sudo cp wp-config-sample.php wp-config.php
```

Update database configuration in `wp-config.php`:
```php
define('DB_NAME', 'wordpress_db');
define('DB_USER', 'wordpress_user');
define('DB_PASSWORD', 'root@root12');
define('DB_HOST', 'localhost');
```

### Set Permissions
```bash
sudo chown -R www-data:www-data /var/www/local.example.com/public_html
sudo chmod -R 755 /var/www/local.example.com/public_html
```

## Step 5: Automate WordPress Setup for Second Domain

### Install WP-CLI
```bash
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
```

### Create Automation Script
Create `/usr/local/bin/wordpress-setup.sh`:
```bash
#!/bin/bash

set -e  # Exit immediately if a command fails

DOMAIN=$1
DB_NAME="${DOMAIN}_db"
DB_USER="wordpress_user"
DB_PASSWORD="root@root12"
WP_ADMIN_USER="admin"
WP_ADMIN_PASS="Root@Root12"
WP_ADMIN_EMAIL="admin@$DOMAIN"

# Validate input
if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "🚀 Setting up WordPress for $DOMAIN..."

sudo mkdir -p /var/www/$DOMAIN/public_html
cd /var/www/$DOMAIN/public_html

if [ ! -f "wp-config-sample.php" ]; then
    echo "📥 Downloading WordPress..."
    wp core download --allow-root
else
    echo "✅ WordPress already exists. Skipping download."
fi

echo "📦 Configuring MySQL..."
sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

if [ ! -f "wp-config.php" ]; then
    echo "⚙️ Configuring wp-config.php..."
    wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --allow-root
else
    echo "✅ wp-config.php already exists. Skipping configuration."
fi

if ! wp core is-installed --allow-root; then
    echo "🌐 Installing WordPress..."
    wp core install --url="http://$DOMAIN" --title="WordPress on $DOMAIN" \
        --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS \
        --admin_email=$WP_ADMIN_EMAIL --allow-root
else
    echo "✅ WordPress is already installed."
fi

echo "🛠 Setting permissions..."
sudo chown -R www-data:www-data /var/www/$DOMAIN/public_html
sudo chmod -R 755 /var/www/$DOMAIN/public_html

VHOST_PATH="/etc/apache2/sites-available/$DOMAIN.conf"
if [ ! -f "$VHOST_PATH" ]; then
    echo "📝 Creating Apache Virtual Host for $DOMAIN..."
    sudo tee $VHOST_PATH > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@$DOMAIN
    ServerName $DOMAIN
    DocumentRoot /var/www/$DOMAIN/public_html

    <Directory /var/www/$DOMAIN/public_html>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

    # Enable site and restart Apache
    sudo a2ensite $DOMAIN.conf
    sudo systemctl restart apache2
else
    echo "✅ Virtual Host already exists for $DOMAIN."
fi

# 8️⃣ Update /etc/hosts (For local testing)
echo "📝 Updating /etc/hosts..."
if ! grep -q "127.0.0.1 $DOMAIN" /etc/hosts; then
    echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
fi

echo "🎉 WordPress setup completed for $DOMAIN!"
echo "🌐 Visit: http://$DOMAIN"

```

Make script executable:
```bash
sudo chmod +x /usr/local/bin/wordpress-setup.sh
```

## Step 6: Create Web Page to Trigger Automation

### Create HTML Form
Create `index.html`:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WordPress Auto Setup</title>
</head>
<body>
    <h2>Enter Domain Name to Install WordPress</h2>
    <form action="setup.php" method="POST">
        <label for="domain">Domain Name:</label>
        <input type="text" id="domain" name="domain" required>
        <button type="submit">Deploy WordPress</button>
    </form>
</body>
</html>
```

### Create PHP Script
Create `setup.php`:
```php
<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $domain = escapeshellarg($_POST["domain"]); 
    if (!preg_match("/^[a-zA-Z0-9.-]+$/", $domain)) {
        die("Invalid domain name.");
    }
    $output = shell_exec("sudo /usr/local/bin/setup-wordpress-wpcli.sh $domain 2>&1");
    echo "<pre>$output</pre>";
} else {
    echo "Invalid request.";
}
?>
```

### Set Web Interface Permissions
```bash
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

### Update Default Apache Configuration
Edit `/etc/apache2/sites-available/000-default.conf`:
```apache
<VirtualHost *:80>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### Restart Services
```bash
sudo systemctl restart apache2
sudo systemctl restart mysql
```

## Step 7: Update DNS or Hosts File

### Local Hosts Configuration
Edit `/etc/hosts`:
```bash
127.0.0.1       local.example.com
127.0.0.1       local.test.com
```

### DNS Configuration
If using a domain:
1. Access your domain registrar's DNS settings
2. Add an A record pointing to your EC2 instance's public IP
3. Wait for DNS propagation (up to 48 hours)

### Clear DNS Cache

**Linux**:
```bash
# If using systemd-resolved
sudo systemctl restart systemd-resolved

# Alternative method
sudo resolvectl flush-caches
```

**macOS**:
```bash
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

**Windows**:
```powershell
ipconfig /flushdns
```

## Step 8: Access WordPress

### Testing URLs
- Main site: `http://local.example.com`
- Automation interface: `http://your-ec2-public-ip`

## Troubleshooting

### Common Issues and Solutions
1. **Connection Refused**
   - Check security groups
   - Verify service status
   - Confirm port configuration

2. **DNS Issues**
   - Verify DNS records
   - Clear DNS cache
   - Check hosts file configuration

3. **Permission Problems**
   - Verify file ownership
   - Check directory permissions
   - Confirm Apache configuration

Need help? Feel free to open an issue! 💡
