const express = require('express');
const session = require('express-session')
const mysql = require('mysql');
const cors = require('cors')
const bodyParser = require('body-parser')
const router = express.Router()

module.exports = (connection) => {

router.post('/login', (req, res)=>{
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

return router;

}

