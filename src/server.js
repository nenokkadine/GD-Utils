const dayjs = require('dayjs')
const Koa = require('koa')
const bodyParser = require('koa-bodyparser')
const router = require('./src/router')
var fs = require('fs');

const app = new Koa()
app.proxy = true

app.use(catcher)
app.use(bodyParser())
app.use(router.routes())
app.use(router.allowedMethods())

const G_SOCK = "/usr/gdutils.sock"

if (fs.existsSync(G_SOCK)) {
  fs.unlinkSync(G_SOCK)
}

app.listen(G_SOCK, '0.0.0.0')

async function catcher (ctx, next) {
  try {
    return await next()
  } catch (e) {
    console.error(e)
    ctx.status = 500
    ctx.body = e.message
  }
}