const loginDb = require('../databaseModules/applicantModel')
//const bcrypt = require('bcryptjs')
const express = require('express')
const { placeholderCheckUserExistsFromMobile,placeholderCreateUser } = require('./placeholderFunctions')
const router = express.Router()

router.post('/register', async (request, response) => {
    const { applicantName,mobileNumber,email, password ,gender,disability} = request.body;
    console.log(request.body);

    if (!applicantName|| !mobileNumber || !password || !email ||!gender ||!disability)
        return response.status(400).json({ msg: 'Missing details' })

    //query database to check if user with given mobile number already exists
    const userFound= placeholderCheckUserExistsFromMobile(mobileNumber,true)
    if (userFound) return response.status(400).json({ msg: 'User already exists' })

        // perform databse insert opertion to insert new user
    const createUserSuccess= placeholderCreateUser(applicantName,mobileNumber,email, password ,gender,disability, true)
    if(createUserSuccess==true)
    {
         return resp.status(200).json({ message: 'User created successfully' }) 
    }
    else
    {
        return response.status(400).json({ msg: 'Failed to create user in database' })
    }
    

    //return success message if user successfully created
})
module.exports =router