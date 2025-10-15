const express = require('express');
const router = express.Router();
const Restock = require('../models/Restock');
const { verifyStaticToken } = require('../utils/verifyStaticToken');
const { authenticateToken } = require('../middleware/auth');

module.exports = (io) => {
  router.post('/', verifyStaticToken, async (req, res) => {
    const { store, sku, product = "Unknown", price, url, originalUrl, image, timestamp = new Date(), source = 'manual' } = req.body;

    const isoTimestamp = new Date(timestamp).toISOString();
    const id = `${sku}-${isoTimestamp}`;

    const alertData = {
      id,
      store,
      sku,
      product,
      price,
      url,
      originalUrl,
      image,
      timestamp,
      source,
      reactions: { yes: 0, no: 0 },
      reactedUsers: []
    };

    try {
      io.emit('restock', alertData);
      await Restock.create(alertData);
      res.send({ success: true, broadcasted: true });
    } catch (err) {
      console.error('❌ DB error:', err);
      res.status(500).send({ error: 'Failed to store alert' });
    }
  });

// alerts.js
// routes/alerts.js
router.get('/recent', authenticateToken, async (req, res) => {
  try {
    const user = req.user;
    const parentId = req.query.parentId || (
      user?.parentAccount?.length
        ? String(user.parentAccount[0]._id || user.parentAccount[0])
        : '0'
    );

    const grouped = await Restock.aggregate([
      { $sort: { timestamp: -1 } },
      { $group: { _id: "$store", alerts: { $push: "$$ROOT" } } },
      { $project: { alerts: { $slice: ["$alerts", 25] } } }
    ]);

    let flattened = grouped.flatMap(g => g.alerts);
    flattened.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));


    const skus = [...new Set(flattened.map(a => a.sku).filter(Boolean))];

    const products = await require('../models/Product').find({ SKU: { $in: skus } });

    const productMap = {};
    for (const p of products) {
      const urls = p.newProductUrls || {};
      productMap[p.SKU] = {
        urls: urls instanceof Map ? Object.fromEntries(urls) : urls,
        fallbackUrl: p.newProductUrl
      };
    }

    // Attach resolved URLs
    flattened = flattened.map(alert => {
      const prod = productMap[alert.sku];
      if (prod) {
        const resolvedUrl =
          prod.urls?.[parentId] ||
          prod.urls?.['0'] ||
          prod.fallbackUrl ||
          alert.url;


        return {
          ...alert,
          url: resolvedUrl, // primary resolved URL
          productUrls: {
            default: resolvedUrl,
            ...(prod.urls || {})
          }
        };
      }
      return alert;
    });

    res.json(flattened);
  } catch (err) {
    console.error('❌ Failed to load recent alerts:', err);
    res.status(500).send({ error: 'Failed to fetch alerts' });
  }
});

router.get('/history', authenticateToken, async (req, res) => {
  try {
    const { sku, productName, retailer, type, mode } = req.query; // ✅ added "mode"

    const query = {};
    if (sku) query.sku = sku;
    if (retailer && retailer !== 'All') {
      query.store = { $regex: `^${retailer}$`, $options: 'i' };
    }
    if (productName) {
      query.product = { $regex: productName, $options: 'i' };
    }
    if (type && type !== 'All') {
      query.type = type.toLowerCase();
    }

    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 60);

    const history = await Restock.aggregate([
      { $match: { ...query, timestamp: { $gte: thirtyDaysAgo } } },
      {
        $group: {
          _id: {
            date: { $dateToString: { format: "%Y-%m-%d", date: "$timestamp" } },
            hour: { $hour: "$timestamp" }
          },
          // ✅ Toggle between counting docs vs summing reactions
          count: mode === 'reactions'
            ? { $sum: "$reactions.yes" }
            : { $sum: 1 }
        }
      },
      { $sort: { "_id.date": -1, "_id.hour": 1 } }
    ]);

    res.json(history);
  } catch (err) {
    console.error('❌ Failed to fetch restock history:', err);
    res.status(500).send({ error: 'Failed to fetch restock history' });
  }
});


// Fetch detailed restocks for a specific hour
router.get('/history/details', authenticateToken, async (req, res) => {
  try {
    const { date, hour, startUtc, endUtc, sku, retailer, type, mode } = req.query;

    let startTime, endTime;
    if (startUtc && endUtc) {
      startTime = new Date(startUtc);
      endTime = new Date(endUtc);
    } else {
      if (!date || hour === undefined) {
        return res.status(400).send({ error: 'Missing date/hour or startUtc/endUtc' });
      }
      startTime = new Date(`${date}T${String(hour).padStart(2, '0')}:00:00Z`);
      endTime = new Date(startTime);
      endTime.setHours(endTime.getHours() + 1);
    }

    const query = { timestamp: { $gte: startTime, $lt: endTime } };
    if (sku) query.sku = sku;
    if (retailer && retailer !== 'All') {
      query.store = { $regex: `^${retailer}$`, $options: 'i' };
    }
    if (type && type !== 'All') {
      query.type = type.toLowerCase();
    }
    if (mode === 'reactions') {
      query["reactions.yes"] = { $gt: 0 }; // ✅ only items with yes reactions
    }

    const results = await Restock.find(query).sort({ timestamp: 1 });
    res.json(results);
  } catch (err) {
    console.error('❌ Failed to fetch restock details:', err);
    res.status(500).send({ error: 'Failed to fetch restock details' });
  }
});



  return router;
};