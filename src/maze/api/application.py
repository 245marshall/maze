# from typing import Optional
from typing import Literal
from typing import List
from fastapi import FastAPI
from pydantic import BaseModel as BaseModel

from maze.generation.algorithm import Maze as _Maze
from maze.generation.algorithm import Algorithms as _Algorithms


MAX_ROW_COLUMN_PRODUCT = 1000

Algorithm = Literal["binary_search", "aldus_broder", "sidewinder"]


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


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/maze/{algorithm}/", response_model=MazeOutput)
def read_maze_algorithm(algorithm: Algorithm, rows: int, columns: int) -> MazeOutput:
    if rows * columns > MAX_ROW_COLUMN_PRODUCT:
        raise ValueError()
    maze = _Maze(rows, columns)
    data = maze.generate_maze(_Algorithms[algorithm.upper()])

    return data
