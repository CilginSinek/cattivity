const User = require("../models/User");
const jwt = require("jsonwebtoken");

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user)
      throw "No user found with this email, please register before login";
    const isMatch = await user.comparePassword(password);
    if (isMatch) {
      const token = jwt.sign(
        { userId: user._id },
        process.env.SECRET,
        { expiresIn: "7d" }
      );
      res.status(201).json({ status: "success", token });
    } else {
      throw "Wrong Password or Email";
    }
  } catch (error) {
    res.status(400).send(error);
  }
};

exports.callback = async (req, res) => {
  try {
    let profile = req.user;
    let tokenData;
    if (!profile) {
      const { code } = req.query;
      if (!code) {
        return res.status(400).json({ error: "Missing 42 code" });
      }

      const clientId = process.env.FORTYTWO_CLIENT_ID;
      const clientSecret = process.env.FORTYTWO_CLIENT_SECRET;
      const redirectUri = process.env.FORTYTWO_CALLBACK_URL;

      if (!clientId || !clientSecret || !redirectUri) {
        return res.status(500).json({ error: "42 OAuth env vars missing" });
      }

      const tokenResponse = await fetch("https://api.intra.42.fr/oauth/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
          grant_type: "authorization_code",
          client_id: clientId,
          client_secret: clientSecret,
          redirect_uri: redirectUri,
          code: code.toString(),
        }),
      });

      if (!tokenResponse.ok) {
        return res.status(401).json({ error: "Invalid 42 code" });
      }

      tokenData = await tokenResponse.json();

      const profileResponse = await fetch("https://api.intra.42.fr/v2/me", {
        headers: { Authorization: `Bearer ${tokenData.access_token}` },
      });

      if (!profileResponse.ok) {
        return res.status(401).json({ error: "Failed to fetch 42 profile" });
      }

      profile = await profileResponse.json();
    }

    const email = profile.email;
    if (!email) {
      return res.status(400).json({ error: "42 profile missing email" });
    }
    let user = await User.findOne({ email });
    if (user == null) {
      if (!profile.login) {
        return res.status(400).json({ error: "42 profile missing login" });
      }
      let coalition = "none";
      let coalitionresponse;
      if (profile.cursus_users && profile.cursus_users[0]?.has_coalition) {
        coalitionresponse = await fetch(
          `https://api.intra.42.fr/v2/users/${profile.id}/coalitions`,
          {
            headers: { Authorization: `Bearer ${tokenData.access_token}` },
          },
        );
        if (coalitionresponse.ok) {
          const coalitionData = await coalitionresponse.json();
          if (Array.isArray(coalitionData) && coalitionData.length > 0) {
            coalition = coalitionData[0].name;
          } else {
            coalition = coalitionData.name;
          }
        }
      }
      console.log("test")
      const name = profile.login;
      const password = `42-${profile.id || profile.login || Date.now() + Math.floor(Math.random() * 10000)}`;
      user = await User.create({ name, email, password });
    }

    const token = jwt.sign(
      { userId: user._id },
      process.env.SECRET,
      { expiresIn: "7d" }
    );
    res.cookie("GameToken", token, {
      httpOnly: false,
      secure: ((process.env.LOCALHOST).includes("localhost") || (process.env.LOCALHOST).includes("127.0.0.1")) ? false : true,
      sameSite: "Lax",
    });
    res.redirect(process.env.GAMEURL)
  } catch (error) {
    res.status(400).json({status:"error", message:error});
  }
};

exports.logout = async (req, res) => {
  res.status(200).json({ status: "success", message: "Logged out. Please delete your token on client side." });
};
