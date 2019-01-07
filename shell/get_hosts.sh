#!/bin/bash
set -e

PROD_API_KEY='c9a018400f9e11e9970575215512b93a'
PROD_URL='http://sjc-mon-master1.cisco.com/api/v1/query?get=hosts&columns[]=name'
STG_API_KEY='34b24e500f9d11e98359296e3579dd36'
STG_URL='http://sjc-wasl-mon1.cisco.com/api/v1/query?get=hosts&columns[]=name'

ENV_LVL=${1:-'all'}

collect_hosts() {
  key=$1
  url=$2
  envs="$envs\n"`curl -g -H "X-Auth-Token: $key" "$url" -s | jq -r .[].name`
}

if [ "$ENV_LVL" != 'prd' ] && [ "$ENV_LVL" != 'stg' ] && [ "$ENV_LVL" != 'all' ]; then
  echo 'Usage: ./get_hosts.sh [prd|stg|all]'
  exit 1
else
  # get list of hostnames from check_mk
  if [ "$ENV_LVL" == 'prd' ] || [ "$ENV_LVL" == 'all' ]; then
    collect_hosts $PROD_API_KEY $PROD_URL
  fi

  if [ "$ENV_LVL" == 'stg' ] || [ "$ENV_LVL" == 'all' ]; then
    collect_hosts $STG_API_KEY $STG_URL
  fi
fi

set +e

# while the env set is not empty
while [[ ${envs} != '' ]]; do

  printf "$envs\n\n"
  printf "grep "
  read searchParam

  # if search term is empty, copy env set to clipboard and exit
  if [[ $searchParam == '' ]]; then
    echo $envs | pbcopy
    echo "Final list:"
    echo $envs
    exit 0
  fi

  # replace current environment set with filtered set
  envs=`echo "$envs" | grep $searchParam`
done

echo "No environments match your filter. Terminating..."
exit 1
