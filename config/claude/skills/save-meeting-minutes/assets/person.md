---
categories:
  - "[[People]]"
reading:
roles:
  -
created_at: {{date:YYYY-MM-DD}} {{time:HH:mm:ss}}
---

%%
記入ルール
- ファイル名: フルネーム.md（姓名の間に空白を入れない）、置き場所: People/
- reading は読みをひらがなで、姓と名の間は半角スペース
- aliases に姓は入れない（同姓の人と区別できなくなるため）
- 下の base の link("{{title}}") はファイル名と一致させる
%%

## 出席した会議

```base
filters:
  and:
    - categories.contains(link("Meetings"))
    - attendees.contains(link("{{title}}"))
views:
  - type: table
    name: 出席した会議
    order:
      - file.name
      - date
      - time
      - series
    sort:
      - property: date
        direction: DESC
```

## 未完了アクション

```dataview
TASK
FROM "Meetings"
WHERE !completed AND contains(flat(list(assignee)), this.file.link)
```
