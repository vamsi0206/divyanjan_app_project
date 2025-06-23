const express = require('express');
const { getUserByMobileNumber } = require('../databaseModules/applicantModel');
const router = express.Router();
const {getAllPendingApplications}=require('.../databaseModules/applicationModel')

module.exports = (connection) => {

router.post('/employeePage/submit/:appid', async (req, res) => {
    var appid=req.params.appid;
    console.log(id);
    //change status of application to accept or reject

});

router.get('/employeePage/',async (req,res)=>{
    //SHOULD ALL PAGES AND ACTIONS HAVE A CONSISTENT UNIFORM FORMAT OF JSON RESPONSE ??
    //IF YES WE NEED TO ALSO ACCOMODATE RESULT OF DATABASE QUERIES APPROPRIATELY
    //get all applications from applications table that have status as submitted
    try {
        const allApplications=await getAllPendingApplications(connection);
        if(allApplications)
            return res.status(200).json(allApplications)
        return res.status(404).json({message:'Empty response' })

    }
    catch(err)
    {
        console.log('Error fetching applications',err);
        return res.status(500).json({message:'Error occured while fetching messages'})
    }

    
    

})

return router;

}

