const express = require('express');
const session = require('express-session')
const mysql = require('mysql2');
const cors = require('cors')
const bodyParser = require('body-parser')
const dotenv=require('dotenv')

//SPECIFY DATABASE CONFIGURATION PARAMETERS BASED ON DEVICE BY IMPORTING CONFIGURATION FILE
dotenv.config({path:'configRaheel.env'}); //For raheel's device
//dotenv.config({path:'./configRis.env'}); // For Rishabh's device

const app = express();
const port = 3000;

// Middleware setup - MUST come before route setup
app.use(cors()); // Allow requests from different origins
app.use(express.json()); // For parsing JSON payloads
app.use(bodyParser.json()); // For parsing JSON payloads (redundant but keeping for safety)
app.use(bodyParser.urlencoded({ extended: true })); // For parsing URL-encoded bodies

// Import routes
const applicantLoginRoute = require('./routes/applicantLoginRoute')
const applicantRegisterRoute = require('./routes/applicantRegisterRoute')
const updateUserApplicationRoute = require('./routes/updateUserApplication')
const applicantDashboardRoute = require('./routes/applicantDashboard')
const employeeDashboardRoute = require('./routes/employeeDashboard')
const applicationActionRoute = require('./routes/applicationAction')
const reportRoute = require('./routes/report')
const railwayUserLoginRoute = require('./routes/railwayUserLoginRoute')
const reportSummary = require('./routes/reportSummary')
const baseEmployeeOptionsRoute = require('./routes/baseEmployeeOptions')
const fetchingCardRoute = require('./routes/fetchingCard');
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
        process.exit(1); // Exit if we can't connect to database
    }
    console.log('Connected to MySQL database!');

    // Setup routes
    app.use('/login', applicantLoginRoute(connection));
    app.use('/railwayUserLogin', railwayUserLoginRoute(connection));
    app.use('/register', applicantRegisterRoute(connection));
    app.use('/updateUserApplication', updateUserApplicationRoute(connection));
    app.use('/applicantDashboard', applicantDashboardRoute(connection));
    app.use('/employeePage', employeeDashboardRoute(connection));
    app.use('/applicationAction', applicationActionRoute(connection));
    app.use('/queryApplications', reportRoute(connection));
    app.use('/reportSummary',reportSummary(connection));
    app.use('/baseEmployeeOptions', baseEmployeeOptionsRoute(connection));
    app.use('/fetchingCard', fetchingCardRoute(connection));

    // Error handling middleware
    app.use((err, req, res, next) => {
        console.error(err.stack);
        res.status(500).json({ message: 'Something broke!' });
    });

    // 404 handler
    app.use((req, res) => {
        res.status(404).json({ message: 'Route not found' });
    });
let url="0.0.0.0";
    app.listen(port, url, () => {
        console.log(`Backend server running on ${url}:${port}`);
        console.log('Waiting for Flutter requests...');
    });
});