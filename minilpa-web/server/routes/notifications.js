const express = require('express');
const router = express.Router();
const db = require('../db');
const { v4: uuidv4 } = require('uuid');

// 获取所有通知
router.get('/', (req, res) => {
  try {
    const notifications = db.get('notifications').value() || [];
    res.json({ success: true, data: notifications });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 获取单个通知
router.get('/:id', (req, res) => {
  try {
    const notification = db.get('notifications').find({ id: req.params.id }).value();
    if (!notification) {
      return res.status(404).json({ success: false, error: 'Notification not found' });
    }
    res.json({ success: true, data: notification });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 创建新通知
router.post('/', (req, res) => {
  try {
    const { type, profileIccid, message } = req.body;
    
    const notifications = db.get('notifications').value();
    const newNotification = {
      id: uuidv4(),
      seqNumber: notifications.length + 1,
      type: type || 'install',
      profileIccid,
      message: message || '',
      notificationAddress: 'smdp.example.com',
      createdAt: new Date().toISOString(),
      processed: false
    };
    
    db.get('notifications').push(newNotification).write();
    
    res.json({ success: true, data: newNotification });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 处理通知
router.post('/:id/process', (req, res) => {
  try {
    const notification = db.get('notifications').find({ id: req.params.id }).value();
    if (!notification) {
      return res.status(404).json({ success: false, error: 'Notification not found' });
    }
    
    const updated = db.get('notifications')
      .find({ id: req.params.id })
      .assign({ processed: true, processedAt: new Date().toISOString() })
      .write();
    
    res.json({ success: true, data: updated });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 删除通知
router.delete('/:id', (req, res) => {
  try {
    const notification = db.get('notifications').find({ id: req.params.id }).value();
    if (!notification) {
      return res.status(404).json({ success: false, error: 'Notification not found' });
    }
    
    db.get('notifications').remove({ id: req.params.id }).write();
    
    res.json({ success: true, data: notification });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 批量删除通知
router.post('/batch/delete', (req, res) => {
  try {
    const { ids } = req.body;
    
    if (!Array.isArray(ids)) {
      return res.status(400).json({ success: false, error: 'ids must be an array' });
    }
    
    const deleted = [];
    ids.forEach(id => {
      const notification = db.get('notifications').find({ id }).value();
      if (notification) {
        deleted.push(notification);
        db.get('notifications').remove({ id }).write();
      }
    });
    
    res.json({ success: true, data: deleted });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 批量处理通知
router.post('/batch/process', (req, res) => {
  try {
    const { ids } = req.body;
    
    if (!Array.isArray(ids)) {
      return res.status(400).json({ success: false, error: 'ids must be an array' });
    }
    
    const processed = [];
    ids.forEach(id => {
      const notification = db.get('notifications').find({ id }).value();
      if (notification) {
        const updated = db.get('notifications')
          .find({ id })
          .assign({ processed: true, processedAt: new Date().toISOString() })
          .write();
        processed.push(updated);
      }
    });
    
    res.json({ success: true, data: processed });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
