# git

## working on code

see changed files

```bash
git st
```

commit changed files

```bash
git ci -a -m"docs: export requirements file"
```

amend last commit with staged changes

```bash
git amend -a
git amend -a -m"docs: useful git commands"
```

add untracked file to git

```bash
git add docs/git.md
```

rebase to the beginning

```bash
git rebase --interactive --root main
```
