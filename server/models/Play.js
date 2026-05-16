const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const PlaySchema = new Schema({
    player: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    playedMap: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Map",
        required: true,
    },
    score: {
        type: Number,
        required: true,
    },
});

const Play = mongoose.model("Play", PlaySchema);
module.exports = Play;