'use strict';

import R from 'ramda';
import { maxPageNumbersToDisplay } from '../config';

export const analPageNumbers = pagesArr => {
  let selected = 0;
  for (let idx in pagesArr) {
    if(pagesArr[idx].selected) {
      selected = parseInt(idx);
      break;
    }
  }
  if(pagesArr.length <= maxPageNumbersToDisplay) {
    return pagesArr;
  }
  let start, final;
  let startPad = 0, finalPad = 0;
  let median = Math.floor(maxPageNumbersToDisplay / 2);
  if(parseInt(selected - median) < 0) {
    start = parseInt(0);
    finalPad = parseInt(median - selected);
  } else {
    start = parseInt(selected - median);
  }
  if(parseInt(selected + median) >= pagesArr.length) {
    final = parseInt(pagesArr.length - 1);
    startPad = parseInt(selected + median - pagesArr.length - 1);
  } else {
    final = parseInt(selected + median);
  }

  return pagesArr.slice(start - startPad, final + finalPad + 1);
};

export const currentPage = (pagesArr) => {
  // console.log(`currentPage - pagesArr: ${JSON.stringify(pagesArr)}`);
  let page = R.find(R.propEq('selected', true))(pagesArr);
  return (page && page.pNum) || 1;
};


export const getFormattedDate = (timestamp, dateOpts) => {
  let _date = new Date(timestamp);
  let dateLink = `/blog/${_date.getFullYear()}/${_date.getMonth() + 1}/${_date.getDate()}`;
  let dateString = new Intl.DateTimeFormat('en-GB', dateOpts).format(_date);
  return {
    dateLink: dateLink,
    dateString: dateString,
    y: _date.getFullYear(),
    m: _date.getMonth() + 1,
    d: _date.getDate()
  };
};

const dayOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

export const poemDate = fecha => {
  const re = /(\d+)[-\/](\d+)[-\/](\d+)/;
  let m = re.exec(fecha);
  if(m) {
    let bastard = new Date(m[1], m[2] - 1, m[3]);
    // return `${bastard.getUTCFullYear()}-${bastard.getUTCMonth() + 1}-${bastard.getUTCDate() + 1} (${dayOfWeek[bastard.getDay()]})`;
    return `${fecha} (${dayOfWeek[bastard.getDay()]})`;    
  } else {
    return null;
  }
};
