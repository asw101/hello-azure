git checkout dev
git branch -d master
git checkout --orphan master dev
git branch -D master
git commit -m "Squash & Merge"
git push -f --set-upstream origin master
hub browse