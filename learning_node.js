const express = require('express');
const mysql = require('mysql');
const cors = require('cors')
const bodyParser = require('body-parser')

const app = express();
const port = 3000;

var connection = mysql.createConnection({
  host: "localhost",
  user: "hellojee",
  password: "Cris1234@",
  database: "mydb"
});


app.get('/login', (req, res)=>{

})