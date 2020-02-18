# README

# python-cli

```bash
cd python-cli/

python3 --version
python3 -m venv env
source env/bin/activate
pip install fire
pip freeze > requirements.txt

code-insiders simple.py
python simple.py multiply 1 2

deactivate
```

# python-web

```bash
cd python-web/

python3 --version
python3 -m venv env
source env/bin/activate
pip install flask
pip freeze > requirements.txt

code-insiders main.py
env FLASK_APP=hello.py flask run --host 127.0.0.1 --port 5000

deactivate
```

# golang-cli

```bash
cd golang-cli/

go run . --help

go run . repeat -n 3 hello

go run . count hello world
```

# golang-web

```bash
cd golang-web/

go run main.go

LISTEN_PORT=8080 go run main.go
```

## Resources
- [google/python-fire](https://github.com/google/python-fire)
- [pallets/flask](https://www.palletsprojects.com/p/flask/)
- [peterbourgon/ff/ffcli](https://github.com/peterbourgon/ff/tree/master/ffcli)
- [net/http](https://golang.org/pkg/net/http/#pkg-examples)
