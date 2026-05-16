const { login, logout, callback } = require("../controller/authController");

const authRedirect = require("../middlewares/authRedirect");
const redirectHome = require("../middlewares/redirectHome");

const router = require("express").Router();

router.route("/login").post(redirectHome, login);
router.route("/42/callback").get(redirectHome, callback);
router.route("/logout").get(authRedirect, logout);

module.exports = router;