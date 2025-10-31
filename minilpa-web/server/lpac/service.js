/**
 * LPAC Service - 提供高级 lpac 功能接口
 */

const LPACExecutor = require('./executor');
const db = require('../db');

class LPACService {
  constructor() {
    this.executor = new LPACExecutor();
    this.useMockData = process.env.USE_MOCK_DATA === 'true';
  }

  /**
   * 检查是否使用真实 lpac
   */
  async isLPACAvailable() {
    if (this.useMockData) {
      return false;
    }
    const status = await this.executor.checkAvailability();
    return status.available;
  }

  /**
   * 获取 Profile 列表（真实或模拟）
   */
  async getProfiles() {
    if (this.useMockData || !(await this.isLPACAvailable())) {
      // 使用数据库中的模拟数据
      return db.get('profiles').value() || [];
    }

    try {
      // 使用真实 lpac
      const profiles = await this.executor.listProfiles();
      
      // 同步到数据库
      db.set('profiles', profiles).write();
      
      return profiles;
    } catch (error) {
      console.error('[LPAC Service] 获取 Profile 失败，使用模拟数据:', error.message);
      return db.get('profiles').value() || [];
    }
  }

  /**
   * 下载 Profile
   */
  async downloadProfile(activationCode, confirmationCode = '', nickname = '') {
    if (this.useMockData || !(await this.isLPACAvailable())) {
      // 模拟下载
      const { v4: uuidv4 } = require('uuid');
      const mockProfile = {
        id: uuidv4(),
        iccid: `8986${Math.floor(Math.random() * 10000000000000000)}`,
        name: nickname || 'New Profile',
        nickname: nickname,
        provider: 'Mock Provider',
        state: 'disabled',
        icon: '📱',
        activationCode,
        confirmationCode,
        downloadedAt: new Date().toISOString(),
        class: 'operational'
      };
      
      db.get('profiles').push(mockProfile).write();
      return mockProfile;
    }

    try {
      // 使用真实 lpac 下载
      const result = await this.executor.downloadProfile(activationCode, confirmationCode);
      
      // 如果有昵称，设置昵称
      if (nickname && result.iccid) {
        await this.executor.setProfileNickname(result.iccid, nickname);
      }

      // 刷新 Profile 列表
      await this.getProfiles();
      
      return result;
    } catch (error) {
      throw new Error(`下载 Profile 失败: ${error.message}`);
    }
  }

  /**
   * 启用 Profile
   */
  async enableProfile(id) {
    const profile = db.get('profiles').find({ id }).value();
    if (!profile) {
      throw new Error('Profile not found');
    }

    if (this.useMockData || !(await this.isLPACAvailable())) {
      // 模拟启用
      db.get('profiles').forEach(p => {
        p.state = p.id === id ? 'enabled' : 'disabled';
      }).write();
      
      return db.get('profiles').find({ id }).value();
    }

    try {
      // 使用真实 lpac
      await this.executor.enableProfile(profile.iccid);
      
      // 刷新列表
      await this.getProfiles();
      
      return db.get('profiles').find({ id }).value();
    } catch (error) {
      throw new Error(`启用 Profile 失败: ${error.message}`);
    }
  }

  /**
   * 禁用 Profile
   */
  async disableProfile(id) {
    const profile = db.get('profiles').find({ id }).value();
    if (!profile) {
      throw new Error('Profile not found');
    }

    if (this.useMockData || !(await this.isLPACAvailable())) {
      // 模拟禁用
      db.get('profiles')
        .find({ id })
        .assign({ state: 'disabled' })
        .write();
      
      return db.get('profiles').find({ id }).value();
    }

    try {
      // 使用真实 lpac
      await this.executor.disableProfile(profile.iccid);
      
      // 刷新列表
      await this.getProfiles();
      
      return db.get('profiles').find({ id }).value();
    } catch (error) {
      throw new Error(`禁用 Profile 失败: ${error.message}`);
    }
  }

