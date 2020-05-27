set -e

cp -f $HELPER_SCRIPTS/warmup.ps1 /home/AzDevOps/actions-warmup.ps1
cp -f $HELPER_SCRIPTS/warmup.sh /warmup.sh

chown AzDevOps /home/AzDevOps/actions-warmup.ps1
chown AzDevOps /warmup.sh
chmod u+x /warmup.sh
