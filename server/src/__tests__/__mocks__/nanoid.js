// Mock for nanoid package
let counter = 0;

const nanoid = (size = 21) => {
  counter++;
  return "test-id-" + counter.toString().padStart(21, "0");
};

module.exports = nanoid;
module.exports.nanoid = nanoid;
