
const getUserByMobileNumber = (connection, mobileNumber) => {
  const query = "SELECT * FROM userinfo WHERE mobile_number = ?";
  return new Promise((resolve, reject) => {
    connection.query(query, [mobileNumber], (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
};

const createUser = (connection, mobileNumber, password) => {
  const query = "INSERT INTO userinfo (mobile_number, password) VALUES (?, ?)";
  return new Promise((resolve, reject) => {
    connection.query(query, [mobileNumber, password], (err, result) => {
      if (err) {
        return reject(err);
      }
      resolve(result);
    });
  });
};

module.exports = { getUserByMobileNumber, createUser };
