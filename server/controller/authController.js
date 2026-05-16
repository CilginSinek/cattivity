const User = require("../models/User");

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user)
      throw "No user found with this email, please register before login";
    const isMatch = await user.comparePassword(password);
    if (isMatch) {
      req.session.userId = user._id;
      res.status(201).json({ status: "success" });
    } else {
      throw "Wrong Password of Email";
    }
  } catch (error) {
    res.status(400).send(error);
  }
};

exports.callback = async (req, res) => {
  try {
    let profile = req.user;

    if (!profile) {
      const { code } = req.query;
      if (!code) {
        return res.status(400).json({ error: "Missing 42 code" });
      }

      const clientId = process.env.FORTYTWO_CLIENT_ID;
      const clientSecret = process.env.FORTYTWO_CLIENT_SECRET;
      const redirectUri = process.env.FORTYTWO_REDIRECT_URI;

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

      const tokenData = await tokenResponse.json();

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
    if (!user) {
      if (!profile.login) {
        return res.status(400).json({ error: "42 profile missing login" });
      }
      const name = profile.login;
      const password = `42-${profile.id || profile.login || Date.now() + Math.floor(Math.random() * 10000)}`;
      user = await User.create({ name, email, password });
    }

    req.session.userId = user._id;
    res.status(201).json({ status: "success", user });
  } catch (error) {
    res.status(400).send(error);
  }
};

exports.logout = async (req, res) => {
  try {
    req.session.destroy(() => {
      res.status(201).json({ status: "success" });
    });
  } catch (error) {
    res.status(401).json({ error });
  }
};
