export AWS_PROFILE=pd

if builtin command -v aws-vault > /dev/null 2>&1; then
    if builtin command -v pass > /dev/null 2>&1; then
        export AWS_VAULT_BACKEND=pass
        export AWS_VAULT_PASS_PREFIX=aws-vault
    fi
fi
