// read a chunk
async function readChunk(offset, length) {
  let blob = file.slice(offset, length + offset);
  let text = await blob.text();
  return text;
}

// Read a dot file
async function readFile() {
  file_sz = file.size

  document.getElementById("progress").innerHTML = "0%";
  document.querySelector('.loading').classList.remove('hidden');

  graph = new Map();
  let curr_offset = 0;
  let last_percentage_update = 0;

  while (curr_offset / file_sz < 0.99) {
    let text = await readChunk(curr_offset, chunk_sz);
    curr_offset += readStates(text, curr_offset);

    if (curr_offset - last_percentage_update > _1MB * 50) {
      last_percentage_update = curr_offset;
      document.getElementById("progress").innerHTML = String(parseInt(curr_offset / file_sz * 100)) + "%"
    }
  }
}

// Parse nodes in a chunk, when loading the file
// returns amount read
function readStates(text, curr_offset) {
  let amountRead = 0;
  let lines = text.split("\n");
  console.log(1321)
  for (i = 0; i < lines.length - 1; i++) {
    let tmp = lines[i];
    let [id, type, value] = parseNode(tmp);
    if (type == 1) {
      graph.set(id, State(id, curr_offset + amountRead, tmp.length));
      if (curr_state == null) curr_state = State(id, curr_offset + amountRead, tmp.length);
    }
    if (type == 2 && !graph.get(id).childs.includes(value))
      graph.get(id).childs.push(value)
    amountRead += tmp.length + 1;
  }
  return amountRead;
}
//чтение файла происходит тут он забирает 20 трасс по айдишникам и  делает из них мапу
async function readTrace() {
  file_sz = file.size

  document.getElementById("progress").innerHTML = "0%";
  document.querySelector('.loading').classList.remove('hidden');

  graph = new Map();
  let curr_offset = 0;
  let last_percentage_update = 0;

  let text = await file.text();
  let lines = text.split("\n");

  //search start of error trace
  let i = 0;
  for (; i < lines.length; i++)
    if (lines[i] == "1: <Initial predicate>") break;
  if (i == lines.length) return;

  let state_id = Number(lines[i].substr(0, lines[i].indexOf(":")));
  let value = "";

  i++;
  for (; i < lines.length; i++) {
    if (!Number.isInteger(state_id)) break;
    if (lines[i].substr(0, 4) == "@!@!") {
      console.log(lines[i], 'POPOPOPO')
      graph.set(state_id, State(state_id, 0, 0))
      graph.get(state_id).value = value
      console.log(value.substring(0, value.indexOf('@!@!')),state_id, 'dafdsas')
      
      if (state_id > 1) graph.get(state_id - 1).childs.push(state_id);
      if (curr_state == null) curr_state = graph.get(state_id);
      i += 2;
      state_id = Number(lines[i].substr(0, lines[i].indexOf(":")));
      console.log(state_id, 'STATEID')
      value = "";
      continue;
    }
    // if(!lines[i+2].includes('@!@!@START')) {
      // console.log(value, lines[i+2], 'LINENENENE')
      // value += lines[i+2] + "\\n";
      value += lines[i] + "\\n";
    // }
  }
  let newStringForMap = graph.get(1).value
  // console.log(graph.get(1).value, '12212')
  // console.log(graph, 'fdsjjsdjjds')
}
