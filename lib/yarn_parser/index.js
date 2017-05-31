const fs = require('fs')
const parser = require('./node_modules/yarn/lib/lockfile/parse.js')

let filename = process.argv[2]
let file = fs.readFileSync(filename, 'utf8')
let json = parser.default(file)

console.log(JSON.stringify(json))
