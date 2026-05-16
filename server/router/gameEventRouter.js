const { savePlay, uploadMap, deleteMap } = require("../controller/gameEventController");

const authRedirect = require("../middlewares/authRedirect");

const router = require("express").Router();

router.route("/play").post(authRedirect, savePlay);
router.route("/upload").post(authRedirect, uploadMap);
router.route("/delete/:id").delete(authRedirect, deleteMap);

module.exports = router;