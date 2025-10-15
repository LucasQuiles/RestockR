const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const User = require('../models/User');
const { authenticateToken } = require('../middleware/auth');

router.get('/skus', authenticateToken, async (req, res) => {
  const products = await Product.find({});
  res.json(products);
});

router.post('/subscribe/:sku', authenticateToken, async (req, res) => {
  const user = await User.findOne({ username: req.user.username });
  if (!user) return res.status(404).send({ error: 'User not found' });

  const sku = req.params.sku;
  if (!user.productSkus.includes(sku)) {
    user.productSkus.push(sku);
    await user.save();
  }

  res.json({ success: true });
});

router.post('/unsubscribe/:sku', authenticateToken, async (req, res) => {
  const user = await User.findOne({ username: req.user.username });
  if (!user) return res.status(404).send({ error: 'User not found' });
  const sku = req.params.sku;
  console.log(`${user.username}, unsubscribe from ${sku}`)

  user.productSkus = user.productSkus.filter(s => s !== sku);
  await user.save();

  res.json({ success: true });
});


// 🆕 Bulk subscribe
router.post('/subscribe-bulk', authenticateToken, async (req, res) => {
  const { skus } = req.body; // expects { skus: ["sku1", "sku2", ...] }
  const user = await User.findOne({ username: req.user.username });
  if (!user) return res.status(404).send({ error: 'User not found' });

  const merged = new Set([...user.productSkus, ...skus]);
  user.productSkus = Array.from(merged);
  await user.save();

  res.json({ success: true, productSkus: user.productSkus });
});

// 🆕 Bulk unsubscribe
router.post('/unsubscribe-bulk', authenticateToken, async (req, res) => {
  const { skus } = req.body; // expects { skus: ["sku1", "sku2", ...] }
  const user = await User.findOne({ username: req.user.username });
  if (!user) return res.status(404).send({ error: 'User not found' });

  user.productSkus = user.productSkus.filter(sku => !skus.includes(sku));
  await user.save();

  res.json({ success: true, productSkus: user.productSkus });
});

module.exports = router;