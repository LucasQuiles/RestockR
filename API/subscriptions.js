const express = require("express");
const router = express.Router();
const User = require("../models/User");

// ✅ Subscribe to a SKU
router.post("/subscribe/:sku", async (req, res) => {
  if (!req.isAuthenticated()) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  const { sku } = req.params;
  const userId = req.user._id;

  try {
    await User.findByIdAndUpdate(
      userId,
      { $addToSet: { productSkus: sku } }, // prevents duplicates
      { new: true }
    );

    const updatedUser = await User.findById(userId);
    res.json({ success: true, productSkus: updatedUser.productSkus });
  } catch (err) {
    console.error("Subscribe error:", err);
    res.status(500).json({ error: "Internal error" });
  }
});

// ✅ Unsubscribe from a SKU
router.post("/unsubscribe/:sku", async (req, res) => {
  if (!req.isAuthenticated()) {
    return res.status(401).json({ error: "Unauthorized" });
  }
  console.log("Unsubscribe")
  const { sku } = req.params;
  const userId = req.user._id;

  try {
    await User.findByIdAndUpdate(
      userId,
      { $pull: { productSkus: sku } }, // safely removes SKU if present
      { new: true }
    );

    const updatedUser = await User.findById(userId);
    res.json({ success: true, productSkus: updatedUser.productSkus });
  } catch (err) {
    console.error("Unsubscribe error:", err);
    res.status(500).json({ error: "Internal error" });
  }
});

module.exports = router;