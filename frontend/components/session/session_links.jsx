import React from 'react';
import { Link } from 'react-router-dom';

export default class SessionLinks extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="session-links">
        <Link to='/login'>Login</Link>
        <Link to='/signup'>Sign Up</Link>
      </div>
    );
  }
}