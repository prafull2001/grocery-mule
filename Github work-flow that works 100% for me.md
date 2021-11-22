This is a curated git workflow that is proven to work. You are welcome to go with what works for you, but if you are unsure just follow the suggestions and commands mentioned below.

### One time actions

1. Fork main repo (on github.com)
   - This is done by clicking on the `Fork` button on https://github.com/jainvipin/gitt

2. Clone your fork
```
$ git clone https://github.com/<your-github-id>/gitt
```

3. Add remote upstream
```
$ git remote add upstream https://github.com/jainvipin/gitt

# now git remote -v should show it appropriately, confirm by doing
$ git remote -v
origin     https://github.com/<your-github-id>/gitt (fetch)
origin     https://github.com/<your-github-id>/gitt (push)
upstream   https://github.com/jainvipin/gitt (fetch)
upstream   https://github.com/jainvipin/gitt (push)
```

### One time for every feature

1. Create a branch to work on feature e.g. feature-foo
```
$ git checkout -b feature-foo
```

### For every change in a feature

1. Switch branches (if the feature branch is already created)
```
$ git checkout feature-foo
```

2. Make changes, edit files, commit to your local repo
```
# make your edits to one or more files in the repo
$ vi foo.c

# check status of all modified/added files
$ git status

# check the diffs to make sure the diffs only contain intended changes
$ git diff

# git add can add specific files or all modified files at once (if no file/dir is specified)
$ git add

# commit the changes to the branch
$ git commit -m "comment for this change"
```

3. When you are ready, push the changes
```
$ git push

# if git push is done first time when a branch is set, you might need to set upstream
$ git push -f --set-upstream origin feature-foo

# this would trigger the sanity run, and let you know if there was a failure
```

4. Say sanity failed, or you got comments to incorporate, and you need to make more changes
```
# checkout branch and commit new changes
$ git checkout feature-foo
$ vi foo.c
$ git add foo.c
$ git commit -m "fixed sanity failure" --amend

# push the new commit; if you'd like to rebase (merge) changes from upstream, see rebase instructions later
$ git push
# this would re-trigger the sanity run, and let you know if there was a failure
```

### How to rebase with main and resubmit

1. Fetch main and Rebase
```
# from any branch (note that each branch is independent of each other and also your main)
$ git fetch upstream main
$ git rebase upstream/main
<may have conflicts, resolve them as follows>
   $ git add .
   $ git rebase --continue
```

2. Push rebased changes
```
# force push is needed because your branch has diverged and SHAs have changed
# you can choose to not force push, but you'll have to dod 'git merge` instead of 'git rebase above'
$ git push -f
    
# this would trigger the sanity run and confirm if sanity passes
```

### Working on multiple branches
Each Branch is independent with respect to the following:
  - You can do make another change in a different branch
  - Rebase with main independent of other branches
  - Push the changes independently
  - Run sanities independently
  - Commit/Merge independently

Note: when you switch between branches the changes must be committed to the local clone, but this is like stashing your changes.

### Keeping your main up to date with upstream main
```
$ git fetch upstream main
$ git rebase upstream/main
```
Keeping main up to date with main ensures that when a new branch is created it has the latest copy of upstream main.

### Squashing commits or merginig multiple commits with head reset
```
# Say, you have two commits that you'd like to squash and force-push them as one commit
$ git reset HEAD~2
$ git add .
$ git commit -m "new commit message for both commits"
$ git push -f origin <branch>

# You can also use interactively squash commits using 
$ git reset -i HEAD~2
# This will open a file editor that will allow you to pick/squash specific commits, write the file after you are done
```

### Deleting a branch
After a series of commit has gone into a branch, and feature development/testing is complete, a branch can be easily deleted using
```
$ git branch -d feature-foo
```