const express = require('express');
const mysql = require('mysql');
const cors = require('cors')
const bodyParser = require('body-parser')

const app = express();
const port = 3000;

app.use(cors()); // Allow requests from different origins (like your Flutter app)
app.use(bodyParser.json()); // This is CRUCIAL: it makes Express understand JSON data sent in the request body
app.use(bodyParser.urlencoded({ extended: true })); // For parsing URL-encoded data (good to include)

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
});


app.post('/login', (req, res)=>{
  const {mobile_number, name} = req.body;

  console.log(`Received login request for number: ${mobile_number}`);

  connection.query("SELECT * FROM userinfo WHERE mobile_number = ?", [mobile_number], (err, result)=>{
    if (err) {
      // If there's an error with the database query itself
      console.error('Error executing query:', err);
      return res.status(500).json({ // Send a 500 status for "Internal Server Error"
        status: 'bad',
        message: 'An error occurred while checking the database.'
      });
    }
    else if (result.length>0){
      console.log(`number '${mobile_number}' found in database.`);
      return res.status(200).json({ // Send a 200 status for "OK"
        status: 'good',
        message: 'Username exists!'
      });
    }else{
      console.log(`number '${mobile_number}' not found in database.`);
      return res.status(200).json({ // Still 200 OK, but with a 'bad' status for your app logic
        status: 'bad',
        message: 'Username not found!'
      });
    }
  })

})

app.listen(port, () => {
    console.log(`Backend server running on http://localhost:${port}`);
    console.log('Waiting for Flutter requests...');
});