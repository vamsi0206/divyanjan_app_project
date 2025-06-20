const express = require('express');
const session = require('express-session')
const mysql = require('mysql2');
const cors = require('cors')
const bodyParser = require('body-parser')

const app = express();
const port = 3000;

const applicantLoginRoute = require('./routes/applicantLoginRoute')
const applicantRegisterRoute = require('./routes/applicantRegisterRoute')
const updateUserApplicationRoute = require('./routes/updateUserApplication')
const dotenv=require('dotenv')

app.use(cors()); // Allow requests from different origins (like your Flutter app)
app.use(bodyParser.json()); // This is CRUCIAL: it makes Express understand JSON data sent in the request body
app.use(bodyParser.urlencoded({ extended: true })); // For parsing URL-encoded data (good to include)


//SPECIFY DATABASE CONFIGURATION PARAMETERS BASED ON DEVICE BY IMPORTING CONFIGURATION FILE
dotenv.config({path:'./configRaheel.env'}); //For raheel's device
//dotenv.config({path:'./configRis.env'}); // For Rishabh's device

// >>>>> ADD THESE DEBUGGING CONSOLE LOGS HERE <<<<<
console.log('--- Environment Variables Loaded ---');
console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_DATABASE:', process.env.DB_DATABASE);
// console.log('DB_PASSWORD:', process.env.DB_PASSWORD); // Temporarily enable for debugging, but be careful not to commit this!
console.log('------------------------------------');
// >>>>> END OF DEBUGGING CONSOLE LOGS <<<<<


//connecting with the database
var connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE
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