# We want to walk cells and manipulate their walls by toggling them on and off. The
# issue is that walls are shared between cells. We will create an array of cells
# and reference the walls by a numerical relationship.
#
#                 _   _   _   _   _
#               |0,0|0,1|0,2|0,3|0,4|
#                 _   _   _   _   _
#               |1,0|1,1|1,2|1,3|1,4|
#                 _   _   _   _   _
#               |2,0|2,1|2,2|2,3|2,4|
#                 _   _   _   _   _
#
# Walls will be stored in two matrices. A north/south matrix and an east/west matrix.
# Looking at the 0,0 cell, the following are the refs for the walls:
#     north_wall = ns_matrix[0][0]
#     south_wall = ns_matrix[1][0]
#
#     west_wall = ew_matrix[0][0]
#     east_wall = ew_matrix[0][1]
#
# For the 1,1 cell, the refs are:
#     north_wall = ns_matrix[1][1]
#     south_wall = ns_matrix[2][1]
#
#     west_wall = ew_matrix[1][1]
#     east_wall = ew_matrix[1][2]
#
# For the i,j cell, the refs are:
#     north_wall = ns_matrix[i][j]
#     south_wall = ns_matrix[i + 1][j]
#
#     west_wall = ew_matrix[i][j]
#     east_wall = ew_matrix[i][j + 1]
#
from libc.stdlib cimport malloc, free

cdef extern from "stdlib.h":
    int rand()
    void srand(long int seedval)

cdef extern from "time.h":
    long int time(int)


cdef choice(int n):
    return rand() % n


cdef int* create_int_array(int length, int initial_value):
    # allocate length * sizeof(int) bytes of memory
    cdef int ix
    cdef int *arr = <int *> malloc(
        length * sizeof(int))
    if not arr:
        raise MemoryError()

    for ix in range(length):
        arr[ix] = initial_value

    return arr


cdef int index_vetch(int ix_row, int ix_col, int n_ix_rows):
    return ix_col * n_ix_rows + ix_row


cdef int* create_ns_walls(int rows, int cols):
    cdef int n = (rows + 1) * cols
    return create_int_array(n, 1)


cdef int* create_we_walls(int rows, int cols):
    cdef int n = rows * (cols + 1)
    return create_int_array(n, 1)


cdef int* create_distances_vector(int rows, int cols):
    cdef int n = rows * cols
    return create_int_array(n, -1)


cdef int* create_visits_array(int rows, int cols):
    cdef int n = rows * cols
    return create_int_array(n, 0)


cdef void set_distance(int val, int row, int col, int rows, int* distances):
    distances[col * rows + row] = val


cdef int get_distance(int row, int col, int rows, int* distances):
    return distances[col * rows + row]


cdef void set_visited(int row, int col, int rows, int* visits_array):
    visits_array[col * rows + row] = 1


cdef int get_visited(int row, int col, int rows, int* visits_array):
    return visits_array[col * rows + row]


cdef void set_north_wall(int state, int cell_row, int cell_col, int n_cell_rows, int* ns_walls):
    cdef int ix = index_vetch(cell_row, cell_col, n_cell_rows + 1)
    ns_walls[ix] = state


cdef void set_south_wall(int state, int cell_row, int cell_col, int n_cell_rows, int* ns_walls):
    cdef int ix = index_vetch(cell_row + 1, cell_col, n_cell_rows + 1)
    ns_walls[ix] = state


cdef void set_west_wall(int state, int cell_row, int cell_col, int n_cell_rows, int* we_walls):
    cdef int ix = index_vetch(cell_row, cell_col, n_cell_rows)
    we_walls[ix] = state


cdef void set_east_wall(int state, int cell_row, int cell_col, int n_cell_rows, int* we_walls):
    cdef int ix = index_vetch(cell_row, cell_col + 1, n_cell_rows)
    we_walls[ix] = state


cdef int get_north_wall(int cell_row, int cell_col, int n_cell_rows, int* ns_walls):
    return ns_walls[index_vetch(cell_row, cell_col, n_cell_rows + 1)]


cdef int get_south_wall(int cell_row, int cell_col, int n_cell_rows, int* ns_walls):
    return ns_walls[index_vetch(cell_row + 1, cell_col, n_cell_rows + 1)]


cdef int get_west_wall(int cell_row, int cell_col, int n_cell_rows, int* we_walls):
    return we_walls[index_vetch(cell_row, cell_col, n_cell_rows)]


cdef int get_east_wall(int cell_row, int cell_col, int n_cell_rows, int* we_walls):
    return we_walls[index_vetch(cell_row, cell_col + 1, n_cell_rows)]


# MAZE GENERATION ALGORITHMS

# Binary Search
cdef void binary_search(int* ns_walls, int* we_walls, int rows, int cols):
    cdef int ix, jx

    srand(time(0))

    set_west_wall(0, 0, 0, rows, we_walls)
    for ix in range(rows):
        for jx in range(cols):
            bin_rand = rand() % 2
            if (jx == cols - 1 or bin_rand == 0) and (ix != rows - 1):
                set_south_wall(0, ix, jx, rows, ns_walls)
            else:
                set_east_wall(0, ix, jx, rows, we_walls)


