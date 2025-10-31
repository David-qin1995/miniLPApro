const express = require('express');
const router = express.Router();
const lpacService = require('../lpac/service');
const { v4: uuidv4 } = require('uuid');

// 获取所有 profiles
router.get('/', async (req, res) => {
  try {
    const profiles = await lpacService.getProfiles();
    res.json({ success: true, data: profiles });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 获取单个 profile
router.get('/:id', async (req, res) => {
  try {
    const profiles = await lpacService.getProfiles();
    const profile = profiles.find(p => p.id === req.params.id || p.iccid === req.params.id);
    
    if (!profile) {
      return res.status(404).json({ success: false, error: 'Profile not found' });
    }
    res.json({ success: true, data: profile });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 下载/添加新 profile
router.post('/', async (req, res) => {
  try {
    const { activationCode, confirmationCode, nickname } = req.body;
    
    if (!activationCode) {
      return res.status(400).json({ 
        success: false, 
        error: 'Activation code is required' 
      });
    }
    
    const profile = await lpacService.downloadProfile(
      activationCode,
      confirmationCode || '',
      nickname || ''
    );
    
    res.json({ success: true, data: profile });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 启用 profile
router.post('/:id/enable', async (req, res) => {
  try {
    const profile = await lpacService.enableProfile(req.params.id);
    res.json({ success: true, data: profile });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 禁用 profile
router.post('/:id/disable', async (req, res) => {
  try {
    const profile = await lpacService.disableProfile(req.params.id);
    res.json({ success: true, data: profile });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 更新 profile 昵称
router.patch('/:id', async (req, res) => {
  try {
    if (!req.body.nickname) {
      return res.status(400).json({ 
        success: false, 
        error: 'Nickname is required' 
      });
    }
    
    const profile = await lpacService.updateProfileNickname(
      req.params.id,
      req.body.nickname
    );
    
    res.json({ success: true, data: profile });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 删除 profile
router.delete('/:id', async (req, res) => {
  try {
    const profile = await lpacService.deleteProfile(req.params.id);
    res.json({ success: true, data: profile });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
