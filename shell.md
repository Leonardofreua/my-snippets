### Count how many lines a java project has

```bash
find . -name '*.java' ! -name "Q*.java" ! -path "./target/*" -type f -print0 | xargs -0 cat | wc -l
```