import request from '@/utils/request'

export interface AiChatResponse {
  answer: string
  sourceType: 'KNOWLEDGE' | 'BUSINESS' | 'OPENAI' | 'ZHIPU' | 'FALLBACK'
  matchedKnowledgeId?: number
  matchedQuestion?: string
  score?: number
}

export const askAi = (question: string, userId?: number) =>
  request<AiChatResponse>({
    url: '/ai/chat',
    method: 'POST',
    data: { question, userId },
  })
