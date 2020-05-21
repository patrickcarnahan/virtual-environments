set -e

powershell=$(which pwsh)

cat << EOF > /etc/systemd/system/actions-warmup.service
[Unit]
Description=Run the azdevnext warmup during bootup before login is allowed
After=docker.service
Before=getty.target

[Service]
Type=oneshot
RemainAfterExit=yes
User=AzDevOps
WorkingDirectory=/agent/_work/1/s
ExecStart=${powershell} -File /usr/local/bin/actions-warmup.ps1

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /usr/local/bin/actions-warmup.ps1
./init.ps1
Import-Module ./Scripts/lib/DeploymentUtilities.psm1
Start-Cluster -Driver 'docker' -UseAllResources \$true
git reset --hard HEAD
EOF

# setup the actions-warmup service to start on boot
systemctl daemon-reload
systemctl enable actions-warmup.service
