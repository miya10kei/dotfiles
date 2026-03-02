export AWS_CONFIG_FILE="$HOME/.config/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.config/aws/credentials"
export AWS_PROFILE=in-house

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
    cmd="aws ecs execute-command --cluster $cluster --task $task --container $container --interactive --command bash"
    echo -e "\e[32m\$$cmd\e[m"
    print -s $cmd
    eval $cmd
  }

  function dive-ec2() {
    aws-check-session
    instanceId=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.State.Name="running") | [.InstanceId, (.Tags[] | select(.Key == "Name").Value)] | @tsv' | fzf | awk '{print $1}')
    if [ -z "$instanceId" ]; then
      return
    fi
    cmd="aws ssm start-session --target $instanceId"
    echo -e "\e[32m\$$cmd\e[m"
    print -s $cmd
    eval $cmd
  }

  function aws-logs() {
    aws-check-session

    local logGroups=""
    local nextToken=""
    while true; do
      if [ -z "$nextToken" ]; then
        result=$(aws logs describe-log-groups --output json)
      else
        result=$(aws logs describe-log-groups --next-token "$nextToken" --output json)
      fi

      logGroups+=$(echo "$result" | jq -r '.logGroups[].logGroupName')$'\n'
      nextToken=$(echo "$result" | jq -r '.nextToken // empty')

      [ -z "$nextToken" ] && break
    done

    logGroupName=$(echo "$logGroups" | fzf)
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

    # Get parameter names by prefix
    local param_names=$(aws ssm get-parameters-by-path \
      --path "$selected_prefix" \
      --recursive \
      --query 'Parameters[].Name' \
      --output text)

    if [ -z "$param_names" ]; then
      echo "No parameters found with prefix: $selected_prefix"
      return 0
    fi

    # Get parameter values
    for name in ${=param_names}; do
      local value=$(aws ssm get-parameter \
        --name "$name" \
        --with-decryption \
        --query 'Parameter.Value' \
        --output text 2>/dev/null)

      if [ $? -eq 0 ]; then
        printf "%-50s : %s\n" "$name" "$value"
      else
        printf "%-50s : [ERROR: Failed to retrieve]\n" "$name"
      fi
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

