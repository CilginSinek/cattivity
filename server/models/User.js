const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const Schema = mongoose.Schema;

const UserSchema = new Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },
  email: {
    type: String,
    unique: true,
    require: true,
    trim: true,
  },
  password: {
    type: String,
    required: true,
  },
  coalition: {
    type: String,
    default: "none",
  },
  plays: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Play",
    },
  ],
  role: {
    type: String,
    default: "User",
    enum: ["User", "Admin"],
  },
});

UserSchema.pre("save", async function () {
  if (this.isModified("password")) {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
  }
});

UserSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model("User", UserSchema);


module.exports = User;