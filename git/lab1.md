# Create a new directory and initialize it as a Git repository
mkdir my_project
cd my_project
git init

# Create a file called main.txt and add some text to it
echo "Initial text" > main.txt

# Check the status of the repository
git status

# Stage the file for commit
git add main.txt

# Commit the file to the repository
git commit -m "Add initial main.txt file"

# Create a new branch called experiment
git branch experiment

# Switch to the experiment branch
git checkout experiment

# Edit the main.txt file and add some additional text
echo "Additional text in experiment branch" >> main.txt

# Commit the changes to the experiment branch
git commit -a -m "Add additional text in experiment branch"

# Switch back to the master branch
git checkout master

# Edit the main.txt file and add some additional text
echo "Additional text in master branch" >> main.txt

# Commit the changes to the master branch
git commit -a -m "Add additional text in master branch"

# Merge the experiment branch into the master branch
git merge experiment

# After Merge add the file and commit it 
git add main.txt
git commit -m "Resolve merge conflict in main.txt"
# Create a new branch called experiment2
git branch experiment2

# Switch to the experiment2 branch
git checkout experiment2

# Edit the main.txt file and add some additional text
echo "Additional text in experiment2 branch" >> main.txt

# Commit the changes to the experiment2 branch
git commit -a -m "Add additional text in experiment2 branch"

# Switch back to the master branch
git checkout master

# Edit the main.txt file and add some additional text
echo "Conflicting text" >> main.txt

# Commit the changes to the master branch
git commit -a -m "Add conflicting text in master branch"

# Attempt to merge the experiment2 branch into the master branch
git merge experiment2

# Check the status of the repository
git status

# View the differences between the conflicting branches
git diff

# Manually resolve the merge conflict in main.txt

# Stage the resolved file for commit
git add main.txt

# Commit the resolved file and complete the merge
git commit -m "Resolve merge conflict between master and experiment2"

# View the commit history of the repository
git log

# delete commit history  only not changes of the repository:
```bash
git reset --soft HEAD~1
```

# delete commit history and changes of the repository:
```bash
git reset --hard HEAD~1
```
# to get file back after deleting it :
```bash
git checkout -- filename.txt
git restore  filename # this will restore the file from trash
```


## Git Stash 
This command is used to stash a commit history into the repository:
```bash
git stash
git stash pop # 

```
This command is used to stash a commit history into the repository with a message:

## 