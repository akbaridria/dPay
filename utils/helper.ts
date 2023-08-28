export const delay = (ms: number) => {
  return new Promise( resolve => setTimeout(resolve, ms) );
}

export const trimWallet = (text: string): string => {
  return text.slice(0,5) + '...' + text.slice(-3)
}