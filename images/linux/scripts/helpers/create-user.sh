useradd --create-home AzDevOps
usermod -a -G docker AzDevOps

mkdir -p /agent
chown -R AzDevOps /agent
