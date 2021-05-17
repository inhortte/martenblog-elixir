'use strict';

var vocab = [];
var serverUrl = () => {
  if(document.URL.match(/localhost/)) {
    return "http://localhost:8777";
  } else if(document.URL.match(/tahr/) ||
    document.URL.match(/pennanti/) ||
    document.URL.match(/galictis/) ||
    document.URL.match(/yak/)) {
    return "http://yak:8777";
  } else {
    return "https://flavigula.net"
  }
};

const refreshDictionary = _filter => {
  var div = document.querySelector("#vocabulary-list");
  div.innerHTML = '';
  var filter = _filter.trim();
  vocab.forEach(row => {
    var re = new RegExp(filter, "i");
    if(filter.length === 0 || re.exec(row.english) || re.exec(row.lakife)) {
      var supplication = document.createElement('div');
      supplication.innerHTML = `${row.lakife} - ${row.english}`;
      div.append(supplication);
    }
  });
};

document.querySelector("#filterBox").oninput = e => {
  var filter = e.target.value.trim();
  refreshDictionary(filter);
};

fetch(`${serverUrl()}/lakife-vocabulary`, {
    method: "get",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    }
}).then(res => res.json()).then(json => {
  if(json.rows && json.rows.length > 0) {
    json.rows.forEach(row => {
      vocab.push({
        english: row[2],
        lakife: row[1]
      });
    });
    refreshDictionary('');
  }
}).catch(err => {
  console.log(`Nothing is what it seems: ${err}`);
});
