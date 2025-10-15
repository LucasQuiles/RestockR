const express = require('express');
const passport = require('passport');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const ParentAccount = require('../models/ParentAccount');
const resolveParentAccount = require('../utils/resolveParentAccount');

const bcrypt = require('bcryptjs');
const router = express.Router();

const DEFAULT_PARENT_ACCOUNT_ID = process.env.DEFAULT_PARENT_ACCOUNT_ID || "689cfdb2af4352a5d8e2b041";

/**
 * Helper to resolve a parent account from an inviteCode or ID
 * Returns the ObjectId if valid, otherwise null
 */ 

// === 🔐 Local Registration ===
router.post('/register', async (req, res) => {
  const { username, password, parentAccount } = req.body;
  if (!username || !password) {
    return res.status(400).send({ message: 'Missing username or password' });
  }

  const existing = await User.findOne({ username });
  if (existing) {
    return res.status(409).send({ message: 'User already exists' });
  }

  const passwordHash = await bcrypt.hash(password, 10);

  let parentAccountId = await resolveParentAccount(parentAccount);
  if (!parentAccountId) {
    parentAccountId = DEFAULT_PARENT_ACCOUNT_ID;
  }

  const newUser = new User({
    username,
    passwordHash,
    parentAccount: [parentAccountId],
  });

  try {
    await newUser.save();
    res.send({ message: 'User registered' });
  } catch (err) {
    console.error('❌ Registration error:', err);
    res.status(500).send({ message: 'Failed to register user' });
  }
});


// === 🔓 Local Login ===
router.post('/login', async (req, res) => {
  const { username, password, parentAccount } = req.body;
  const user = await User.findOne({ username });
  if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
    return res.status(401).send({ message: 'Invalid credentials' });
  }

  // If URL param has parentAccount and user has only default account, assign it
  if (parentAccount && (!user.parentAccount || user.parentAccount[0] === DEFAULT_PARENT_ACCOUNT_ID)) {
    const parentAccountId = await resolveParentAccount(parentAccount);
    if (parentAccountId) {
      user.parentAccount = [parentAccountId];
      await user.save();
    }
  }

  const token = jwt.sign(
    { id: user._id, username: user.username, userType: user.userType },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );

  res.send({ token });
});

// === 🟣 Discord OAuth ===

// Step 1: Redirect to Discord with state containing optional parentAccount
// === 🟣 Discord OAuth ===
router.get('/discord', (req, res, next) => {
  console.log('📥 Incoming GET /api/auth/discord request');
  console.log('➡ Query params:', req.query);

  const guildId = req.query.guildId;
  if (!guildId) {
    console.warn('⚠️ No guildId provided in query!');
  }

  const state = JSON.stringify({ guildId });

  console.log('🛠 Generated state param:', state);
  console.log('🚀 Redirecting to Discord OAuth...');

  passport.authenticate('discord', {
    session: false,
    state
  })(req, res, next);
});



// Step 2: Handle callback
router.get(
  '/discord/callback',
  passport.authenticate('discord', {
    session: false,
    failureRedirect: `${process.env.CLIENT_ORIGIN}/login?error=unauthorized`
  }),
  async (req, res) => {
    if (!req.user || req.user.userType === 0) {
      console.warn('❌ Unauthorized Discord login attempt');

      // Detect mobile and redirect to custom scheme
      const userAgent = req.get('user-agent') || '';
      const isMobile = /iPhone|iPad|Android/i.test(userAgent);

      if (isMobile) {
        return res.redirect(`restockr://callback?error=unauthorized`);
      }
      return res.redirect(`${process.env.CLIENT_ORIGIN}/login?error=unauthorized`);
    }

    let parentAccountParam = null;
    try {
      const parsedState = JSON.parse(req.query.state || '{}');
      parentAccountParam = parsedState.parentAccount || null;
    } catch (err) {
      console.warn('⚠️ Failed to parse Discord state param:', err);
    }

    // Assign parentAccount if provided and valid
    if (parentAccountParam && (!req.user.parentAccount || req.user.parentAccount[0] === DEFAULT_PARENT_ACCOUNT_ID)) {
      const parentAccountId = await resolveParentAccount(parentAccountParam);
      if (parentAccountId) {
        req.user.parentAccount = [parentAccountId];
        await req.user.save();
      }
    }

    const token = jwt.sign(
      { id: req.user._id, username: req.user.username, userType: req.user.userType },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Detect mobile and redirect to custom scheme
    const userAgent = req.get('user-agent') || '';
    const isMobile = /iPhone|iPad|Android/i.test(userAgent);

    console.log('📱 User-Agent:', userAgent);
    console.log('📱 Is Mobile:', isMobile);

    if (isMobile) {
      console.log('📱 Redirecting to mobile app: restockr://callback?token=...');
      return res.redirect(`restockr://callback?token=${token}`);
    }

    console.log('🌐 Redirecting to web app:', `${process.env.CLIENT_ORIGIN}/login?token=...`);
    res.redirect(`${process.env.CLIENT_ORIGIN}/login?token=${token}`);
  }
);

router.get('/parent-account/:inviteCode', async (req, res) => {
  const account = await ParentAccount.findOne({ inviteCode: req.params.inviteCode });
  if (!account) return res.status(404).send({ message: 'Not found' });
  res.send(account);
});


module.exports = router;