  /**
   * 删除 Profile
   */
  async deleteProfile(id) {
    const profile = db.get('profiles').find({ id }).value();
    if (!profile) {
      throw new Error('Profile not found');
    }

    if (this.useMockData || !(await this.isLPACAvailable())) {
      // 模拟删除
      db.get('profiles').remove({ id }).write();
      return profile;
    }

    try {
      // 使用真实 lpac
      await this.executor.deleteProfile(profile.iccid);
      
      // 从数据库删除
      db.get('profiles').remove({ id }).write();
      
      return profile;
    } catch (error) {
      throw new Error(`删除 Profile 失败: ${error.message}`);
    }
  }

  /**
   * 更新 Profile 昵称
   */
  async updateProfileNickname(id, nickname) {
    const profile = db.get('profiles').find({ id }).value();
    if (!profile) {
      throw new Error('Profile not found');
    }

    if (this.useMockData || !(await this.isLPACAvailable())) {
      // 模拟更新
      db.get('profiles')
        .find({ id })
        .assign({ nickname })
        .write();
      
      return db.get('profiles').find({ id }).value();
    }

    try {
      // 使用真实 lpac
      await this.executor.setProfileNickname(profile.iccid, nickname);
      
      // 更新数据库
      db.get('profiles')
        .find({ id })
        .assign({ nickname })
        .write();
      
      return db.get('profiles').find({ id }).value();
    } catch (error) {
      throw new Error(`更新昵称失败: ${error.message}`);
    }
  }

  /**
   * 获取芯片信息
   */
  async getChipInfo() {
    if (this.useMockData || !(await this.isLPACAvailable())) {
      // 返回模拟数据
      return {
        eid: '89049032123456789012345678901234',
        platformVersion: '2.3.0',
        platformLabel: 'STMicroelectronics',
        euiccInfo: {
          svn: '3.3.0',
          euiccFirmwareVer: '1.0.0',
          extCardResource: '0000',
          uiccCapability: '0000000000'
        },
        manufacturer: {
          name: 'STMicroelectronics',
          productionDate: '2023-06-15'
        },
        certificateIssuer: {
          commonName: 'GSMA',
          country: 'GB',
          organization: 'GSMA'
        },
        freeSpace: 524288,
        totalSpace: 1048576
      };
    }

    try {
      return await this.executor.getChipInfo();
    } catch (error) {
      throw new Error(`获取芯片信息失败: ${error.message}`);
    }
  }

  /**
   * 获取通知列表
   */
  async getNotifications() {
    if (this.useMockData || !(await this.isLPACAvailable())) {
      return db.get('notifications').value() || [];
    }

    try {
      const notifications = await this.executor.listNotifications();
      db.set('notifications', notifications).write();
      return notifications;
    } catch (error) {
      console.error('[LPAC Service] 获取通知失败，使用模拟数据:', error.message);
      return db.get('notifications').value() || [];
    }
  }

  /**
   * 处理通知
   */
  async processNotification(id) {
    const notification = db.get('notifications').find({ id }).value();
    if (!notification) {
      throw new Error('Notification not found');
    }

    if (this.useMockData || !(await this.isLPACAvailable())) {
      // 模拟处理
      db.get('notifications')
        .find({ id })
        .assign({ processed: true, processedAt: new Date().toISOString() })
        .write();
      
      return db.get('notifications').find({ id }).value();
    }

    try {
      await this.executor.processNotification(notification.seqNumber);
      
      db.get('notifications')
        .find({ id })
        .assign({ processed: true, processedAt: new Date().toISOString() })
        .write();
      
      return db.get('notifications').find({ id }).value();
    } catch (error) {
      throw new Error(`处理通知失败: ${error.message}`);
    }
  }

  /**
   * 删除通知
   */
  async deleteNotification(id) {
    const notification = db.get('notifications').find({ id }).value();
    if (!notification) {
      throw new Error('Notification not found');
    }

    if (this.useMockData || !(await this.isLPACAvailable())) {
      // 模拟删除
      db.get('notifications').remove({ id }).write();
      return notification;
    }

    try {
      await this.executor.deleteNotification(notification.seqNumber);
      db.get('notifications').remove({ id }).write();
      return notification;
    } catch (error) {
      throw new Error(`删除通知失败: ${error.message}`);
    }
  }
}

module.exports = new LPACService();

