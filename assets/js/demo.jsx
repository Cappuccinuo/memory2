'use strict'

import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function run_demo(root, channel) {
  ReactDOM.render(<MemoryGame channel={channel}/>, root);
}

class Square extends React.Component {
  render() {
    const toggleVisible = this.props.isTurned ? 'visible' : this.props.isMatch ? 'visible' : 'hidden';
    const changeColor = this.props.isMatch ? '#C4C9CF' : 'white';
    let style = {
      visibility: toggleVisible,
    };
    let wholeStyle = {
      background: changeColor,
    }
    return (
      <button className="square" style={wholeStyle} onClick={this.props.onClick}>
        <div style={style}>
          <div>{this.props.value}</div>
        </div>
      </button>
    );
  }
}

class MemoryGame extends React.Component {
  constructor(props) {
    super(props)
    this.resetTime = null
    this.state = {
      show: [],       // The selected indices of cards
      completed: [],  // The paired indices of cards
      skel:[],        // Cards value based on indices,
                      // "?" If not selected or pairs, otherwise show the value
      step: 0,        // The click times so far
    }
    this.channel = props.channel;
    this.channel.join()
                .receive("ok", this.gotView.bind(this))
                .receive("error", resp => {console.log("Unable to join", resp)});
  }

  gotView(view) {
    console.log("New view", view);
    this.setState(view.game);
  }

  sendGuess(i) {
    if (!this.state.completed.includes(i) && !this.state.show.includes(i)) {
      this.channel.push("guess", {"card": i})
                  .receive("ok", this.gotView.bind(this));
      if (this.resetTime) {
        return;
      }
      if (this.state.show.length >= 1) {
        this.resetTime = setTimeout(() => {
          this.sendReset();
        }, 500);
      }
    }
  }

  sendReset() {
    this.channel.push("reset", {"clear": true})
                .receive("ok", this.gotView.bind(this));
    this.resetTime = null;
  }

  sendRestart() {
    this.channel.push("restart", {"renew": true})
                .receive("ok", this.gotView.bind(this));
  }

  render() {
    return (
    <div>
      <div className="restart">
        <button className="button" onClick={() => this.sendRestart()}>Restart</button>
      </div>
      <div className="score">
        <span>Score: {200 - this.state.step}</span>
      </div>
      <div className="game">
        {this.state.skel.map((card, i) => {
          return <Square
            value={card}
            onClick={() => this.sendGuess(i)}
            isTurned={this.state.show.includes(i)}
            isMatch={this.state.completed.includes(i)}
            key={i}/>;
        }, this)}
      </div>
    </div>
    );
  }
}
