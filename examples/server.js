const R = require('ramda')
const express = require('express')
const bodyParser = require('body-parser')
const morgan = require('morgan')

const port = process.env.PORT || 4000
const host = process.env.HOST || '0.0.0.0'
const app = express()

app.use(morgan('dev'))
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())
app.get('/', (req, res) => {
  res.json('API Example')
})
app.get('/api/files', handlerGet('files', ['file']))
app.get('/api/users', handlerGet('users', ['login', 'firstname', 'lastname', 'mail']))

console.log(`Start on :${port}`)
app.listen(port, host)

// Pagination list.
function handlerGet (name, keywords) {
  const data = require(`./${name}.json`)

  return (req, res) => {
    const search = R.propOr('', 'search', req.query)
    const page = parseInt(R.propOr(0, 'page', req.query))
    const perPage = parseInt(R.propOr(100, 'per_page', req.query))
    const order = R.propOr('ASC', 'order', req.query)
    const orderBy = R.propOr('file', 'order_by', req.query)

    const filter = R.isEmpty(search)
      ? data
      : R.filter(x => R.any(R.identity,
        keywords.map(field => R.includes(search, R.prop(field, x)))), data)
    const sorted = R.sortBy(R.prop(orderBy), filter)
    const orderFn = order === 'ASC' ? R.identity : R.reverse
    const ordered = orderFn(sorted)
    const items = R.slice(page * perPage, (page + 1) * perPage, ordered)

    setTimeout(() => {
      res.json({
        total: R.length(ordered),
        items: items
      })
    }, 1500)
  }
}
