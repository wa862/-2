import request from '@/utils/request'

export interface AiKnowledgeItem {
  id: number
  question: string
  answer: string
  category?: string
  keywords?: string
  status?: number
  sortOrder?: number
  hitCount?: number
}

export function getKnowledgeList(keyword = '', all = true) {
  return request.get<any, AiKnowledgeItem[]>('/ai/knowledge', { params: { keyword, all } })
}

export function createKnowledge(data: Partial<AiKnowledgeItem>) {
  return request.post<any, AiKnowledgeItem>('/ai/knowledge', data)
}

export function updateKnowledge(id: number, data: Partial<AiKnowledgeItem>) {
  return request.put<any, AiKnowledgeItem>(`/ai/knowledge/${id}`, data)
}

export function deleteKnowledge(id: number) {
  return request.request({ method: 'DELETE', url: `/ai/knowledge/${id}` })
}
