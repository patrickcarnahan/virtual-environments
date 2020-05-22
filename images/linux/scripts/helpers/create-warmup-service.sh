set -e

cat << EOF > /warmup.sh
pwsh -File ~/actions-warmup.ps1 > ~/actions-warmup.log
EOF

cp -f $HELPER_SCRIPTS/warmup.ps1 /home/AzDevOps/actions-warmup.ps1
chown AzDevOps /home/AzDevOps/actions-warmup.ps1

chown AzDevOps /warmup.sh
chmod u+x /warmup.sh
