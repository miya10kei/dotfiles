export AWS_PROFILE=pd

if builtin command -v aws-vault > /dev/null 2>&1; then
    if builtin command -v pass > /dev/null 2>&1; then
        export AWS_VAULT_BACKEND=pass
        export AWS_VAULT_PASS_PREFIX=aws-vault
    fi
fi

if builtin command -v aws-vault > /dev/null 2>&1; then
  function aws-sw() {
    export AWS_PROFILE=$(aws-vault list --profiles | grep -v -E "sso|default" | sort | fzf)
  }
fi

if builtin command -v aws > /dev/null 2>&1; then
  function dive-ecs() {
    aws sts get-caller-identity > /dev/null
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
    aws sts get-caller-identity > /dev/null
    instanceId=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.State.Name="running") | [.InstanceId, (.Tags[] | select(.Key == "Name").Value)] | @tsv' | fzf | awk '{print $1}')
    if [ -z "$instanceId" ]; then
      return
    fi
    cmd="aws ssm start-session --target $instanceId"
    echo -e "\e[32m\$$cmd\e[m"
    print -s $cmd
    eval $cmd
  }
fi
