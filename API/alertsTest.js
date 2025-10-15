// routes/alertsTest.js
const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

module.exports = (io) => {
  router.post('/test', authenticateToken, async (req, res) => {
    try {
      const userId = req.user._id || req.user.id;
      if (!userId) return res.status(400).send({ error: "userId missing from token" });

      const testData = {
        id: `test-${Date.now()}`,
        store: 'test_store',
        region: 'us',
        sku: 'TEST-SKU',
        product: 'Test Product',
        price: '$19.99',
        url: 'https://mavely.app.link/e/XIwBHpPu8Vb',
        image: 'https://via.placeholder.com/300x300.png?text=TEST',
        timestamp: new Date(),
        source: 'api-v2-test',
        reactions: { yes: 0, no: 0 },
        reactedUsers: [],
        productUrls: { default: 'https://mavely.app.link/e/XIwBHpPu8Vb' },
        testTimestamp: Date.now(),
      };

      // Emit ONLY to this user’s sockets
      io.to(userId).emit('restock', testData);

      res.status(200).send({ success: true, testData });
    } catch (err) {
      console.error("Test alert failed:", err);
      res.status(500).send({ error: "Internal server error" });
    }
  });

  return router;
};