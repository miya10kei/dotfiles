export AWS_CONFIG_FILE="$HOME/.config/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.config/aws/credentials"

if builtin command -v aws-vault > /dev/null 2>&1; then if builtin command -v pass > /dev/null 2>&1; then
    export AWS_VAULT_BACKEND=pass
    export AWS_VAULT_PASS_PREFIX=aws-vault
  fi

  function exec_aws_command() {
    cmd=$1
    echo -e "\e[32m\$$cmd\e[m"
    print -s $cmd
    eval $cmd
  }

  function aws-check-session() {
    aws sts get-caller-identity > /dev/null
  }

  function aws-sw() {
    export AWS_PROFILE=$(aws-vault list --profiles | grep -v -E "sso|default" | sort | fzf)
  }

  function aws-rg-sw() {
    aws-check-session
    region=$(aws ec2 describe-regions | jq -r '.Regions[].RegionName' | sort | fzf)
    if [ -z "$region" ]; then
      return
    fi
    export AWS_DEFAULT_REGION=$region
  }


  function dive-ecs() {
    aws-check-session
    cluster=$(aws ecs list-clusters | jq -r ".clusterArns[]" | sed 's/.*\///g' | fzf)
    if [ -z "$cluster" ]; then
      return
    fi
    service=$(aws ecs list-services --cluster $cluster | jq -r ".serviceArns[]" | sed 's/.*\///g' | fzf)
    if [ -z "$service" ]; then
      return
    fi
    task=$(aws ecs list-tasks --cluster $cluster --service-name $service | jq -r ".taskArns[]" | sed 's/.*\///g' | fzf)
    if [ -z "$task" ]; then
      return
    fi
    container=$(aws ecs describe-tasks --cluster $cluster --task $task | jq -r '.tasks[].containers[].name' | fzf)
    if [ -z "$container" ]; then
      return
    fi
    exec_aws_command "aws ecs execute-command --cluster $cluster --task $task --container $container --interactive --command bash"
  }

  function dive-ec2() {
    aws-check-session
    instanceId=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.State.Name == "running") | [.InstanceId, (.Tags[] | select(.Key == "Name").Value)] | @tsv' | fzf | awk '{print $1}')
    if [ -z "$instanceId" ]; then
      return
    fi
    exec_aws_command "aws ssm start-session --target $instanceId"
  }

  function dive-cognito() {
    aws-check-session
    poolId=$(aws cognito-idp list-user-pools --max-results 60 | jq -r '.UserPools[] | [.Name, .Id] | @tsv' | column -t | fzf | awk '{print $2}')
    if [ -z "$poolId" ]; then
      return
    fi
    username=$(aws cognito-idp list-users --user-pool-id $poolId | jq -r '.Users[] | [.Username, .UserStatus] | @tsv' | column -t | fzf | awk '{print $1}')
    if [ -z "$username" ]; then
      return
    fi
    exec_aws_command "aws cognito-idp admin-get-user --user-pool-id $poolId --username $username"
  }

  function aws-logs() {
    aws-check-session
    # AWS CLI v2 は自動でページ送りして全件を返す
    logGroupName=$(aws logs describe-log-groups --query 'logGroups[].logGroupName' --output text | tr '\t' '\n' | fzf)
    if [ -z "$logGroupName" ]; then
      return
    fi
    exec_aws_command "aws logs tail --since 1h --format short --follow $logGroupName"
  }

  function aws-params() {
    aws-check-session

    echo "Getting parameter paths..."

    # Get all parameter names and extract unique path prefixes
    local all_params=$(aws ssm describe-parameters \
      --query 'Parameters[].Name' \
      --output text)

    if [ -z "$all_params" ]; then
      echo "No parameters found in current AWS account/region"
      return 0
    fi

    # Extract unique path prefixes (up to 3 levels deep)
    local prefixes=$(echo "$all_params" | tr '\t' '\n' | \
      sed -E 's|(/[^/]+/[^/]+/?).*|\1|' | \
      sort -u | \
      grep -E '^/[^/]+(/[^/]+)?/?$')

    # Let user select a prefix with fzf
    local selected_prefix=$(echo "$prefixes" | fzf \
      --prompt="Select parameter path: " \
      --preview="aws ssm get-parameters-by-path --path {} --query 'Parameters[].Name' --output text | head -10" \
      --preview-window=right:50%)

    if [ -z "$selected_prefix" ]; then
      echo "No path selected"
      return 0
    fi

    echo "Searching for parameters with prefix: $selected_prefix"
    echo "========================================"

    # 名前と値を1回のAPI呼び出し（自動ページ送り）でまとめて取得する
    local params
    params=$(aws ssm get-parameters-by-path \
      --path "$selected_prefix" \
      --recursive \
      --with-decryption \
      --query 'Parameters[].[Name,Value]' \
      --output json) || return 1

    if [[ $(jq length <<< "$params") -eq 0 ]]; then
      echo "No parameters found with prefix: $selected_prefix"
      return 0
    fi

    jq -r '.[] | @tsv' <<< "$params" | while IFS=$'\t' read -r name value; do
      printf "%-50s : %s\n" "$name" "$value"
    done
  }


  function aws-kb-sync() {
    aws-check-session
    knowledgeBaseId=$(aws bedrock-agent list-knowledge-bases | jq -r '.knowledgeBaseSummaries[] | [.name, .knowledgeBaseId] | @tsv' | column -t | fzf | awk '{print $2}')
    if [ -z "$knowledgeBaseId" ]; then
      return
    fi

    dataSourceId=$(aws bedrock-agent list-data-sources --knowledge-base-id $knowledgeBaseId | jq -r '.dataSourceSummaries[] | [.name, .dataSourceId, .status] | @tsv' | column -t | fzf | awk '{print $2}')
    if [ -z "$dataSourceId" ]; then
      return
    fi

    ingestionJobId=$(aws bedrock-agent start-ingestion-job --knowledge-base-id $knowledgeBaseId --data-source-id $dataSourceId | jq -r '.ingestionJob.ingestionJobId')

    if [ -z "$ingestionJobId" ]; then
      echo "ingestionJobId is Not Found"
      return
    fi

    exec_aws_command "watch -tcd \"aws bedrock-agent get-ingestion-job --knowledge-base-id $knowledgeBaseId --data-source-id $dataSourceId --ingestion-job-id $ingestionJobId\""
  }

  function aws-br-prompts() {
    aws-check-session
    promptIdentifier=$(aws bedrock-agent list-prompts | jq -r '.promptSummaries[] | [.name, .id] | @tsv' | column -t | fzf | awk '{print $2}')
    if [ -z "$promptIdentifier" ]; then
      return
    fi

    exec_aws_command "aws bedrock-agent get-prompt --prompt-identifier $promptIdentifier | jq -r '.variants[0].templateConfiguration.chat.system[0].text'"
  }

fi

