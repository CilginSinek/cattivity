const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token)
    return res
      .status(401)
      .json({ status: "error", message: "You can't do that. Login!" });

  try {
    const decoded = jwt.verify(token, process.env.SECRET);
    req.userId = decoded.userId;
    next();
  } catch {
    return res
      .status(401)
      .json({ status: "error", message: "Invalid or expired token." });
  }
};