const express = require('express');
const router = express.Router();
const LPACExecutor = require('../lpac/executor');
const lpacService = require('../lpac/service');

// 检查 lpac 状态
router.get('/status', async (req, res) => {
  try {
    const executor = new LPACExecutor();
    const status = await executor.checkAvailability();
    
    res.json({
      success: true,
      data: {
        ...status,
        useMockData: process.env.USE_MOCK_DATA === 'true',
        apduDriver: process.env.APDU_DRIVER || 'auto',
        isAvailable: await lpacService.isLPACAvailable()
      }
    });
  } catch (error) {
    res.json({
      success: false,
      data: {
        available: false,
        error: error.message,
        useMockData: process.env.USE_MOCK_DATA === 'true'
      }
    });
  }
});

// 获取 lpac 版本
router.get('/version', async (req, res) => {
  try {
    const executor = new LPACExecutor();
    const result = await executor.execute(['version']);
    
    res.json({
      success: true,
      version: result.stdout
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.error || error.message
    });
  }
});

// 刷新所有数据（从 lpac 同步）
router.post('/sync', async (req, res) => {
  try {
    const profiles = await lpacService.getProfiles();
    const notifications = await lpacService.getNotifications();
    const chipInfo = await lpacService.getChipInfo();
    
    res.json({
      success: true,
      data: {
        profiles: profiles.length,
        notifications: notifications.length,
        chipInfo: chipInfo ? 'available' : 'unavailable'
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;

