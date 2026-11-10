人物ノート。

```base
filters:
  and:
    - categories.contains(link("People"))
    - '!file.inFolder("Templates")'
views:
  - type: table
    name: People
    order:
      - file.name
      - reading
      - roles
    sort:
      - property: file.name
        direction: ASC
```
