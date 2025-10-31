import request from './request'

export function parseQRCode(file) {
  const formData = new FormData()
  formData.append('image', file)
  
  return request({
    url: '/qrcode/parse',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

export function parseText(text) {
  return request({
    url: '/qrcode/parse-text',
    method: 'post',
    data: { text }
  })
}

