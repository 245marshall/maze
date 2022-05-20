# from typing import Optional
from typing import Literal
from typing import List
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel as BaseModel

from maze.generation.algorithm import Maze as _Maze
from maze.generation.algorithm import Algorithms as _Algorithms


MAX_ROW_COLUMN_PRODUCT = 10000

Algorithm = Literal[
    "binary_search",
    "aldus_broder",
    "sidewinder"
]

origins = [
    "http://localhost:3000",
    "http://localhost",
]

class CellOutput(BaseModel):
    row: int
    column: int
    walls: str
    distance: int


class MazeOutput(BaseModel):
    rows: int
    columns: int
    maze: List[CellOutput]


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/maze/{algorithm}", response_model=MazeOutput)
def read_maze_algorithm(algorithm: Algorithm, rows: int, columns: int) -> MazeOutput:
    if rows * columns > MAX_ROW_COLUMN_PRODUCT:
        raise ValueError()
    maze = _Maze(rows, columns)
    data = maze.generate_maze(_Algorithms[algorithm.upper()])
    return data
