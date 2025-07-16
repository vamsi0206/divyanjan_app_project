const express = require('express');
const router = express.Router();

module.exports = (connection) => {

    router.get('/:user_id', async (req, res) => {
        const user_id = req.params.user_id;
        try {
            // Find the user's division_id from Railwayuser
            const getDivisionQuery = `SELECT division_id FROM Railwayuser WHERE user_id = ? AND validity_id = '1'`;
            connection.query(getDivisionQuery, [user_id], (err, userResults) => {
                if (err) {
                    console.error('Error fetching user division:', err);
                    return res.status(500).json({ 
                        success: false, 
                        message: 'Database error while fetching user division' 
                    });
                }
                if (!userResults || userResults.length === 0) {
                    return res.status(404).json({ 
                        success: false, 
                        message: 'User not found or not valid' 
                    });
                }
                const division_id = userResults[0].division_id;
                // Get all level-1 users from all divisions
                const level1Query = `
                    SELECT user_id, name, mobile_number, email, current_level, division_id, statename
                    FROM Railwayuser 
                    WHERE current_level = '1' 
                    AND validity_id = '1'
                    ORDER BY division_id, name
                `;
                // Get all level-2 users from the same division
                const level2Query = `
                    SELECT user_id, name, mobile_number, email, current_level, division_id, statename
                    FROM Railwayuser 
                    WHERE current_level = '2' 
                    AND division_id = ? 
                    AND validity_id = '1'
                    ORDER BY name
                `;
                connection.query(level1Query, (err, level1Results) => {
                    if (err) {
                        console.error('Error fetching level-1 users:', err);
                        return res.status(500).json({ 
                            success: false, 
                            message: 'Database error while fetching level-1 users' 
                        });
                    }
                    connection.query(level2Query, [division_id], (err, level2Results) => {
                        if (err) {
                            console.error('Error fetching level-2 users:', err);
                            return res.status(500).json({ 
                                success: false, 
                                message: 'Database error while fetching level-2 users' 
                            });
                        }
                        return res.status(200).json({
                            level1_users: level1Results,
                            level2_users: level2Results
                        });
                    });
                });
            });
        } catch (error) {
            console.error('Unexpected error in baseEmployeeOptions:', error);
            return res.status(500).json({ 
                success: false, 
                message: 'Unexpected error occurred' 
            });
        }
    });

    return router;
}; 