#!/bin/bash

set -e

DOMAIN=$1
DB_NAME="${DOMAIN//./_}_db"  # Or DB_NAME="${DOMAIN}_db" if you prefer
DB_USER="wordpress_user1"
DB_PASSWORD=$(openssl rand -base64 32) # Generate strong password
WP_ADMIN_USER="admin"
WP_ADMIN_PASS="root@root12@Root12" # Generate strong password
WP_ADMIN_EMAIL="admin@$DOMAIN"

# Validate input
if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "🚀 Setting up WordPress for $DOMAIN..."

# 1️⃣ Create website directory
sudo mkdir -p /var/www/$DOMAIN/public_html
cd /var/www/$DOMAIN/public_html

# 2️⃣ Download WordPress if not exists
if [ ! -f "wp-config-sample.php" ]; then
    echo "📥 Downloading WordPress..."
    wp core download --allow-root
else
    echo "✅ WordPress already exists. Skipping download."
fi

# 3️⃣ Create MySQL database (Corrected - Crucial fix here)
echo "📦 Configuring MySQL..."

mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -u root -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';" # Create user first
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';" # Grant privileges
mysql -u root -e "FLUSH PRIVILEGES;"

# 4️⃣ Create wp-config.php
if [ ! -f "wp-config.php" ]; then
    echo "⚙️ Configuring wp-config.php..."
    wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass="$DB_PASSWORD" --allow-root # Quote $DB_PASSWORD
else
    echo "✅ wp-config.php already exists. Skipping configuration."
fi

# 5️⃣ Install WordPress
if ! wp core is-installed --allow-root; then
    echo "🌐 Installing WordPress..."
    wp core install --url="http://$DOMAIN" --title="WordPress on $DOMAIN" \
        --admin_user=$WP_ADMIN_USER --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" --allow-root  # Quote passwords
else
    echo "✅ WordPress is already installed."
fi

# 6️⃣ Set permissions
echo "🛠 Setting permissions..."
sudo chown -R www-data:www-data /var/www/$DOMAIN/public_html
sudo chmod -R 755 /var/www/$DOMAIN/public_html

# 7️⃣ Create Apache Virtual Host
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