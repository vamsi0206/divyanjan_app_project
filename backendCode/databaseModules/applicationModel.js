const getAllPendingApplications =(connection)=>{
    const query="SELECT * from Application WHERE status =submitted ";
    return new Promise((resolve, reject) => {
    connection.query(query, (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
}

const getFilteredPendingApplications = (connection,filters = {}) => {
    let query = "SELECT * FROM Application WHERE 1=1";
    const params = [];
    
    // Handle multiple status values
    if (filters.status) {
        if (Array.isArray(filters.status)) {
            const placeholders = filters.status.map(() => '?').join(',');
            query += ` AND status IN (${placeholders})`;
            params.push(...filters.status);
        } else {
            query += " AND status = ?";
            params.push(filters.status);
        }
    }
    
    // Handle other single value filters
    const singleValueFields = [
        'applicant_id', 'current_division_id', 'current_division_user_id',
        'current_cmi_id', 'current_cis_id', 'card_number'
    ];
    
    singleValueFields.forEach(field => {
        if (filters[field]) {
            query += ` AND ${field} = ?`;
            params.push(filters[field]);
        }
    });
    
    // Handle date ranges
    if (filters.submission_date_from) {
        query += " AND submission_date >= ?";
        params.push(filters.submission_date_from);
    }
    
    if (filters.submission_date_to) {
        query += " AND submission_date <= ?";
        params.push(filters.submission_date_to);
    }
    
    // Handle search in card_number (partial match)
    if (filters.card_number_search) {
        query += " AND card_number LIKE ?";
        params.push(`%${filters.card_number_search}%`);
    }
    
    // Add ordering and pagination
    query += " ORDER BY submission_date DESC";
    
    if (filters.limit) {
        query += " LIMIT ?";
        params.push(parseInt(filters.limit));
        
        if (filters.offset) {
            query += " OFFSET ?";
            params.push(parseInt(filters.offset));
        }
    }
    
    return new Promise((resolve, reject) => {
        connection.query(query, params, (err, results) => {
            if (err) {
                return reject(err);
            }
            resolve(results);
        });
    });
};

const viewApplicationById= (applicationId,connection)=>{
  const query="SELECT * from Application WHERE application_id= ? ";
    return new Promise((resolve, reject) => {
    connection.query(query,[applicationId], (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
}
//may need to modify database query processing based on datatype
const setApplicationStatus=(connection, applicationId, actionType) =>{
  const query=" UPDATE TABLE Application SET status=? WHERE application_id=";
    return new Promise((resolve, reject) => {
    connection.query(query,[ actionType, applicationId], (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
}
