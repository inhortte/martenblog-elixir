'use strict';

export const server = () => {
  if(/localhost/.exec(document.URL)) {
    return 'http://localhost:8777';
  } else if(/galictis/.exec(document.URL)) {
    return 'http://galictis-vittata:8777';
  } else if(/tahr/.exec(document.URL)) {
    return 'http://tahr:8777';
  } else if(/pennanti/.exec(document.URL)) {
    return 'http://pennanti:8777';
  } else {
    return 'https://flavigula.net';
  }
};
