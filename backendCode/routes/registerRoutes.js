const loginDb = require('../databaseModules/applicant')
const bcrypt = require('bcryptjs')
const express = require('express')
const router = express.Router()

router.post('/register', async (req, res) => {
    const { username,mobileNumber,email, password } = req.body;
    console.log(req.body);

    if (!mobileNumber || !password )
        return res.status(400).json({ msg: 'Missing details' })

    //query database to check if user with given mobile number already exists
    //const userFound= 
    if (userFound) return res.status(400).json({ msg: 'User already exists' })

    const newUser = new Users({ roll, password, role })
    // perform databse insert opertion to insert new user

    //return success message if user successfully created
})
module.exports =router