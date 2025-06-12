const express= require('express')
const session = require('express-session')
const bodyParser =require('body-parser')
const mysql= require('mysql2')

//modules for route actions
const applicantLoginRoutes= require('./routes/applicantLoginRoutes')
const registerRoutes= require('./routes/registerRoutes')

const app = express()

//add and import parameters related to sql database connection
const port= process.env.port || 3000

//dotenv.config
//const db = mysql.createConnection(...);
//db.connect(() =>{}); //put parameters picked from config env file

//Middlewares
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended:true}))

//sessions handler (will implement upon successful database integration)


//Routers
app.use('/applicantLogin',applicantLoginRoutes)
app.use('/registerRoutes',applicantRegisterRoutes)

//start server
app.listen(port, () => {
    console.log(`Server listening on port ${port}`)
})

module.exports = app