import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';


function Cell(props) {
  const id = props.column * props.boardRows + props.row;
  const standard_border = "2px solid #000";
  const background_color = `rgb(48, 75, ${255 * (1 - 7 * props.distance / props.totalCells)})`;
  const off_border = `2px solid `;
  
  var north_border = `2px solid #000`;
  var south_border = "2px solid #000";
  var east_border = "2px solid #000";
  var west_border = "2px solid #000";
  // var background_color = "#fff";

  var alternate_border = "2px solid " + background_color;
  
  if ( props.walls.indexOf("n") === -1 ) {
    north_border = alternate_border;
  }
  if ( props.walls.indexOf("s") === -1 ) {
    south_border = alternate_border;
  }
  if ( props.walls.indexOf("w") === -1 ) {
    west_border = alternate_border;
  }
  if ( props.walls.indexOf("e") === -1 ) {
    east_border = alternate_border;
  }

  return (
      <div className="cell" id={id} 
        style={{ 
          backgroundColor:background_color,
          borderLeft: west_border,
          borderRight: east_border,
          borderTop: north_border,
          borderBottom: south_border,
        }}>{props.distance}</div>
    );
}


class Board extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            error: null,
            idLoaded: false,
            rowCount: null,
            columnCount: null,
            totalCells: null,
            cells: null,
        }
    }

    componentDidMount() {
      fetch("http://localhost:8000/maze/binary_search?rows=20&columns=35", 
          {
              method: "GET",
              headers: {
                  'Accept': 'application/json',
                },
          })
        .then(res => res.json())
        .then(
          (result) => {
            this.setState({
              isLoaded: true,
              rowCount: result.rows,
              columnCount: result.columns,
              cells: result.maze,
              totalCells: result.rows * result.columns,
            });
          },
          // Note: it's important to handle errors here
          // instead of a catch() block so that we don't swallow
          // exceptions from actual bugs in components.
          (error) => {
            this.setState({
              isLoaded: true,
              error
            });
          }
        )
    }

    renderSquare(cell) {
        return (
            <Cell 
              distance={cell.distance} 
              walls={cell.walls} 
              row={cell.row} 
              column={cell.column} 
              boardRows={this.state.rowCount}
              totalCells={this.state.totalCells}
            />
        );
    }

    renderRow(row) {
        return row.map((cell) => this.renderSquare(cell));
    }

    render () {
      const { error, isLoaded, rowCount, columnCount, totalCells, cells } = this.state
      if (error) {
        return (<div>Error: {error.message}</div>);
      } else if (!isLoaded) {
        return (<div>Loading...</div>);
      }
      
      var rows = [];
      var row = [];

      for (let ix = 0; ix < rowCount; ix++) {
          var row = cells.slice(ix * columnCount, (ix + 1) * columnCount);
          rows.push(row);
      }

      return (
          <div>
              {rows?.map((row) => 
                  <div className="board-row">
                      {this.renderRow(row)}
                  </div>)
              }
          </div>
        );
    }
}


class Maze extends React.Component {
    render() {
      return (
          <div className="maze">
            <div className="maze-board">
              <Board/>
            </div>
            <div className="maze-info">
              <div>{/* status */}</div>
              <ol>{/* TODO */}</ol>
            </div>
          </div>
        );
    }
}


const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<Maze />);
