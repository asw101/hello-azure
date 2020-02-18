# README

## Clone repo(s)
```bash
hub clone cloud-actions/python-actions-flask-aci
hub clone cloud-actions/golang-actions-http-aci
hub clone cloud-actions/docker-actions-nginx-aci
hub clone cloud-actions/python-actions-vscode-flask-aci
hub clone cloud-actions/python-actions-vscode-django-aci
hub clone cloud-actions/docker-actions-fire-github
```

## Browse repo(s)
```bash
hub browse cloud-actions/python-actions-flask-aci
hub browse cloud-actions/golang-actions-http-aci
hub browse cloud-actions/docker-actions-nginx-aci
hub browse cloud-actions/python-actions-vscode-flask-aci
hub browse cloud-actions/python-actions-vscode-django-aci
hub browse cloud-actions/docker-actions-fire-github
```

## Misc
```bash
cd python-actions-flask-aci
cd golang-actions-http-aci
cd docker-actions-nginx-aci
cd python-actions-vscode-flask-aci
cd python-actions-vscode-django-aci
cd docker-actions-fire-github
```

## cat every DEPLOY.txt
```bash
find . -type d | grep 'azure' | while read -r line
do 
    echo "$line"
    cd $line
    cat DEPLOY.txt
    # ...
    cd ../../
done
```

## do something with every subdir
```bash
for d in */; do
    echo "$d"
done
```

## push cloned (template) repo to a new head
```bash
hub clone cloud-actions/docker-actions-nginx-aci
cd docker-actions-nginx-aci/
# create asw101/docker-actions-nginx-aci
git push git@github.com:asw101/docker-actions-nginx-aci.git HEAD:master
```
