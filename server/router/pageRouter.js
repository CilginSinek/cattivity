const { root, leaderboard, maps, getmap, profile } = require("../controller/pageController");

const authRedirect = require("../middlewares/authRedirect");


const router = require("express").Router();

router.route("/").get(authRedirect, root);
router.route("/leaderboard").get(authRedirect, leaderboard);
router.route("/maps").get(authRedirect, maps);
router.route("/maps/:id").get(authRedirect, getmap);
router.route("/profile/:id").get(authRedirect, profile);

module.exports = router;