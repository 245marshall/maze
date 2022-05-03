import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';


// const numbers = [1, 2, 3, 4, 5];


function Cell(props) {
    return (
        <button className="cell">
            {props.value}
        </button>
    );
}


class Board extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            rows: props.rows,
            columns: props.columns,
            items: props.items,
            ready_rows: [],
        }
    }

    renderSquare(cell) {
        return (
            <Cell value={cell.distance}>{cell.distance}</Cell>
        );
    }

    renderRow(row) {
        return row.map((cell) => this.renderSquare(cell));
    }

    render () {
        const max_row = this.state.rows;
        var rows = [];
        var row = [];

        for (let ix = 0; ix < max_row; ix++) {
            var row = this.state.items.slice(ix * max_row, (ix + 1) * max_row);
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

    constructor(props) {
        super(props);
        this.state = {
            error: null,
            isLoaded: false,
            rows: null,
            columns: null,
            items: [],
        }
    }

    componentDidMount() {
        fetch("http://localhost:8000/maze/aldus_broder?rows=20&columns=20", 
            {
                method: "GET", 
                // mode: "no-cors",
                headers: {
                    'Accept': 'application/json',
                  },
            })
          .then(res => res.json())
          .then(
            (result) => {
              this.setState({
                isLoaded: true,
                rows: result.rows,
                columns: result.columns,
                items: result.maze,
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

    render() {
      const { error, isLoaded, rows, columns, items } = this.state
      if (error) {
        return (<div>Error: {error.message}</div>);
      } else if (!isLoaded) {
        return (<div>Loading...</div>);
      } else {
        return (
            <div className="maze">
              <div className="maze-board">
                <Board rows={rows} columns={columns} items={items}/>
              </div>
              <div className="maze-info">
                <div>{/* status */}</div>
                <ol>{/* TODO */}</ol>
              </div>
            </div>
          );
      }
    }
}


const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<Maze />);
