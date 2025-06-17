const express = require('express');
const session = require('express-session')
const mysql = require('mysql');
const cors = require('cors')
const bodyParser = require('body-parser')

const app = express();
const port = 3000;

const applicantLoginRoute = require('./routes/applicantLoginRoute')
const applicantRegisterRoute = require('./routes/applicantRegisterRoute')
const updateUserApplicationRoute = require('./routes/updateUserApplication')


app.use(cors()); // Allow requests from different origins (like your Flutter app)
app.use(bodyParser.json()); // This is CRUCIAL: it makes Express understand JSON data sent in the request body
app.use(bodyParser.urlencoded({ extended: true })); // For parsing URL-encoded data (good to include)



//connecting with the database
var connection = mysql.createConnection({
  host: "localhost",
  user: "hellojee",
  password: "Cris1234@",
  database: "mydb"
});

// Try to connect to the MySQL database
connection.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL database:', err);
        // It's crucial to handle this error. Your server won't be able to talk to the DB.
        // You might want to exit the process or show a prominent error message.
        return;
    }
    console.log('Connected to MySQL database!');

    app.use('/', applicantLoginRoute(connection))
    app.use('/', applicantRegisterRoute(connection))
    app.use('/', updateUserApplicationRoute(connection))

    app.listen(port, "0.0.0.0", () => {
        console.log(`Backend server running on http://0.0.0.0:${port}`);
        console.log('Waiting for Flutter requests...');
    });
});