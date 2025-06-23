const express = require('express');
const router = express.Router();
const {getFilteredPendingApplications}=require('.../databaseModules/applicationModel')

module.exports = (connection) => {


// view an application with given id
app.get('/applicationAction/:applicationId/view', async (req, res) => {
  // Extract query parameters 
  let applicationId=req.params.applicationId
  try
  {
    const application = await viewApplicationById(connection, applicationId);
    return res.status(200).json(application);
    
  } 
  catch (err) {
    console.error('Error during application fetch:', err);
    return res.status(500).json({ message: 'Application with given id not found' });
  }
        

})

app.post('/applicationAction/:applicationId/:actionType', async (req, res) => {
  // Extract query parameters 
  let applicationId=req.params.applicationId
  let actionType=req.params.actionType
  
  try
  {
    const application = await setApplicationStatus(connection, applicationId,actionType);
    return res.status(200).json(application);
    
  } 
  catch (err) {
    console.error('Error during application status setting:', err);
    return res.status(500).json({ message: 'Database operation to update status of application failed' });
  }
        

});

return router;

}

