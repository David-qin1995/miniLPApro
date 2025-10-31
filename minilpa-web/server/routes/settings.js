const express = require('express');
const router = express.Router();
const db = require('../db');

// 获取设置
router.get('/', (req, res) => {
  try {
    const settings = db.get('settings').value() || {};
    res.json({ success: true, data: settings });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 更新设置
router.patch('/', (req, res) => {
  try {
    const currentSettings = db.get('settings').value();
    const newSettings = Object.assign({}, currentSettings, req.body);
    
    db.set('settings', newSettings).write();
    
    res.json({ success: true, data: newSettings });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 更新行为设置
router.patch('/behavior', (req, res) => {
  try {
    const currentBehavior = db.get('settings.behavior').value() || {};
    const newBehavior = Object.assign({}, currentBehavior, req.body);
    
    db.set('settings.behavior', newBehavior).write();
    
    res.json({ success: true, data: newBehavior });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 重置设置
router.post('/reset', (req, res) => {
  try {
    const defaultSettings = {
      language: 'zh-CN',
      theme: 'auto',
      daytimeTheme: 'FlatMacLightLaf',
      nighttimeTheme: 'FlatMacDarkLaf',
      autoNightMode: 'SYSTEM',
      emojiDesign: 'twemoji',
      behavior: {
        sendInstallNotification: false,
        removeInstallNotification: false,
        sendEnableNotification: false,
        removeEnableNotification: false,
        sendDisableNotification: false,
        removeDisableNotification: false,
        sendDeleteNotification: false,
        removeDeleteNotification: false
      }
    };
    
    db.set('settings', defaultSettings).write();
    
    res.json({ success: true, data: defaultSettings });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
