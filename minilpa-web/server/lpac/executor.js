/**
 * LPAC Executor - 执行 lpac 命令的包装器
 * lpac 是用于管理 eSIM 的命令行工具
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

class LPACExecutor {
  constructor() {
    // lpac 可执行文件路径
    this.lpacPath = this.findLPACPath();
    this.apduDriver = process.env.APDU_DRIVER || 'auto'; // auto, pcsc, at
    this.logLevel = process.env.LPAC_LOG_LEVEL || 'info';
  }

  /**
   * 查找 lpac 可执行文件
   */
  findLPACPath() {
    const possiblePaths = [
      path.join(__dirname, '../../bin/lpac'), // 项目 bin 目录
      '/usr/local/bin/lpac',                  // 系统安装
      '/usr/bin/lpac',                        // Linux 默认
      path.join(process.env.HOME || '', '.local/bin/lpac') // 用户目录
    ];

    for (const p of possiblePaths) {
      if (fs.existsSync(p)) {
        return p;
      }
    }

    // 如果都找不到，使用默认路径（会在执行时报错）
    return 'lpac';
  }

  /**
   * 执行 lpac 命令
   * @param {Array} args - 命令参数
   * @param {Object} options - 执行选项
   * @returns {Promise} 返回执行结果
   */
  async execute(args = [], options = {}) {
    return new Promise((resolve, reject) => {
      const fullArgs = [
        '-apdu', this.apduDriver,
        ...args
      ];

      console.log(`[LPAC] 执行命令: ${this.lpacPath} ${fullArgs.join(' ')}`);

      const proc = spawn(this.lpacPath, fullArgs, {
        encoding: 'utf8',
        ...options
      });

      let stdout = '';
      let stderr = '';

      proc.stdout.on('data', (data) => {
        stdout += data.toString();
      });

      proc.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      proc.on('close', (code) => {
        if (code === 0) {
          resolve({
            success: true,
            code,
            stdout: stdout.trim(),
            stderr: stderr.trim(),
            data: this.parseOutput(stdout)
          });
        } else {
          reject({
            success: false,
            code,
            stdout: stdout.trim(),
            stderr: stderr.trim(),
            error: stderr.trim() || `lpac exited with code ${code}`
          });
        }
      });

      proc.on('error', (error) => {
        reject({
          success: false,
          error: error.message,
          hint: 'lpac 可能未安装或路径不正确'
        });
      });
    });
  }

  /**
   * 解析 lpac 输出为 JSON
   */
  parseOutput(output) {
    try {
      // lpac 通常输出 JSON 格式
      return JSON.parse(output);
    } catch (e) {
      // 如果不是 JSON，返回原始文本
      return { raw: output };
    }
  }

  /**
   * 获取 eUICC 信息
   */
  async getChipInfo() {
    try {
      const result = await this.execute(['chip', 'info']);
      return result.data;
    } catch (error) {
      throw new Error(`获取芯片信息失败: ${error.error || error.message}`);
    }
  }

  /**
   * 列出所有 Profile
   */
  async listProfiles() {
    try {
      const result = await this.execute(['profile', 'list']);
      return result.data;
    } catch (error) {
      throw new Error(`获取 Profile 列表失败: ${error.error || error.message}`);
    }
  }

  /**
   * 下载 Profile
   * @param {string} activationCode - 激活码
   * @param {string} confirmationCode - 确认码（可选）
   */
  async downloadProfile(activationCode, confirmationCode = '') {
    try {
      const args = ['profile', 'download', '-a', activationCode];
      if (confirmationCode) {
        args.push('-c', confirmationCode);
      }
      const result = await this.execute(args);
      return result.data;
    } catch (error) {
      throw new Error(`下载 Profile 失败: ${error.error || error.message}`);
    }
  }

  /**
   * 启用 Profile
   * @param {string} iccid - Profile ICCID
   */
  async enableProfile(iccid) {
    try {
      const result = await this.execute(['profile', 'enable', '-i', iccid]);
      return result.data;
    } catch (error) {
      throw new Error(`启用 Profile 失败: ${error.error || error.message}`);
    }
  }

  /**
   * 禁用 Profile
   * @param {string} iccid - Profile ICCID
   */
  async disableProfile(iccid) {
    try {
      const result = await this.execute(['profile', 'disable', '-i', iccid]);
      return result.data;
    } catch (error) {
      throw new Error(`禁用 Profile 失败: ${error.error || error.message}`);
    }
  }

  /**
   * 删除 Profile
   * @param {string} iccid - Profile ICCID
   */
  async deleteProfile(iccid) {
    try {
      const result = await this.execute(['profile', 'delete', '-i', iccid]);
      return result.data;
    } catch (error) {
      throw new Error(`删除 Profile 失败: ${error.error || error.message}`);
    }
  }

  /**
   * 设置 Profile 昵称
   * @param {string} iccid - Profile ICCID
   * @param {string} nickname - 昵称
   */
  async setProfileNickname(iccid, nickname) {
    try {
      const result = await this.execute(['profile', 'nickname', '-i', iccid, '-n', nickname]);
      return result.data;
    } catch (error) {
      throw new Error(`设置昵称失败: ${error.error || error.message}`);
    }
  }

  /**
   * 列出通知
   */
  async listNotifications() {
    try {
      const result = await this.execute(['notification', 'list']);
      return result.data;
    } catch (error) {
      throw new Error(`获取通知列表失败: ${error.error || error.message}`);
    }
  }

  /**
   * 处理通知
   * @param {number} seqNumber - 通知序列号
   */
  async processNotification(seqNumber) {
    try {
      const result = await this.execute(['notification', 'process', '-s', seqNumber.toString()]);
      return result.data;
    } catch (error) {
      throw new Error(`处理通知失败: ${error.error || error.message}`);
    }
  }

  /**
   * 删除通知
   * @param {number} seqNumber - 通知序列号
   */
  async deleteNotification(seqNumber) {
    try {
      const result = await this.execute(['notification', 'remove', '-s', seqNumber.toString()]);
      return result.data;
    } catch (error) {
      throw new Error(`删除通知失败: ${error.error || error.message}`);
    }
  }

  /**
   * 检查 lpac 是否可用
   */
  async checkAvailability() {
    try {
      const result = await this.execute(['version']);
      return {
        available: true,
        version: result.stdout,
        path: this.lpacPath
      };
    } catch (error) {
      return {
        available: false,
        error: error.error || error.message,
        hint: 'lpac 未安装或无法访问'
      };
    }
  }
}

module.exports = LPACExecutor;

