MTG の議事録。

```base
filters:
  and:
    - categories.contains(link("Meetings"))
    - '!file.inFolder("Templates")'
views:
  - type: table
    name: 日付順
    order:
      - file.name
      - date
      - time
      - series
      - attendees
    sort:
      - property: date
        direction: DESC
  - type: table
    name: シリーズ別
    groupBy:
      property: series
      direction: ASC
    order:
      - file.name
      - date
      - time
      - attendees
    sort:
      - property: date
        direction: DESC
```

## 未完了アクション

```dataview
TASK
FROM "Meetings"
WHERE !completed
FLATTEN assignee AS person
GROUP BY person
```
