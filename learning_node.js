var mysql = require('mysql');

var connection = mysql.createConnection({
  host: "localhost",
  user: "hellojee",
  password: "Cris1234@"
});

connection.connect(function(err) {
  if (err) throw err;
  console.log("Connected!");
    connection.query("use mydb", function (err, result) {
    if (err) throw err;
    console.log("Database created");
  });
   connection.query("create table userInfo(name varchar(30), age int)", function (err, result) {
    if (err) throw err;
    console.log("Database created");
  });
});