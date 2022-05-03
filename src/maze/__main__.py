import argparse
import time

from maze.generation.algorithm import Maze, Algorithms
from maze.presentation.terminal import present

def main():
    algos = [
        Algorithms.BINARY_SEARCH.name.lower(),
        Algorithms.SIDEWINDER.name.lower(),
        Algorithms.ALDUS_BRODER.name.lower(),
    ]

    parser = argparse.ArgumentParser("maze")
    parser.add_argument("rows", type=int, help="number of rows in the maze")
    parser.add_argument("columns", type=int, help="number of columns in the maze")
    parser.add_argument("--algorithm", default="binary_search", choices=algos, help="which algorithm to use")
    parser.add_argument("--timeit", action="store_true")

    args = parser.parse_args()

    if args.rows * args.columns > 1000 and not args.timeit:
        raise RuntimeError("rows x columns > 1000 not supported")

    start = time.time()

    maze = Maze(args.rows, args.columns)
    gen = maze.generate_maze(Algorithms[args.algorithm.upper()])

    diff = time.time() - start
    if not args.timeit:
        present(gen)
    else:
        print(diff)

if __name__ == "__main__":
    main()
