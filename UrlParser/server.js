const express = require('express');
const app = express();
const port = 3000;
const fs = require('fs');

app.get('/favicon.ico', (req, res) => {
    res.send('icon');
});

app.get('*main.js', (req, res) => {
    res.send(fs.readFileSync('./output/main.js').toString())
});

app.get('*', (req, res) => {
    res.send(fs.readFileSync('./output/index.html').toString())
})

app.listen(port);