const loginDb = require('../databaseModules/applicant')
const bcrypt = require('bcryptjs')
const express = require('express')
const router = express.Router()

const { placeholderCheckUserExists ,placeHolderPasswordMatch} = require('./placeholderFunctions')


router.get('/hello', (req, res) => {
    res.send('hello from login page')
  });

//for login page
router.post('login', async(request,response) =>{
    const { mobileNum, password}=request.body
    if(!mobileNum || ! password)
        return response.status(400).json({message: 'Missing details'})

    //check if this user with this mobile number exists and account actually exists in database or not
    const userExists=placeholderCheckUserExists(mobileNum,true);
    if(!userExists)
    {
        return response.status(400).json({ message: 'No User registered with given mobile number' })   
    }
    // check if provided password matches the stored password from database
    const passwordMatch=placeHolderPasswordMatch(password,true);
    if(passwordMatch)
    {
        return response.status(200).json({ message: 'You have logged in successfully' }) 
    }
    else{
        return response.status(400).json({message : 'Invalid Password'})
    }

});

//for user details page that appears after successful login
//when the frontend redirects
router.post('viewApplicantDashboard', async(request,response)=>{

});

router.get('/logout',async(request,response)=>{
//will be implemented when sessions are maintained in some database
});


module.exports =router