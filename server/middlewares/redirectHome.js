const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (token) {
    try {
      jwt.verify(token, process.env.SECRET);
      return res.status(400).json({ status: "error", message: "Before Logout" });
    } catch {
    }
  }
  next();
};