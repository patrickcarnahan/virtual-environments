useradd --create-home AzDevOps
usermod -a -G docker AzDevOps
usermod -a -G adm AzDevOps
echo 'AzDevOps ALL=NOPASSWD: ALL' >> /etc/sudoers

mkdir -p /agent
chown -R AzDevOps /agent
