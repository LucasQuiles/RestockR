// routes/me.js
const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authenticateToken } = require('../middleware/auth');

router.get('/me', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ username: req.user.username })
      .populate('parentAccount', 'discordServerName');

    if (!user) {
      return res.status(404).send({ error: 'User not found' });
    }
    console.log("User parentAccount:", user.parentAccount);

    res.send({
      email: user.email || '',
      username: user.username,
      userType: user.userType,
      productSkus: user.productSkus || [],
      restockBell: user.restockBell ?? true,
      parentAccount: (user.parentAccount || []).map(p => ({
        id: String(p._id), // ensure it's always a string
        discordServerName: p.discordServerName || null
      })),
      minimumQty: user.minimumQty ?? 1,
      newSku: user.newSku || { pokemon: false, mtg: false, op: false, gundam: false, riftbound: false, yugioh: false },
      autoOpenPcQueue: user.autoOpenPcQueue ?? false,
      pcQueueDelaySeconds: user.pcQueueDelaySeconds ?? 0,
      reopenCooldown: user.reopenCooldown ?? 0,      
    });
  } catch (err) {
    console.error('❌ Failed to load user:', err);
    res.status(500).send({ error: 'Failed to fetch user data' });
  }
});

router.patch('/me', authenticateToken, async (req, res) => {
  const {
    restockBell,
    minimumQty,
    newSku,
    autoOpenPcQueue,
    pcQueueDelaySeconds,
    reopenCooldown
  } = req.body;

  try {
    const user = await User.findOne({ username: req.user.username });
    if (!user) {
      return res.status(404).send({ error: 'User not found' });
    }

    if (typeof restockBell === 'boolean') {
      user.restockBell = restockBell;
    }
    if (typeof minimumQty === 'number') {
      user.minimumQty = minimumQty;
    }
    if (newSku && typeof newSku === 'object') {
      user.newSku = {
        pokemon: !!newSku.pokemon,
        mtg: !!newSku.mtg,
        op: !!newSku.op,
        gundam: !!newSku.gundam,        // NEW
        riftbound: !!newSku.riftbound,  // NEW
        yugioh: !!newSku.yugioh         // NEW
      };
    }

    if (typeof autoOpenPcQueue === 'boolean') {
      user.autoOpenPcQueue = autoOpenPcQueue;
    }
    if (typeof pcQueueDelaySeconds === 'number') {
      user.pcQueueDelaySeconds = Math.max(0, Math.min(600, pcQueueDelaySeconds));
    }
    if (typeof reopenCooldown === 'number') {
      user.reopenCooldown = Math.max(0, Math.min(600, reopenCooldown));
    }
    await user.save();
    res.send({ success: true, updated: true });
  } catch (err) {
    console.error('❌ Failed to update user:', err);
    res.status(500).send({ error: 'Failed to update user data' });
  }
});

module.exports = router;