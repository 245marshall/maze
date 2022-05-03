# Mazes
Implements algorithms from Mazes for Programmers utilizing Cython and presents them using FastAPI.

# Setup Development
Developers must have the following installed:
* npm
* python3

```
cd maze
python3 -m pip install -r requirements/base.txt
python3 -m pip install -e .
```

# Build Backend Package
Build the backend with
```
python3 setup.py build_ext
python3 setup.py bdist_wheel
```

# API
Launch the API with 
```
uvicorn maze.api.application:app --reload
```

# React App
Launch the React Application with
```
cd maze/src/web
npm start
```
