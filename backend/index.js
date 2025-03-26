const express = require('express')
const { v4: uuidv4 } = require('uuid');
const { CORS_ORIGIN } = require('./config')
console.log(require('./config'))
console.log(CORS_ORIGIN)

const ID = uuidv4()
const PORT = 8080

const app = express()
app.use(express.json())

app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', 'http://frontend-alb-1322983034.us-west-1.elb.amazonaws.com');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', '*')
    next();
})
app.get(/.*/, (req, res) => {
    console.log(`${new Date().toISOString()} GET`)
    res.json({id: ID})
})

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Backend started on ${PORT}`);
});

