import request from '@/utils/request'

export interface AiChatResponse {
  answer: string
  sourceType: 'KNOWLEDGE' | 'BUSINESS' | 'OPENAI' | 'ZHIPU' | 'FALLBACK'
  matchedKnowledgeId?: number
  matchedQuestion?: string
  score?: number
}

export function askAi(question: string, userId?: number) {
  return request.post<any, AiChatResponse>('/ai/chat', { question, userId }, { timeout: 60000 })
}
