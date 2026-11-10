---
categories:
  - "[[Meeting Series]]"
created_at: {{date:YYYY-MM-DD}} {{time:HH:mm:ss}}
title: "{{title}}"
---

%% categories を [[Meetings]] にしない。索引ノート自体が横断一覧に混ざるため %%

## 開催回

```base
filters:
  and:
    - categories.contains(link("Meetings"))
    - series == link("{{title}}")
views:
  - type: table
    name: 開催回
    order:
      - file.name
      - date
      - time
      - attendees
    sort:
      - property: date
        direction: DESC
```

## 継続論点

各論点の詳細はリンク先を参照。決着した論点はここから外す。

- 論点の要約 — [[YYYY-MM-DD_シリーズ名#見出し|YYYY-MM-DD 見出し]]
