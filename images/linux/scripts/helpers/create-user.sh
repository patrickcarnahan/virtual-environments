useradd --create-home AzDevOps
usermod -a -G docker AzDevOps
usermod -a -G systemd-journal AzDevOps

mkdir -p /agent
chown -R AzDevOps /agent

echo "AzDevOps hard priority 0" >> /etc/security/limits.conf
