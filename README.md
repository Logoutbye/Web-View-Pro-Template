please donot push your local changes to this repo
and if you wish to add this existing repo after local changes to new repo follow the steps below:
1. git remote -v  "to check the git repository"
2. git remote remove origin "to remove the git repository"
4. git remote -v  "to check the git repository"
5. git init 
6. git remote add origin <remote_url> 
7. git commit -am "commit message" 
8. git push origin master 