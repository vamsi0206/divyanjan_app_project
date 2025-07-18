const express = require('express');
const { getUserByMobileNumber } = require('../databaseModules/applicantModel');
const router = express.Router();
const { getApplicationsByEmployeeId, getRailwayUserById } = require('../databaseModules/applicationModel');

module.exports = (connection) => {

router.post('/:appid', async (req, res) => {
    var appid = req.params.appid;
    console.log(appid);
    //change status of application to accept or reject
    // TODO: Implement application status change logic
    return res.status(200).json({ message: 'Application action endpoint - implementation pending' });
});

router.get('/:employeeLevel/:employeeId', async (req, res) => {
    const current_level = req.params.employeeLevel;
    const user_id = req.params.employeeId;
    
    // Validate employee level
    if (!['1', '2', '3'].includes(current_level)) {
        return res.status(400).json({ message: 'Invalid employee level. Must be 1, 2, or 3.' });
    }
    
    try {
        // Fetch employee info to verify employee exists
        const employee = await getRailwayUserById(connection, user_id);
        if (!employee) {
            return res.status(404).json({ success: false, message: 'Employee not found' });
        }
        
        // Get applications assigned to this employee based on current_processing_employee
        const applications = await getApplicationsByEmployeeId(connection, user_id);
        
        if (applications && applications.length > 0) {
            return res.status(200).json({
                success: true,
                data: applications,
                count: applications.length,
                employeeLevel: current_level,
                processableLevel: current_level === '1' ? 'applicant' : 
                                 current_level === '2' ? '1' : '2'
            });
        }
        
        return res.status(200).json({
            success: true,
            data: [],
            count: 0,
            message: 'No applications assigned to you',
            employeeLevel: current_level,
            processableLevel: current_level === '1' ? 'applicant' : 
                             current_level === '2' ? '1' : '2'
        });

    } catch (err) {
        console.log('Error fetching applications', err);
        return res.status(500).json({ 
            success: false,
            message: 'Error occurred while fetching applications' 
        });
    }
});

return router;

}

