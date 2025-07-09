const express = require('express');
const router = express.Router();

module.exports = (connection) => {

    router.get('/:user_id/:division', async (req, res) => {
        const user_id = req.params.user_id;
        const division = req.params.division;
        
        try {
            // First, validate that the user is a level 1 employee
            const validateUserQuery = `
                SELECT user_id, name, current_level, division_id, validity_id 
                FROM Railwayuser 
                WHERE user_id = ? AND current_level = '1' AND validity_id = '1'
            `;
            
            connection.query(validateUserQuery, [user_id], (err, userResults) => {
                if (err) {
                    console.error('Error validating user:', err);
                    return res.status(500).json({ 
                        success: false, 
                        message: 'Database error while validating user' 
                    });
                }
                
                if (userResults.length === 0) {
                    return res.status(403).json({ 
                        success: false, 
                        message: 'Access denied. Only level 1 employees can access this route.' 
                    });
                }
                
                // Get level 1 users from different divisions (transfer_division)
                const transferDivisionQuery = `
                    SELECT user_id, name, mobile_number, email, current_level, division_id, statename, station_id
                    FROM Railwayuser 
                    WHERE current_level = '1' 
                    AND division_id != ? 
                    AND validity_id = '1'
                    ORDER BY division_id, name
                `;
                
                // Get level 2 users from the same division (next_level)
                const nextLevelQuery = `
                    SELECT user_id, name, mobile_number, email, current_level, division_id, statename, station_id
                    FROM Railwayuser 
                    WHERE current_level = '2' 
                    AND division_id = ? 
                    AND validity_id = '1'
                    ORDER BY name
                `;
                
                // Execute both queries
                connection.query(transferDivisionQuery, [division], (err, transferResults) => {
                    if (err) {
                        console.error('Error fetching transfer division users:', err);
                        return res.status(500).json({ 
                            success: false, 
                            message: 'Database error while fetching transfer division users' 
                        });
                    }
                    
                    connection.query(nextLevelQuery, [division], (err, nextLevelResults) => {
                        if (err) {
                            console.error('Error fetching next level users:', err);
                            return res.status(500).json({ 
                                success: false, 
                                message: 'Database error while fetching next level users' 
                            });
                        }
                        
                        return res.status(200).json({
                            success: true,
                            transfer_division: transferResults,
                            next_level: nextLevelResults,
                            user_info: {
                                user_id: userResults[0].user_id,
                                name: userResults[0].name,
                                division: userResults[0].division_id
                            }
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