# Sidewinder
cdef void sidewinder(int* ns_walls, int* we_walls, int rows, int cols):
    cdef int ix, jx, choice_step
    cdef int path_start = 0
    cdef int path_iterations = 0

    srand(time(0))

    for ix in range(rows):
        for jx in range(cols):
            path_iterations += 1
            bin_rand = rand() % 2
            if ((jx == cols - 1) or (bin_rand == 0)) and (ix != rows - 1):
                choice_step = choice(path_iterations)
                set_south_wall(0, ix, jx - choice_step, rows, ns_walls)
                path_iterations = 0
            else:
                set_east_wall(0, ix, jx, rows, we_walls)


# Aldus-Broder
cdef void aldus_broder(int* ns_walls, int* we_walls, int rows, int cols):
    srand(time(0))

    cdef int rand_choice, visited
    cdef int ix = 0
    cdef int jx = 0
    cdef int* visits = create_visits_array(rows, cols)
    
    cdef int visits_remaining = rows * cols - 1  # subtract one for the starting point
    set_visited(ix, jx, rows, visits)
    
    while True:
        rand_choice = choice(4)
        if rand_choice == 0 and ix > 0:
            visited = get_visited(ix - 1, jx, rows, visits)
            if not visited:
                set_north_wall(0, ix, jx, rows, ns_walls)
                set_visited(ix - 1, jx, rows, visits)
                visits_remaining -= 1
            ix = ix - 1
        elif rand_choice == 1 and jx < cols - 1:
            visited = get_visited(ix, jx + 1, rows, visits)
            if not visited:
                set_east_wall(0, ix, jx, rows, we_walls)
                set_visited(ix, jx + 1, rows, visits)
                visits_remaining -= 1
            jx = jx + 1
        elif rand_choice == 2 and ix < rows - 1:
            visited = get_visited(ix + 1, jx, rows, visits)
            if not visited:
                set_south_wall(0, ix, jx, rows, ns_walls)
                set_visited(ix + 1, jx, rows, visits)
                visits_remaining -= 1
            ix = ix + 1
        elif rand_choice == 3 and jx > 0:
            visited = get_visited(ix, jx - 1, rows, visits)
            if not visited:
                set_west_wall(0, ix, jx, rows, we_walls)
                set_visited(ix, jx - 1, rows, visits)
                visits_remaining -= 1
            jx = jx -1
        
        if visits_remaining <= 0:
            break


# TODO: Wilson's

# SOLUTION ALGORITHMS

# dijkstra's
cdef void handle_connection(int val, int* ns_walls, int* we_walls, int* distances, int ix, int jx, int rows, int cols):
    # get: row, col, rows, arr
    cdef int north, south, east, west, dist

    dist = get_distance(ix, jx, rows, distances)
    if dist != -1:
        return
    
    set_distance(val, ix, jx, rows, distances)

    if (ix > 0):
        north = get_north_wall(ix, jx, rows, ns_walls)
        if not north:
            handle_connection(val + 1, ns_walls, we_walls, distances, ix - 1, jx, rows, cols)
    if (jx > 0):
        west = get_west_wall(ix, jx, rows, we_walls)
        if not west:
            handle_connection(val + 1, ns_walls, we_walls, distances, ix, jx - 1, rows, cols)
    if (ix < rows - 1):
        south = get_south_wall(ix, jx, rows, ns_walls)
        if not south:
            handle_connection(val + 1, ns_walls, we_walls, distances, ix + 1, jx, rows, cols)
    if (jx < cols - 1):
        east = get_east_wall(ix, jx, rows, we_walls)
        if not east:
            handle_connection(val + 1, ns_walls, we_walls, distances, ix, jx + 1, rows, cols)
    
cdef int* dijkstra(int* ns_walls, int* we_walls, int rows, int cols):
    cdef int* distances = create_distances_vector(rows, cols)

    handle_connection(0, ns_walls, we_walls, distances, 0, 0, rows, cols)

    return distances


cpdef enum Algorithms:
    BINARY_SEARCH = 0
    SIDEWINDER = 1
    ALDUS_BRODER = 2


class Maze:
    def __init__(self, rows: int, columns: int):
        self.rows = rows
        self.columns = columns

    def generate_maze(self, Algorithms algorithm):
        cdef int* ns_walls = create_ns_walls(self.rows, self.columns)
        cdef int* we_walls = create_we_walls(self.rows, self.columns)

        if algorithm == Algorithms.BINARY_SEARCH:
            binary_search(ns_walls, we_walls, self.rows, self.columns)
        elif algorithm == Algorithms.SIDEWINDER:
            sidewinder(ns_walls, we_walls, self.rows, self.columns)
        elif algorithm == Algorithms.ALDUS_BRODER:
            aldus_broder(ns_walls, we_walls, self.rows, self.columns)

        cdef int*  distances = dijkstra(ns_walls, we_walls, self.rows, self.columns)

        data = {
            "rows": self.rows,
            "columns": self.columns,
            "maze": list()
        }
        for ix in range(self.rows):
            for jx in range(self.columns):
                north = get_north_wall(ix, jx, self.rows, ns_walls)
                south = get_south_wall(ix, jx, self.rows, ns_walls)
                west = get_west_wall(ix, jx, self.rows, we_walls)
                east = get_east_wall(ix, jx, self.rows, we_walls)
                dist = get_distance(ix, jx, self.rows, distances)

                walls = ""
                if north:
                    walls += "n"
                if east:
                    walls += "e"
                if south:
                    walls += "s"
                if  west:
                    walls += "w"

                data["maze"].append({
                    "row": ix,
                    "column": jx,
                    "walls": walls,
                    "distance": dist,
                })

        # free memory
        free(ns_walls)
        free(we_walls)
        free(distances)

        return data
