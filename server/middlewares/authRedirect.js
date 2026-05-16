const User = require("../models/User");

module.exports = async (req, res, next) => {
  if(!req.session.userId)
    return res
      .status(401)
      .json({ status: "error", message: "You can't do that. Login!" });
  const user = await User.findById(req.session.userId);
  if (!req.session.userId || !user)
    return res
      .status(401)
      .json({ status: "error", message: "You can't do that. Login!" });
  next();
};