import request from './request'

export function getChipInfo() {
  return request({
    url: '/chip',
    method: 'get'
  })
}

export function getChipCertificate() {
  return request({
    url: '/chip/certificate',
    method: 'get'
  })
}

