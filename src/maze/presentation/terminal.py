import sys


def present(data, fhandle=sys.stdout):
    rows = data["rows"]
    columns = data["columns"]
    maze = data["maze"]

    center_tmplt = "%3d"
    board_string = ""
    m_ix = 0
    for ix in range(rows):
        upper = ""
        middle = ""
        lower = ""
        for jx in range(columns):
            cell = maze[m_ix]
            m_ix += 1
            center = center_tmplt % cell["distance"]

            if "n" in cell["walls"]:
                upper = upper + "+---"
            else:
                upper = upper + "+   "
            if "w" in cell["walls"]:
                middle = middle + "|" + center
            else:
                middle = middle + " " + center
            if jx == columns - 1 and "e" in cell["walls"]:
                middle = middle + "|"
            if ix == rows - 1 and "s" in cell["walls"]:
                lower = lower + "+---"
            else:
                lower = lower + "    "
            if jx == columns - 1:
                upper += "+"
                lower += "+"

        board_string = board_string + "\n" + upper
        board_string = board_string + "\n" + middle
        if ix == rows - 1:
            board_string = board_string + "\n" + lower    
    board_string += "\n"
    
    fhandle.write(board_string)
    fhandle.flush()
