-- GitHub Actions のワークフローなど一般的なスキーマは、yaml-language-server が SchemaStore から自動で当てる
---@type vim.lsp.Config
return {
  -- nvim-lspconfig の既定の filetypes に、ワークフロー用の yaml.ghaction を加える
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values", "yaml.ghaction" },
  settings = {
    yaml = {
      -- 整形は conform の yamlfmt で行う
      format = { enable = false },
      -- CloudFormation / SAM の組み込み関数
      customTags = {
        "!And scalar",
        "!And sequence",
        "!Base64 scalar",
        "!Cidr scalar",
        "!Cidr sequence",
        "!Condition scalar",
        "!Equals sequence",
        "!FindInMap sequence",
        "!GetAZs scalar",
        "!GetAtt scalar",
        "!GetAtt sequence",
        "!If sequence",
        "!ImportValue scalar",
        "!ImportValue mapping",
        "!Join sequence",
        "!Not sequence",
        "!Or sequence",
        "!Ref scalar",
        "!Select sequence",
        "!Split sequence",
        "!Sub scalar",
        "!Sub sequence",
        "!Transform mapping",
      },
      schemas = {
        ["https://raw.githubusercontent.com/aws/aws-sam-cli/master/schema/samcli.json"] = "samconfig.yaml",
        ["https://raw.githubusercontent.com/aws/serverless-application-model/develop/samtranslator/validator/sam_schema/schema.json"] = "template*.yaml",
      },
    },
  },
}
